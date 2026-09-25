<#
.SYNOPSIS
	Checks the canonical ci.yml in docs/shared-ci.md against the regression it has already had.

.DESCRIPTION
	docs/shared-ci.md carries the `ci.yml` every repository holds byte-identical. Its trigger
	block has a deliberate asymmetry -- `push` filters paths, `pull_request` does not -- and
	that asymmetry has been silently undone twice by rollouts that regenerated the block from
	a symmetric template:

	  cf13319 (2026-08-23) removed paths-ignore from pull_request across 41 repositories
	  a4cec36 (2026-08-26) put it back, as a side effect of adopting the unified workflow

	A filtered `pull_request` trigger reports no check at all rather than a neutral one, so a
	ruleset requiring "Build, Test & Release" blocks every docs-only pull request permanently.
	See ktsu-dev/.github#5.

	Run with pwsh: ./scripts/tests/shared-ci-template.tests.ps1
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:Doc = Join-Path $PSScriptRoot '..' '..' 'docs' 'shared-ci.md' | Resolve-Path
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

# The block is located by the sentence that introduces it rather than by being the first
# fenced block in the file, so that adding an example earlier in the document does not
# silently point these assertions at the wrong YAML.
function Get-CallerWorkflow {
	$lines = Get-Content -LiteralPath $script:Doc
	$anchor = $lines.IndexOf(($lines | Where-Object { $_ -match '^Each repository holds this at .*ci\.yml' } | Select-Object -First 1))
	if ($anchor -lt 0) {
		throw "The sentence introducing the canonical ci.yml is no longer in $script:Doc, so this test cannot find the block it guards."
	}

	$start = -1
	for ($i = $anchor; $i -lt $lines.Count; $i++) {
		if ($lines[$i] -eq '```yaml') { $start = $i + 1; break }
	}
	if ($start -lt 0) { throw 'No fenced yaml block follows the introducing sentence.' }

	$body = @()
	for ($i = $start; $i -lt $lines.Count; $i++) {
		if ($lines[$i] -eq '```') { return , $body }
		$body += $lines[$i]
	}
	throw 'The fenced yaml block is not closed.'
}

# Returns the lines nested under a given trigger inside the top-level `on:` mapping.
function Get-TriggerBody {
	param([string[]]$Workflow, [string]$Trigger)

	$inOn = $false
	$body = @()
	$collecting = $false

	foreach ($line in $Workflow) {
		if ($line -match '^on:\s*$') { $inOn = $true; continue }
		if (-not $inOn) { continue }

		# Any column-zero content ends the `on:` mapping.
		if ($line -match '^\S') { break }

		if ($line -match "^  $([regex]::Escape($Trigger)):\s*$") { $collecting = $true; continue }

		# A sibling trigger at the same indent ends this one.
		if ($collecting -and $line -match '^  \S') { break }

		if ($collecting -and $line.Trim()) { $body += $line }
	}

	return , $body
}

$workflow = Get-CallerWorkflow

# The headline requirement, and the half that has regressed twice. A pull_request trigger
# carrying paths-ignore makes a docs-only PR unmergeable under a ruleset that requires the
# build check, because a skipped trigger reports nothing for the ruleset to wait on.
Test-Case -Name 'pull_request does not filter paths' -Assertion {
	$body = Get-TriggerBody -Workflow $workflow -Trigger 'pull_request'
	if ($body | Where-Object { $_ -match 'paths-ignore' }) {
		return "pull_request carries paths-ignore:`n      $($body -join "`n      ")"
	}
}

# The other half. Removing this one is the obvious over-correction, and it is wrong: release
# gating runs off KtsuBuild's should_release rather than the event type, so a docs-only push
# to main would cut a version.
Test-Case -Name 'push still filters paths' -Assertion {
	$body = Get-TriggerBody -Workflow $workflow -Trigger 'push'
	if (-not ($body | Where-Object { $_ -match 'paths-ignore' })) {
		return "push has lost its paths-ignore:`n      $($body -join "`n      ")"
	}
}

# Both triggers must still exist. A rewrite that drops `pull_request` altogether would pass
# the first assertion for the wrong reason.
Test-Case -Name 'both triggers are still declared' -Assertion {
	$missing = @('push', 'pull_request') | Where-Object {
		-not ($workflow | Where-Object { $_ -match "^  $_`:" })
	}
	if ($missing) { return "missing trigger(s): $($missing -join ', ')" }
}

Write-Host ''
if ($script:Failures -gt 0) {
	Write-Host "$script:Failures of $script:Count case(s) failed." -ForegroundColor Red
	exit 1
}

Write-Host "All $script:Count case(s) passed." -ForegroundColor Green
