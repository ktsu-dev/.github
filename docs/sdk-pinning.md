# One ktsu SDK version per repository

`update-sdks.yml` pins every `ktsu.Sdk*` MSBuild SDK reference in a repository to one agreed
version, weekly and on demand. The logic lives in [`scripts/update-sdks.ps1`] so it can be run
and tested outside Actions; the workflow is the schedule and the guard rails around it.

## Why this exists alongside Dependabot

Dependabot already raises version bumps, and its `ktsu` group raises them together. What it
does not guarantee is that a repository ends up on *one* version: a grouped pull request that
updates some entries and not others is a normal outcome, and the result builds against two
versions of the same SDK. That is not a reproducible build, and it is not visible in a diff
that looks like a routine bump.

So the two are not redundant. Dependabot chases versions; this converges them. The unit of
work here is the **reference**, not the package — a repository whose `global.json` and project
files disagree is repaired even when no newer version exists.

## What it looks at

Every `global.json` under `msbuild-sdks`, and every `Sdk="…/…"` attribute in every `.csproj`.
A package is in the family when it is `ktsu.Sdk` exactly or begins with `ktsu.Sdk.`, so
`ktsu.Sdk` and `ktsu.Sdk.Tool` both count and an unrelated `ktsu.SdkAdjacent` does not.

Versions are compared as semantic versions, so `2.9.0` sorts below `2.28.1` and a prerelease
sorts below the release it precedes. Prereleases are never a target. A reference already ahead
of the latest release — which is what a deliberate prerelease pin looks like — becomes the
target for the rest of the repository rather than being rolled backwards.

Edits are textual and scoped to the version that follows the package name, so key order,
formatting, comments, unrelated entries and the trailing newline all survive.

A package whose version cannot be resolved — a feed hiccup, a package that was never published,
a name that has since been retired — fails the run. Every package is still looked at first, so
one run names every unresolvable package rather than one per run, and the run fails before
anything is written. Reporting the failures and converging the rest would leave the repository
on two versions of the family, which is the state this exists to repair.

## What it does not do

It does not open a pull request. It builds and tests the repository with the new pins and
pushes to the default branch only if that passes, which is the same bar a merge would clear.
A failure leaves the repository untouched and red, which is the signal that a version needs a
person.

## The caller

```yaml
name: Update SDKs

on:
  schedule:
    - cron: "0 8 * * MON"
  workflow_dispatch:
    inputs:
      version:
        description: Pin every ktsu SDK to this version instead of the latest release
        required: false
        type: string

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

# A called workflow cannot hold more permission than its caller, so the write the push needs
# is granted here.
permissions:
  contents: write

jobs:
  update-sdks:
    uses: ktsu-dev/.github/.github/workflows/update-sdks.yml@release
    with:
      version: ${{ inputs.version || '' }}
```

A repository that targets nothing Windows-specific can pass `runs-on: ubuntu-latest`. The
default is `windows-latest` because the verification build is what licenses the push, and a
repository with Windows targets cannot be built anywhere else.

## Running it by hand

```powershell
# Report and apply, resolving the latest release of each package from NuGet
./scripts/update-sdks.ps1 -Path ../SomeRepo

# Move a repository onto a specific version
./scripts/update-sdks.ps1 -Path ../SomeRepo -Version 2.29.0

# Report without writing
./scripts/update-sdks.ps1 -Path ../SomeRepo -WhatIf
```

```powershell
./scripts/tests/update-sdks.tests.ps1
```

Each test case is a failure the previous workflow actually had, so the file doubles as the
record of what was wrong with it.

## What was wrong with the previous workflow

It was a silent no-op in every repository, and had been for as long as the feed has carried a
prerelease. Confirmed against the live feed rather than read off the source:

| Defect | Effect |
| ------ | ------ |
| `[System.Version]::Parse` on every published version | Throws on `2.28.1-pre.1`; the `catch` reported "may not be published to NuGet.org" and returned null, which the caller read as "no update available" |
| `-like "ktsu.Sdk.*"` and a `ktsu\.Sdk\.\w+` pattern | Both miss the bare `ktsu.Sdk`, the package nearly every repository pins. `VST`, which pins only that, reported "No ktsu SDKs found" and stayed on `2.8.0` |
| One recorded version per package, first seen wins | A package whose first-seen reference was current was skipped entirely, so the stragglers behind it never moved |
| A `[\d\.]+` replacement pattern | Read `2.0.0` out of `2.0.0-pre.1` and rewrote only that part, producing a version that was never published |
| `-not $env:FORCE_UPDATE` | `[bool]"false"` is `$true`, so the input never forced anything |
| `git push origin main` | Hardcoded a branch name |
| `ConvertTo-Json -Depth 10` round-trip | Reformatted the whole file to change one string |

The four repositories on `ktsu.Sdk` `2.25.0` at the time of writing, and `VST` on `2.8.0`, are
what that adds up to.

[`scripts/update-sdks.ps1`]: ../scripts/update-sdks.ps1
