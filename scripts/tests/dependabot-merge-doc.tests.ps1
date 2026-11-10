<#
.SYNOPSIS
	Checks the caller template in docs/dependabot-auto-merge.md against the CI it has to follow.

.DESCRIPTION
	The template is what a new repository copies. Its `workflow_run` trigger only fires for
	workflows named in `workflows:`, and listing a name that never runs is silent: green
	Dependabot PRs simply sit unmerged. It listed `.NET Workflow` after repositories had moved
	to the canonical `ci.yml` (`name: CI`), whose pipelines run as reusable workflows and never
	produce a `workflow_run` of their own, and it tracked `@main` rather than the promoted
	`@release`. See ktsu-dev/.github#59.

	These cases read the canonical `ci.yml` from docs/shared-ci.md, so renaming it there
	without updating the merge caller fails here.

	Run with pwsh: ./scripts/tests/dependabot-merge-doc.tests.ps1
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:Docs = Join-Path $PSScriptRoot '..' '..' 'docs' | Resolve-Path
$script:Failures = 0
$script:Count = 0

function Test-Case {
	param([string]$Name, [scriptblock]$Assertion)

	$script:Count++
	$problem = & $Assertion
	if ($problem) {
		$script:Failures++
		Write-Host "FAIL  $Name" -ForegroundColor Red
		Write-Host "      $problem" -ForegroundColor Red
		return
	}

	Write-Host "ok    $Name" -ForegroundColor Green
}

# The fenced yaml block that follows the sentence introducing it, located by that sentence so
# an example added earlier in the document can't take its place.
function Get-YamlBlockAfter {
	param([string]$Document, [string]$Introduction)

	$lines = Get-Content -LiteralPath (Join-Path $script:Docs $Document)
	$anchor = -1
	for ($i = 0; $i -lt $lines.Count; $i++) {
		if ($lines[$i] -match $Introduction) { $anchor = $i; break }
	}
	if ($anchor -lt 0) { throw "No line matching '$Introduction' in $Document, so this test cannot find the block it guards." }

	$start = -1
	for ($i = $anchor; $i -lt $lines.Count; $i++) {
		if ($lines[$i] -eq '```yaml') { $start = $i + 1; break }
	}
	if ($start -lt 0) { throw "No fenced yaml block follows '$Introduction' in $Document." }

	$block = @()
	for ($i = $start; $i -lt $lines.Count -and $lines[$i] -ne '```'; $i++) { $block += $lines[$i] }
	return $block
}

$script:Caller = Get-YamlBlockAfter -Document 'dependabot-auto-merge.md' -Introduction '^Each repository holds this at .*dependabot-merge\.yml'
$script:CiName = (Get-YamlBlockAfter -Document 'shared-ci.md' -Introduction '^Each repository holds this at .*ci\.yml' |
	Where-Object { $_ -match '^name:\s*(.+)$' } | Select-Object -First 1) -replace '^name:\s*', '' -replace '^["'']|["'']$', ''

function Get-ListenedWorkflows {
	$names = @()
	$inList = $false
	foreach ($line in $script:Caller) {
		if ($line -match '^\s*workflows:\s*$') { $inList = $true; continue }
		if ($inList) {
			if ($line -match '^\s*-\s*["'']?([^"'']+)["'']?\s*$') { $names += $Matches[1]; continue }
			break
		}
	}
	return $names
}

Test-Case -Name 'the caller listens for the canonical ci.yml by its name' -Assertion {
	if (-not $script:CiName) { return 'the canonical ci.yml in docs/shared-ci.md has no name:' }
	$listened = @(Get-ListenedWorkflows)
	if ($listened -notcontains $script:CiName) {
		return "workflows: lists '$($listened -join "', '")', not '$script:CiName', the name of the canonical ci.yml"
	}
}

Test-Case -Name 'the caller names no pipeline that only runs inside ci.yml' -Assertion {
	$listened = @(Get-ListenedWorkflows)
	if ($listened -contains '.NET Workflow') {
		return "'.NET Workflow' is dotnet.yml, a reusable workflow under ci.yml; it never produces a workflow_run"
	}
}

Test-Case -Name 'the caller tracks the promoted release ref' -Assertion {
	$uses = $script:Caller | Where-Object { $_ -match 'uses:\s*\S*dependabot-merge\.yml@' } | Select-Object -First 1
	if (-not $uses) { return 'the caller does not call dependabot-merge.yml' }
	if ($uses -notmatch 'dependabot-merge\.yml@release\s*$') { return "expected @release, got '$($uses.Trim())'" }
}

Write-Host ''
if ($script:Failures -gt 0) {
	Write-Host "$script:Failures of $script:Count case(s) failed." -ForegroundColor Red
	exit 1
}

Write-Host "All $script:Count case(s) passed." -ForegroundColor Green
