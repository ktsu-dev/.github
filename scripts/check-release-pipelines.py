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

Usage: check-release-pipelines.py <full commit sha>   (run from inside this repository's checkout)
"""

import re
import subprocess
import sys

import yaml

THIS_REPO = "ktsu-dev/.github"
RELEASE_REF = "release"
DISPATCHER = ".github/workflows/ci-shared.yml"
# A full object name only. Anything else, a leading "-" in particular, would reach git as
# something other than a commit.
SHA_PATTERN = re.compile(r"[0-9a-f]{40}|[0-9a-f]{64}")


# Object names go to git on stdin through `cat-file --batch`, never on its command line, so
# nothing taken from this script's arguments or from ci-shared.yml can be read as an option.
def read_object(sha, path):
    """Return the blob at <sha>:<path> as text, or None when it does not exist there."""
    spec = f"{sha}:{path}\n".encode("utf-8")
    out = subprocess.run(["git", "cat-file", "--batch"], input=spec,
                         capture_output=True, check=False).stdout
    header, _, rest = out.partition(b"\n")
    fields = header.split()
    if len(fields) != 3 or fields[1] != b"blob":
        return None
    return rest[:int(fields[2])].decode("utf-8")


def exists_at(sha, path):
    return read_object(sha, path) is not None


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


def check(sha, doc):
    """Return (verified, problems) for the job-level `uses:` in a parsed ci-shared.yml."""
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
    return verified, problems


def main(argv):
    if len(argv) != 2:
        print(__doc__.strip().splitlines()[-1], file=sys.stderr)
        return 2
    sha = argv[1]
    if not SHA_PATTERN.fullmatch(sha):
        print(f"::error::'{sha}' is not a full commit SHA.")
        return 2

    dispatcher = read_object(sha, DISPATCHER)
    if dispatcher is None:
        print(f"::error::{sha} has no {DISPATCHER}.")
        return 1

    verified, problems = check(sha, yaml.safe_load(dispatcher) or {})

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
