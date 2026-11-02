#!/usr/bin/env python3
"""Check that ci-shared.yml at a commit, and every pipeline it dispatches to, exist there.

Run by promote-release.yml before it moves the `release` tag. Every repository's ci.yml
resolves ci-shared.yml@release, and ci-shared.yml dispatches to the pipelines in this
repository. If one of them is missing at the promoted commit, every caller fails with
"workflow was not found" as soon as the tag moves.

ci-shared.yml names its pipelines absolutely (ktsu-dev/.github/<path>@release). A plain
`./` reference counts as well. For both, the pipeline must exist at the commit being
promoted, which is the commit `@release` will point at. A job-level `uses:` that this check
cannot resolve at that commit fails the check instead of being skipped. That covers another
repository, or this one at a ref other than `release`. Skipping those is how the check came
to pass without verifying anything (ktsu-dev/.github#29). Zero verified pipelines also fails.

Usage: check-release-pipelines.py <sha>   (run from inside this repository's checkout)
"""

import subprocess
import sys

import yaml

THIS_REPO = "ktsu-dev/.github"
RELEASE_REF = "release"
DISPATCHER = ".github/workflows/ci-shared.yml"


def exists_at(sha, path):
    return subprocess.run(["git", "cat-file", "-e", f"{sha}:{path}"],
                          capture_output=True).returncode == 0


def resolve(uses):
    """Return (path, None) for a pipeline in this repository at the promoted commit,
    or (None, reason) for a reference this check cannot verify."""
    if uses.startswith("./"):
        return uses[2:], None

    target, sep, ref = uses.partition("@")
    if not sep:
        return None, "has no @ref, so it cannot be resolved"

    parts = target.split("/", 2)
    if len(parts) < 3:
        return None, "is not of the form owner/repo/path@ref"
    repo, path = "/".join(parts[:2]), parts[2]

    if repo.lower() != THIS_REPO.lower():
        return None, f"points at {repo}, which this check cannot verify at the promoted commit"
    if ref != RELEASE_REF:
        return None, (f"points at @{ref}, not @{RELEASE_REF}, so it is not resolved "
                      "against the commit being promoted")
    return path, None


def main(argv):
    if len(argv) != 2:
        print(__doc__.strip().splitlines()[-1], file=sys.stderr)
        return 2
    sha = argv[1]

    show = subprocess.run(["git", "show", f"{sha}:{DISPATCHER}"], capture_output=True, text=True)
    if show.returncode != 0:
        print(f"::error::{sha} has no {DISPATCHER}.")
        return 1

    doc = yaml.safe_load(show.stdout) or {}
    problems = []
    verified = []
    for job, spec in (doc.get("jobs") or {}).items():
        uses = (spec or {}).get("uses")
        if not uses:
            continue
        path, reason = resolve(uses)
        if reason:
            problems.append(f"{job} -> {uses} {reason}")
        elif not exists_at(sha, path):
            problems.append(f"{job} -> {uses} is missing at {sha} ({path})")
        else:
            verified.append(f"{job} -> {path}")

    if problems:
        print("::error::ci-shared.yml dispatches to pipelines that cannot be verified at this commit:")
        for p in problems:
            print(f"::error::  {p}")
        return 1

    if not verified:
        print("::error::ci-shared.yml dispatches to no pipeline this check recognises, so nothing "
              "was verified. Refusing to promote on a check that checked nothing.")
        return 1

    print(f"ci-shared.yml and the {len(verified)} pipeline(s) it dispatches to are present:")
    for v in verified:
        print(f"  {v}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
