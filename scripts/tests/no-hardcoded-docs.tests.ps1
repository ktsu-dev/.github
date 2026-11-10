<#
.SYNOPSIS
	Checks that no script here rewrites or commits another repository's docs from hard-coded text.

.DESCRIPTION
	scripts/update-docs.ps1 wrote an April-2025 snapshot of each repository's description over its
	DESCRIPTION.md, filled its README with "Feature 1" placeholders, and committed both on whatever
	branch was checked out. README, DESCRIPTION and TAGS are now written per repository, from that
	repository's code, by the update-docs skill, so nothing in scripts/ should do it. See
	ktsu-dev/.github#53.

	This holds scripts/ to that: no script writes README.md or DESCRIPTION.md and also runs
	`git commit`, and CLAUDE.md lists no script that is not there.

	Run with pwsh: ./scripts/tests/no-hardcoded-docs.tests.ps1
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:Root = Join-Path $PSScriptRoot '..' '..' | Resolve-Path
$script:ScriptsPath = Join-Path $script:Root 'scripts'
$script:ClaudeMdPath = Join-Path $script:Root 'CLAUDE.md'
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

$scripts = @(Get-ChildItem -Path $script:ScriptsPath -File |
	Where-Object { $_.Extension -in '.ps1', '.py', '.sh' })

Test-Case -Name 'update-docs.ps1 is gone' -Assertion {
	if (Test-Path (Join-Path $script:ScriptsPath 'update-docs.ps1')) {
		return 'scripts/update-docs.ps1 still exists; it overwrites DESCRIPTION.md and README.md from a hard-coded table and commits them.'
	}
}

# A script that both writes a repository's README or DESCRIPTION and commits is the shape that
# shipped stale package descriptions. Writing docs locally for a person to review is fine.
Test-Case -Name 'no script writes README.md or DESCRIPTION.md and commits it' -Assertion {
	$offenders = @($scripts | Where-Object {
			$text = Get-Content -LiteralPath $_.FullName -Raw
			($text -match '(README|DESCRIPTION)\.md') -and
			($text -match '(Set-Content|Out-File|WriteAllText|>\s*)') -and
			($text -match 'git\s+commit')
		} | ForEach-Object { $_.Name })

	if ($offenders.Count -gt 0) {
		return "these scripts write README.md/DESCRIPTION.md and run git commit: $($offenders -join ', ')."
	}
}

# CLAUDE.md is what an agent reads before running anything here, so it must not point at a
# script that is gone, or describe one that is not listed.
Test-Case -Name 'CLAUDE.md lists only scripts that exist' -Assertion {
	$listed = @(Select-String -LiteralPath $script:ClaudeMdPath -Pattern '^- `([^`/]+\.(ps1|py|sh))`' |
		ForEach-Object { $_.Matches[0].Groups[1].Value })
	$missing = @($listed | Where-Object { -not (Test-Path (Join-Path $script:ScriptsPath $_)) })

	if ($missing.Count -gt 0) {
		return "CLAUDE.md lists scripts that are not in scripts/: $($missing -join ', ')."
	}
}

Write-Host ''
if ($script:Failures -gt 0) {
	Write-Host "$script:Failures of $script:Count case(s) failed." -ForegroundColor Red
	exit 1
}

Write-Host "All $script:Count case(s) passed." -ForegroundColor Green
