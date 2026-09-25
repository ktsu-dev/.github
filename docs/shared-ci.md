# Shared CI

Every ktsu repository runs the same CI entry point: a `ci.yml` that calls
[`ci-shared.yml`] in this repository and nothing else. `ci-shared.yml` works out what kind
of repository it is looking at and dispatches to the right pipeline.

## Why a dispatcher

A repository that names its pipeline directly — `uses: .../dotnet.yml@release` — has to be
edited when it moves to a different pipeline, and the set of repositories needing that edit
is only discoverable by reading all of them. A repository that names `ci-shared.yml` says
"build me however ktsu builds this kind of repository", which stays true without edits.

The payoff is that adding a language or a build environment is a change here. A Rust
pipeline becomes one more job in `ci-shared.yml`; no repository is touched.

## How the dispatch works

`jobs.<job_id>.uses` cannot take an expression — GitHub is explicit that *"You cannot use
contexts or expressions in this keyword"* — so the dispatch is not a computed path. It is
one statically referenced job per pipeline, each gated by an `if:` on the `detect` job's
outputs. `if:` on a `uses:` job does work; the Dependabot merge gate has relied on it in
production since its rollout.

`detect` classifies the repository from two independent signals, and requires both:

| Signal      | Source                     | What it answers                     |
| ----------- | -------------------------- | ----------------------------------- |
| Topic       | `topics` on the repository | What the repository *intends* to be |
| Marker file | `global.json` for .NET     | What the repository *actually* is   |

Requiring both closes the two ways this goes wrong. `blogs` and `ktsu.dev` carry the
`dotnet` topic without being .NET builds, so a topic on its own over-matches. A repository
whose topic was never set would match nothing, and a run that matches no pipeline and
passes anyway is precisely the silent success this design exists to remove — so a
mismatch is a hard failure that names what to fix, not a skip.

Visibility comes from the API rather than `github.event.repository.private`. The payload
shape varies across `push`, `pull_request`, `schedule` and `workflow_dispatch`, and a
missing field would read as "public" — the one wrong answer that matters, because it
routes a private repository through the public pipeline.

### Forks

**A fork does not inherit its parent's topics.** Verified against `ktsu-dev/winget-pkgs`,
a fork of `microsoft/winget-pkgs`: the parent carries topics, the fork's repository object
has none at all. Selecting on a topic alone would therefore fail every fork of every ktsu
repository, and fail it by telling a stranger to add organization metadata they do not own.

So `detect` borrows the parent's topics when the repository is a fork and has no `dotnet`
topic of its own. A fork then classifies as whatever it was forked from. The marker-file
check still applies, and files *are* inherited, so this loosens nothing about what a fork
has to actually be. A fork that sets its own `dotnet` topic is taken at its word and the
parent is never consulted.

Nothing else needs a fork-specific gate, because the pipelines already have one each:

| Concern | Existing guard |
| --- | --- |
| Publishing | `ktsubuild` is passed `EXPECTED_OWNER: ktsu-dev` and decides `should_release` itself |
| SonarQube | every Sonar step is gated on `env.SONAR_TOKEN != ''`, which is empty in a fork |
| Installing the build tool | `dotnet tool install ktsu.KtsuBuild.Tool` from public NuGet, no secret |

A forker therefore gets discovery, build and tests across all three platforms, and the
steps that would need ktsu's secrets skip themselves.

## The caller

Each repository holds this at `.github/workflows/ci.yml`, byte-identical everywhere:

```yaml
name: CI

on:
  push:
    branches: [main, develop]
    paths-ignore:
      ["**.md", ".github/ISSUE_TEMPLATE/**", ".github/pull_request_template.md"]
  pull_request:
  schedule:
    - cron: "0 23 * * *" # Daily at 11 PM UTC
  workflow_dispatch:
    inputs:
      version-bump:
        description: 'Version bump type'
        required: false
        default: 'auto'
        type: choice
        options:
          - auto
          - patch
          - minor
          - major

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

# The caller grants; a called workflow can only reduce. This is the union of what the
# pipelines request -- dotnet.yml's release job needs contents and packages, its security
# job needs id-token -- and a pipeline that needs a permission missing here fails the run
# at startup, before any job exists to report it.
permissions:
  contents: write
  packages: write
  id-token: write

jobs:
  ci:
    uses: ktsu-dev/.github/.github/workflows/ci-shared.yml@release
    secrets: inherit
    with:
      # `inputs` is empty on push, pull_request and schedule; only a dispatch sets it.
      version-bump: ${{ inputs.version-bump || 'auto' }}
```

Triggers, path filters and concurrency live here because a reusable workflow cannot declare
triggers, and a concurrency group inside one would contend with the caller waiting on it —
`github.workflow` resolves to the caller on both sides, so the group string would collide.

### Why only `push` filters paths

