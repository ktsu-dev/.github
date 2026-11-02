<#
.SYNOPSIS
	Checks that CI actually runs the guard tests in this directory.

.DESCRIPTION
	The other *.tests.ps1 files guard update-sdks.ps1, which every repository fetches from
	@release, and the canonical ci.yml in docs/shared-ci.md, which has regressed twice. They
	are worth nothing if no workflow runs them, and for a while none did. See
	ktsu-dev/.github#39.

	This holds .github/workflows/script-tests.yml to the three things that make it a guard:
	it runs on pull requests and on pushes to main, it discovers the tests by glob rather
	than by a list someone has to keep up to date, and it fails on a non-zero exit code.

	Run with pwsh: ./scripts/tests/script-tests-workflow.tests.ps1
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:Root = Join-Path $PSScriptRoot '..' '..' | Resolve-Path
$script:WorkflowPath = Join-Path $script:Root '.github' 'workflows' 'script-tests.yml'
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

# Returns the lines nested under a given trigger inside the top-level `on:` mapping, or
# $null when the trigger is not declared at all.
function Get-TriggerBody {
	param([string[]]$Workflow, [string]$Trigger)

	# The `on:` mapping runs from its key to the next column-zero line.
	$on = [array]::IndexOf($Workflow, ($Workflow | Where-Object { $_ -match '^on:\s*$' } | Select-Object -First 1))
	if ($on -lt 0) { return $null }
	$block = @($Workflow | Select-Object -Skip ($on + 1))
	$end = [array]::IndexOf($block, ($block | Where-Object { $_ -match '^\S' } | Select-Object -First 1))
	if ($end -ge 0) { $block = @($block | Select-Object -First $end) }

	# The trigger's body runs from its key to the next sibling at the same indent.
	$key = "^  $([regex]::Escape($Trigger)):"
	$at = [array]::IndexOf($block, ($block | Where-Object { $_ -match $key } | Select-Object -First 1))
	if ($at -lt 0) { return $null }

	$body = @()
	foreach ($line in @($block | Select-Object -Skip ($at + 1))) {
		if ($line -match '^  \S') { break }
		if ($line.Trim()) { $body += $line }
	}
	return , $body
}

$workflow = if (Test-Path -LiteralPath $script:WorkflowPath) {
	Get-Content -LiteralPath $script:WorkflowPath
} else {
	$null
}

Test-Case -Name 'a workflow runs scripts/tests' -Assertion {
	if ($null -eq $workflow) { return ".github/workflows/script-tests.yml does not exist, so no CI runs these tests." }
}

if ($null -ne $workflow) {
	# A pull request is where a regression has to turn red; after merge it is already on
	# main and one promotion away from every repository.
	Test-Case -Name 'runs on every pull request' -Assertion {
		$body = Get-TriggerBody -Workflow $workflow -Trigger 'pull_request'
		if ($null -eq $body) { return 'pull_request is not a trigger.' }
		if ($body | Where-Object { $_ -match '\bpaths(-ignore)?:|\bbranches(-ignore)?:' }) {
			return "pull_request is filtered, so some pull requests skip the tests:`n      $($body -join "`n      ")"
		}
	}

	Test-Case -Name 'runs on push to main' -Assertion {
		$body = Get-TriggerBody -Workflow $workflow -Trigger 'push'
		if ($null -eq $body) { return 'push is not a trigger.' }
		if ($body | Where-Object { $_ -match '\bpaths(-ignore)?:' }) {
			return "push is path-filtered:`n      $($body -join "`n      ")"
		}
		$branches = $body | Where-Object { $_ -match 'branches:' }
		if ($branches -and -not ($branches | Where-Object { $_ -match '\bmain\b' })) {
			return "push is limited to branches that do not include main: $branches"
		}
	}

	# A hand-maintained list is how a new test file ends up never running.
	Test-Case -Name 'discovers tests by glob' -Assertion {
		if (-not ($workflow | Where-Object { $_ -match "scripts/tests" }) -or
			-not ($workflow | Where-Object { $_ -match "\*\.tests\.ps1" })) {
			return 'the workflow does not glob scripts/tests/*.tests.ps1.'
		}
	}

	# The test scripts report failure only through their exit code.
	Test-Case -Name 'fails on a non-zero exit code' -Assertion {
		if (-not ($workflow | Where-Object { $_ -match '\$LASTEXITCODE' })) {
			return 'the workflow never inspects $LASTEXITCODE, so a failing test file would not fail the job.'
		}
	}
}

Write-Host ''
if ($script:Failures -gt 0) {
	Write-Host "$script:Failures of $script:Count case(s) failed." -ForegroundColor Red
	exit 1
}

Write-Host "All $script:Count case(s) passed." -ForegroundColor Green
