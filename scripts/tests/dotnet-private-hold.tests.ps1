<#
.SYNOPSIS
	Runs dotnet-private.yml's pipeline step against a stub ktsubuild and checks the release hold.

.DESCRIPTION
	ci-shared.yml sends every private .NET repository to dotnet-private.yml. That file started as
	ImageGui's own workflow and held its releases unconditionally: it ran `ktsubuild build` and
	wrote should_release=false whatever the repository, so no private repository ever released and
	every run was green (ktsu-dev/.github#37).

	The hold is now opt-in through the repository variable KTSU_RELEASE_HOLD. The step's PowerShell
	is taken from the workflow as written and run with a `ktsubuild` on PATH that records what it
	was asked to do and, for `ci`, writes the step outputs the real tool writes.

	Run with pwsh: ./scripts/tests/dotnet-private-hold.tests.ps1
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:Workflow = Join-Path $PSScriptRoot '..' '..' '.github' 'workflows' 'dotnet-private.yml' | Resolve-Path
$script:Failures = 0
$script:Count = 0

# The lines of the named step, from its `- name:` up to the next step or job.
function Get-StepLines {
	param([string]$Name)

	$lines = Get-Content -LiteralPath $script:Workflow
	$start = -1
	for ($i = 0; $i -lt $lines.Count; $i++) {
		if ($lines[$i] -match "^(\s*)- name: $([regex]::Escape($Name))\s*$") { $start = $i; $indent = $Matches[1].Length; break }
	}
	if ($start -lt 0) { throw "No step named '$Name' in $script:Workflow." }

	$step = @($lines[$start])
	for ($i = $start + 1; $i -lt $lines.Count; $i++) {
		$line = $lines[$i]
		if ($line.Trim() -and ($line.Length - $line.TrimStart().Length) -le $indent) { break }
		$step += $line
	}
	return $step
}

function Get-PipelineScript {
	$step = Get-StepLines -Name 'Run KtsuBuild CI Pipeline'
	$start = -1
	for ($i = 0; $i -lt $step.Count; $i++) {
		if ($step[$i] -match '^(\s*)run: \|\s*$') { $start = $i + 1; $indent = $Matches[1].Length; break }
	}
	if ($start -lt 0) { throw "The pipeline step has no 'run: |' block." }

	$body = @()
	for ($i = $start; $i -lt $step.Count; $i++) {
		$line = $step[$i]
		if ($line.Trim() -and ($line.Length - $line.TrimStart().Length) -le $indent) { break }
		$body += if ($line.Length -gt $indent + 2) { $line.Substring($indent + 2) } else { $line.Trim() }
	}
	return ($body -join "`n") + "`n"
}

# The step's env block, as name => expression.
function Get-PipelineEnv {
	$step = Get-StepLines -Name 'Run KtsuBuild CI Pipeline'
	$env = @{}
	$inEnv = $false
	foreach ($line in $step) {
		if ($line -match '^\s*env:\s*$') { $inEnv = $true; continue }
		if ($inEnv) {
			if ($line -match '^\s*run:') { break }
			if ($line -match '^\s+([A-Z_]+):\s*(.+?)\s*$') { $env[$Matches[1]] = $Matches[2] }
		}
	}
	return $env
}

$stub = @'
$record = $args -join ' '
Add-Content -LiteralPath $env:STUB_CALLS -Value $record
if ($args[0] -eq 'ci') {
	"version=9.9.9" >> $env:GITHUB_OUTPUT
	"release_hash=from-ci" >> $env:GITHUB_OUTPUT
	"should_release=true" >> $env:GITHUB_OUTPUT
}
exit 0
'@

function Invoke-Pipeline {
	param([string]$Hold, [string]$VersionBump = 'auto')

	$dir = Join-Path ([System.IO.Path]::GetTempPath()) "dotnet-private-hold-$([guid]::NewGuid())"
	$workspace = Join-Path $dir 'workspace'
	New-Item -ItemType Directory -Path $workspace -Force | Out-Null
	$originalPath = $env:PATH
	$saved = @{}
	foreach ($name in 'RELEASE_HOLD', 'VERSION_BUMP', 'GITHUB_OUTPUT', 'STUB_CALLS') { $saved[$name] = [Environment]::GetEnvironmentVariable($name) }
	try {
		Set-Content -LiteralPath (Join-Path $dir 'ktsubuild.ps1') -Value $stub -NoNewline
		Set-Content -LiteralPath (Join-Path $workspace 'VERSION.md') -Value "1.2.3`n" -NoNewline
		git -C $workspace init -q 2>&1 | Out-Null
		git -C $workspace -c user.name=t -c user.email=t@example.com commit -q --allow-empty -m init 2>&1 | Out-Null
		$head = (git -C $workspace rev-parse HEAD).Trim()

		$script = (Get-PipelineScript).Replace('${{ github.workspace }}', $workspace).Replace('${{ inputs.version-bump }}', $VersionBump)
		$scriptPath = Join-Path $dir 'pipeline.ps1'
		Set-Content -LiteralPath $scriptPath -Value $script -NoNewline

		$outputFile = Join-Path $dir 'github_output'
		$callsFile = Join-Path $dir 'calls'
		New-Item -ItemType File -Path $outputFile, $callsFile | Out-Null

		$env:PATH = "$dir$([System.IO.Path]::PathSeparator)$originalPath"
		$env:RELEASE_HOLD = $Hold
		$env:VERSION_BUMP = $VersionBump
		$env:GITHUB_OUTPUT = $outputFile
		$env:STUB_CALLS = $callsFile

		Push-Location $workspace
		try { $output = & pwsh -NoProfile -NonInteractive -File $scriptPath 2>&1 | Out-String; $code = $LASTEXITCODE }
		finally { Pop-Location }

		$outputs = @{}
		foreach ($line in Get-Content -LiteralPath $outputFile) {
			$key, $value = $line -split '=', 2
			$outputs[$key] = $value # The last write wins, as it does on a runner.
		}
		return [pscustomobject]@{
			Code    = $code
			Output  = $output
			Calls   = @(Get-Content -LiteralPath $callsFile)
			Outputs = $outputs
			Head    = $head
		}
	}
	finally {
		$env:PATH = $originalPath
		foreach ($name in $saved.Keys) { [Environment]::SetEnvironmentVariable($name, $saved[$name]) }
		Remove-Item -LiteralPath $dir -Recurse -Force -ErrorAction SilentlyContinue
	}
}

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

function Get-RunProblem {
	param($Run, [string]$ExpectedCall, [string]$ExpectedShouldRelease)

	if ($Run.Code -ne 0) { return "the step exited $($Run.Code): $($Run.Output.Trim())" }
	if ($Run.Calls.Count -ne 1 -or $Run.Calls[0] -notlike "$ExpectedCall*") {
		return "expected one 'ktsubuild $ExpectedCall ...' call; got: $($Run.Calls -join ' | ')"
	}
	$shouldRelease = $Run.Outputs['should_release']
	if ($shouldRelease -ne $ExpectedShouldRelease) {
		return "expected should_release=$ExpectedShouldRelease; got '$shouldRelease'."
	}
	return $null
}

Test-Case 'a private repository without KTSU_RELEASE_HOLD runs the full ci pipeline and releases' {
	$r = Invoke-Pipeline -Hold ''
	Get-RunProblem -Run $r -ExpectedCall 'ci --workspace' -ExpectedShouldRelease 'true'
}

Test-Case 'KTSU_RELEASE_HOLD=false releases' {
	$r = Invoke-Pipeline -Hold 'false'
	Get-RunProblem -Run $r -ExpectedCall 'ci --workspace' -ExpectedShouldRelease 'true'
}

Test-Case 'KTSU_RELEASE_HOLD=true builds only and reports no release' {
	$r = Invoke-Pipeline -Hold 'true'
	$problem = Get-RunProblem -Run $r -ExpectedCall 'build --workspace' -ExpectedShouldRelease 'false'
	if ($problem) { return $problem }
	if ($r.Outputs['version'] -ne '1.2.3') { return "expected version=1.2.3 from VERSION.md; got '$($r.Outputs['version'])'." }
	if ($r.Outputs['release_hash'] -ne $r.Head) { return "expected release_hash=$($r.Head); got '$($r.Outputs['release_hash'])'." }
	if ($r.Output -notmatch 'title=Release held') { return 'a held run posts no "Release held" notice, so its green check reads as a release.' }
}

Test-Case 'a forced version bump is forwarded to ci' {
	$r = Invoke-Pipeline -Hold '' -VersionBump 'minor'
	if ($r.Calls.Count -ne 1 -or $r.Calls[0] -notmatch '^ci .*--version-bump minor$') { return "got: $($r.Calls -join ' | ')" }
}

Test-Case 'a forced version bump is forwarded to a held build' {
	$r = Invoke-Pipeline -Hold 'true' -VersionBump 'major'
	if ($r.Calls.Count -ne 1 -or $r.Calls[0] -notmatch '^build .*--version-bump major$') { return "got: $($r.Calls -join ' | ')" }
}

Test-Case 'the hold reads the KTSU_RELEASE_HOLD repository variable' {
	$env = Get-PipelineEnv
	if ($env['RELEASE_HOLD'] -ne '${{ vars.KTSU_RELEASE_HOLD }}') { return "RELEASE_HOLD is '$($env['RELEASE_HOLD'])'." }
}

Test-Case 'the pipeline step is given the publishing credentials' {
	$env = Get-PipelineEnv
	foreach ($pair in @(@('NUGET_API_KEY', '${{ secrets.NUGET_KEY }}'), @('KTSU_PACKAGE_KEY', '${{ secrets.KTSU_PACKAGE_KEY }}'))) {
		if ($env[$pair[0]] -ne $pair[1]) { return "$($pair[0]) is '$($env[$pair[0]])', expected '$($pair[1])'." }
	}
}

Test-Case 'the build job may publish packages' {
	$text = Get-Content -LiteralPath $script:Workflow -Raw
	$job = [regex]::Match($text, '(?ms)^  build:\r?\n.*?^    steps:')
	if (-not $job.Success) { return 'no build job found.' }
	if ($job.Value -notmatch '(?m)^\s+packages:\s*write\b') { return 'the build job does not grant packages: write.' }
}

Test-Case 'the workflow no longer describes itself as one repository''s own' {
	$text = Get-Content -LiteralPath $script:Workflow -Raw
	if ($text -match 'ImageGui') { return 'the workflow still names ImageGui.' }
}

Write-Host ''
if ($script:Failures -gt 0) {
	Write-Host "$script:Failures of $script:Count case(s) failed." -ForegroundColor Red
	exit 1
}

Write-Host "All $script:Count case(s) passed." -ForegroundColor Green
