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
    paths-ignore:
      ["**.md", ".github/ISSUE_TEMPLATE/**", ".github/pull_request_template.md"]
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

Inside `ci-shared.yml` the pipelines are referenced relatively (`./.github/workflows/...`),
which resolves to the same commit of this repository as `ci-shared.yml` itself. So the
dispatcher and the pipeline it selects are always versioned together: moving `release`
moves both atomically, and a pull request here tests its own pipelines rather than the
released ones.

## Interaction with the Dependabot merge gate

`dependabot-merge.yml` in each repository lists the workflows whose completion re-opens the
merge question, **by workflow name**. Under shared CI that list is the single name `CI`,
identical in every repository — which removes the per-repository footgun described in
[`dependabot-auto-merge.md`]. Renaming the caller away from `CI`, or back to per-pipeline
names, silently stops Dependabot PRs merging.

## Adding a pipeline

1. Add the workflow to this repository with `on: workflow_call`.
2. Add a job to `ci-shared.yml` with a static `uses:` and an `if:` on `detect`'s outputs.
3. Teach `detect` the new topic and marker file, including its failure messages.
4. Move the `release` tag.

No repository is edited unless it is changing what kind of repository it is.

[`ci-shared.yml`]: ../.github/workflows/ci-shared.yml
[`dependabot-auto-merge.md`]: ./dependabot-auto-merge.md
