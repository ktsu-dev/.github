<#
.SYNOPSIS
	Checks the promote-release guard that every pipeline ci-shared.yml dispatches to exists.

.DESCRIPTION
	promote-release.yml runs scripts/check-release-pipelines.py before it moves the `release`
	tag. After ci-shared.yml switched to absolute `uses:` references, the old inline check
	skipped every job and always passed (ktsu-dev/.github#29). Each case builds a throwaway git
	repository holding a ci-shared.yml and the pipelines it should or should not find, then runs
	the script against its HEAD.

	Run with pwsh: ./scripts/tests/check-release-pipelines.tests.ps1
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:Script = Join-Path $PSScriptRoot '..' 'check-release-pipelines.py' | Resolve-Path
$script:Failures = 0
$script:Count = 0

function New-Dispatcher {
	param([string[]]$Uses)
	$jobs = for ($i = 0; $i -lt $Uses.Count; $i++) {
		"  job$($i):`n    uses: $($Uses[$i])`n"
	}
	return "on: workflow_call`njobs:`n  detect:`n    runs-on: ubuntu-latest`n    steps:`n      - uses: actions/checkout@v5`n$($jobs -join '')"
}

function Invoke-Check {
	param([hashtable]$Files)

	$root = Join-Path ([System.IO.Path]::GetTempPath()) "check-release-$([guid]::NewGuid())"
	New-Item -ItemType Directory -Path $root | Out-Null
	try {
		foreach ($name in $Files.Keys) {
			$path = Join-Path $root $name
			New-Item -ItemType Directory -Path (Split-Path -Parent $path) -Force | Out-Null
			Set-Content -LiteralPath $path -Value $Files[$name] -NoNewline
		}
		Push-Location $root
		try {
			git init -q . 2>&1 | Out-Null
			git add -A 2>&1 | Out-Null
			git -c user.name=test -c user.email=test@example.invalid -c commit.gpgsign=false commit -q -m fixture 2>&1 | Out-Null
			$sha = (git rev-parse HEAD).Trim()
			$output = & python3 $script:Script $sha 2>&1 | Out-String
			return [pscustomobject]@{ Code = $LASTEXITCODE; Output = $output }
		}
		finally { Pop-Location }
	}
	finally {
		Remove-Item -LiteralPath $root -Recurse -Force -ErrorAction SilentlyContinue
	}
}

function Test-Case {
	param([string]$Name, [hashtable]$Files, [bool]$ShouldPass, [string]$Mentions)

	$script:Count++
	$r = Invoke-Check -Files $Files
	$problem = $null
	if ($ShouldPass -and $r.Code -ne 0) { $problem = "expected the check to pass; it exited $($r.Code)." }
	elseif (-not $ShouldPass -and $r.Code -eq 0) { $problem = 'expected the check to fail; it passed.' }
	elseif ($Mentions -and $r.Output -notmatch [regex]::Escape($Mentions)) { $problem = "the output does not mention '$Mentions'." }

	if ($problem) {
		$script:Failures++
		Write-Host "FAIL  $Name" -ForegroundColor Red
		Write-Host "      $problem" -ForegroundColor Red
		Write-Host "      $($r.Output.Trim() -replace "`n", "`n      ")" -ForegroundColor Red
		return
	}
	Write-Host "ok    $Name" -ForegroundColor Green
}

$dispatcher = '.github/workflows/ci-shared.yml'
$public = '.github/workflows/dotnet.yml'
$private = '.github/workflows/dotnet-private.yml'
$absolute = @(
	'ktsu-dev/.github/.github/workflows/dotnet.yml@release',
	'ktsu-dev/.github/.github/workflows/dotnet-private.yml@release'
)

Test-Case -Name 'absolute @release references that exist pass, and are counted' -ShouldPass $true -Mentions '2 pipeline(s)' -Files @{
	$dispatcher = New-Dispatcher $absolute
	$public = 'on: workflow_call'
	$private = 'on: workflow_call'
}

# The acceptance criterion from #29: deleting dotnet.yml must fail the promotion and name it.
Test-Case -Name 'a deleted pipeline behind an absolute reference fails and is named' -ShouldPass $false -Mentions 'dotnet.yml' -Files @{
	$dispatcher = New-Dispatcher $absolute
	$private = 'on: workflow_call'
}

Test-Case -Name 'a relative ./ reference is still resolved' -ShouldPass $false -Mentions 'dotnet.yml' -Files @{
	$dispatcher = New-Dispatcher @('./.github/workflows/dotnet.yml')
}

Test-Case -Name 'a reference to this repository at another ref fails' -ShouldPass $false -Mentions '@main' -Files @{
	$dispatcher = New-Dispatcher @('ktsu-dev/.github/.github/workflows/dotnet.yml@main')
	$public = 'on: workflow_call'
}

Test-Case -Name 'a reference to another repository fails' -ShouldPass $false -Mentions 'ktsu-dev/Other' -Files @{
	$dispatcher = New-Dispatcher @('ktsu-dev/Other/.github/workflows/dotnet.yml@release')
	$public = 'on: workflow_call'
}

Test-Case -Name 'a dispatcher that dispatches to nothing fails rather than passing vacuously' -ShouldPass $false -Mentions 'nothing' -Files @{
	$dispatcher = New-Dispatcher @()
}

Test-Case -Name 'a commit without ci-shared.yml fails' -ShouldPass $false -Mentions 'ci-shared.yml' -Files @{
	'README.md' = 'no dispatcher here'
}

# The workflow passes `git rev-parse` output; anything that is not a full SHA is refused
# before it reaches git, where a leading "-" would be read as an option.
$script:Count++
$r = & python3 $script:Script '--output=/tmp/x' 2>&1 | Out-String
if ($LASTEXITCODE -eq 0 -or $r -notmatch 'not a full commit SHA') {
	$script:Failures++
	Write-Host "FAIL  an argument that is not a full SHA is refused" -ForegroundColor Red
	Write-Host "      exit $LASTEXITCODE; $($r.Trim())" -ForegroundColor Red
} else {
	Write-Host "ok    an argument that is not a full SHA is refused" -ForegroundColor Green
}

Write-Host ''
if ($script:Failures -gt 0) {
	Write-Host "$script:Failures of $script:Count case(s) failed." -ForegroundColor Red
	exit 1
}

Write-Host "All $script:Count case(s) passed." -ForegroundColor Green
