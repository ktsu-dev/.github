# Dependabot auto-merge

Dependabot PRs across ktsu-dev merge themselves, but only after CI has actually reported
green. The decision lives in one place — [`.github/workflows/dependabot-merge.yml`] in
this repository — and every other repository calls it.

## Why it is shaped this way

The previous version ran `on: pull_request` and called `gh pr merge --auto`. That flag
reads like "merge when green", but it means "merge when branch protection is satisfied",
which delegates the waiting entirely to required status checks. `main` is unprotected in
these repositories and declares no required checks, so the condition was vacuously true
the moment the PR opened.

In `Semantics`, PR #233 opened at 04:18:08 and merged at 04:18:20. Its test jobs did not
start until 04:18:34 and went red at 04:21. A failing dependency bump reached `main`
twelve seconds after it was proposed.

The fix is to decide the merge *after* CI reports, by listening for `workflow_run`
completions rather than for the PR itself. That means:

- the list of checks that must be green is read from the commit, so no repository needs
  branch protection configured to get the guarantee;
- nothing waits on us while we wait on it, so there is no deadlock and no runner sitting
  idle for the length of a build;
- the token is a real one. GitHub hands `pull_request` runs on a Dependabot branch a
  read-only `GITHUB_TOKEN`; a `workflow_run` run executes in the base repository's
  context, where `contents: write` means what it says.

## What the shared workflow guarantees

- The PR is located by **head SHA**, never by branch name or actor. A commit pushed after
  CI finished moves the head, so nothing matches and nothing merges — rather than merging
  code CI never saw.
- The author is read from the **API**, not from the event payload. A re-run re-attributes
  `actor.login` to whoever pressed the button, and nothing in the payload is signed
  (`githubactions:S8232`).
- **Every** check run on the commit must be green, not just the one that triggered us.
  Anything still in flight is a reason to wait; whichever run finishes last fires the
  workflow again and the merge happens on that pass.
- `skipped` and `neutral` count as green — `dotnet.yml` skips *Analyze & Release* and
  *Security Scanning* on a pull request, and CodeQL reports `neutral` there. A check that
  is absent entirely is not counted, so a workflow that legitimately does not run (say,
  *Verify Generated Files* on a markdown-only bump) does not block forever.

## The caller

Each repository holds this at `.github/workflows/dependabot-merge.yml`:

```yaml
name: Dependabot auto-merge

on:
  workflow_run:
    workflows:
      - ".NET Workflow"
    types: [completed]

permissions:
  contents: write
  pull-requests: write

jobs:
  merge:
    if: >
      github.event.workflow_run.event == 'pull_request' &&
      github.event.workflow_run.conclusion == 'success'
    uses: ktsu-dev/.github/.github/workflows/dependabot-merge.yml@main
    with:
      head-sha: ${{ github.event.workflow_run.head_sha }}
```

### The one thing to get right per repository

`workflows:` must name **every** workflow the repository runs on a pull request, by the
workflow's `name:` field — not its filename.

That list is what re-opens the merge question. The gate refuses to merge while any check
on the commit is still pending, so a workflow missing from the list is one whose
completion never triggers a re-evaluation. If it happens to finish last, a Dependabot PR
that is genuinely green sits unmerged. Listing a workflow that does not exist is harmless
— it simply never fires.

Most repositories run only `.NET Workflow`. The exceptions as of this rollout:

| Repository | `workflows:` |
| ---------- | ------------ |
| `Sdk` | `.NET SDK Workflow` |
| `Semantics` | `.NET Workflow`, `Verify Generated Files` |
| `ImGuiApp` | `.NET Workflow`, `iOS Workflow` |
| `CredentialCache` | `.NET Workflow`, `Cross-platform verification` |
| `GitIntegration` | `.NET Workflow`, `Cross-Platform Tests` |

**Adding a new pull-request workflow to a repository means adding its name here too.**
Renaming one means updating it. Nothing detects the omission — the symptom is a green
Dependabot PR that never merges.

The caller must not list its own name (`Dependabot auto-merge`); it is triggered by
`workflow_run`, not `pull_request`, and a workflow cannot wait on itself.

## Not covered

`VST` has CI but no `dependabot.yml`, and `ImageGui`, `ByteSizeDotnet`, `blogs` and
`ktsu.dev` have neither. `winget-pkgs` is a fork of `microsoft/winget-pkgs` and follows
upstream. None of them carry the caller; adding `dependabot.yml` to any of them is what
would make it worth adding.

[`.github/workflows/dependabot-merge.yml`]: ../.github/workflows/dependabot-merge.yml