The asymmetry is deliberate and is the one part of this block that must not be "tidied up"
into symmetry. `scripts/tests/shared-ci-template.tests.ps1` asserts both halves of it.

`push` keeps its `paths-ignore` because release gating runs off KtsuBuild's `should_release`
rather than the event type, so a docs-only push to `main` would otherwise cut a version.

`pull_request` must not have one. A filtered `pull_request` trigger does not report a
neutral check — it reports *nothing*, so any ruleset requiring **Build, Test & Release**
blocks a docs-only pull request permanently, with no check to wait on and nothing to
override. That also catches pull requests editing `DESCRIPTION.md` and `TAGS.md`, which the
Terraform workspace derives repository metadata from.

This has already been reverted twice by rollouts that regenerated the trigger block from a
symmetric template — `cf13319` removed the filter across 41 repositories on 2026-08-23, and
`a4cec36` put it back three days later as a side effect of adopting the unified workflow.
See ktsu-dev/.github#5.

## The `release` tag

Callers reference `@release`, a tag that is moved rather than a version that has to be
propagated. `main` can take work in progress without touching fifty repositories' CI;
moving the tag promotes it.

Promote by running the **Promote release** workflow in this repository from the Actions
tab. It takes a `ref` (default `main`) and refuses to move the tag unless:

- the ref resolves to a commit here;
- that commit is **contained in main**, so nothing reaches fifty repositories' CI without
  having gone through review here;
- `ci-shared.yml` exists at that commit, and every pipeline it dispatches to exists too.

It then force-moves an annotated `release` tag recording who promoted it, and writes a
summary saying which commit the tag moved from and to. Promotions are queued rather than
cancelled, so a run that may already have moved the tag is never interrupted.

Moving the tag by hand works too, but skips all of the above.

Inside `ci-shared.yml` the pipelines are referenced **absolutely**, at `@release` — not
relatively. A relative `./` inside a workflow that was itself reached through a tag is
resolved by GitHub against the tag *object* rather than the commit it points at, and a tag
object has no tree, so the lookup fails:

```text
error parsing called workflow ".github/workflows/ci.yml"
 -> "ktsu-dev/.github/.github/workflows/ci-shared.yml@release" (source tag with sha:af44498...)
 --> "./.github/workflows/dotnet.yml" : workflow was not found.
```

That sha is the annotated tag's own, not the commit it points to. The relative form does
resolve on a `pull_request` event, which is exactly what makes this trap worth writing
down — it looks correct until the first push to a default branch. The absolute form
resolves identically on every event, and because `release` is promoted as one unit the
dispatcher and the pipeline it selects still move together.

The cost is that a pull request against this repository tests its own `ci-shared.yml`
against the *released* pipelines rather than its own. Changing a pipeline and the
dispatcher together therefore wants two promotions, or a throwaway tag.

## Interaction with the Dependabot merge gate

`dependabot-merge.yml` in each repository lists the workflows whose completion re-opens the
merge question, **by workflow name**. Under shared CI that list is the single name `CI`,
identical in every repository — which removes the per-repository footgun described in
[`dependabot-auto-merge.md`]. Renaming the caller away from `CI`, or back to per-pipeline
names, silently stops Dependabot PRs merging.

## Interaction with the profile README

The Status column on the organization profile is the latest run of one workflow file on a
repository's default branch, and KtsuBuild reads that file **by name**. It reads `ci.yml` —
the caller, not the pipeline the caller dispatches to. That is deliberate for the same reason
the dispatcher exists: a repository that starts building through a new pipeline keeps its
badge without the generator being taught anything.

While repositories are still being moved over, [`update-readme.yml`] passes
`--fallback-workflow dotnet.yml`, so an unmigrated repository still shows a status and the run
logs a warning naming it. The flag comes off when the warnings stop.

A repository that has neither file reports no status, which is the intended signal for a
repository that has opted out of shared CI rather than a bug to work around.

## Related shared workflows

`update-sdks.yml` is reusable in the same way and reached through the same `release` tag, but
it is not part of the dispatcher: it runs on its own weekly schedule rather than on push, so
folding it into `ci-shared.yml` would run it on every commit. Repositories call it from their
own `update-sdks.yml`. See [`sdk-pinning.md`].

## Adding a pipeline

1. Add the workflow to this repository with `on: workflow_call`.
2. Add a job to `ci-shared.yml` with a static `uses:` and an `if:` on `detect`'s outputs.
3. Teach `detect` the new topic and marker file, including its failure messages.
4. Move the `release` tag.

No repository is edited unless it is changing what kind of repository it is.

[`ci-shared.yml`]: ../.github/workflows/ci-shared.yml
[`dependabot-auto-merge.md`]: ./dependabot-auto-merge.md
[`sdk-pinning.md`]: ./sdk-pinning.md
[`update-readme.yml`]: ../.github/workflows/update-readme.yml
