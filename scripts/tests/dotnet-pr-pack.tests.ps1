<#
.SYNOPSIS
	Runs the Validate Package step of dotnet.yml against a stub dotnet and checks what it packs.

.DESCRIPTION
	Packing, and with it package validation, used to run only in the Release step, which a pull
	request never reaches. A Polyfill bump that broke `dotnet pack` was green on its PR, was
	auto-merged, and left about 19 repositories unreleasable. See ktsu-dev/.github#41.

	The step's pwsh is taken from the workflow as written and run in a fixture workspace with a
	`dotnet` on PATH that records each call and fails the pack of whichever project the case
	names. The workflow itself is also checked for where the step sits and what gates it.

	Run with pwsh: ./scripts/tests/dotnet-pr-pack.tests.ps1
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:Workflow = Join-Path $PSScriptRoot '..' '..' '.github' 'workflows' 'dotnet.yml' | Resolve-Path
$script:StepName = 'Validate Package'
$script:Failures = 0
$script:Count = 0

# The lines of one step: from its `- name:` to the next step at the same indent.
function Get-StepLines {
	param([string]$Name)

	$lines = Get-Content -LiteralPath $script:Workflow
	$start = -1
	for ($i = 0; $i -lt $lines.Count; $i++) {
		if ($lines[$i] -match "^(\s*)- name: $([regex]::Escape($Name))\s*$") { $start = $i; $indent = $Matches[1].Length; break }
	}
	if ($start -lt 0) { return $null }

	$body = @($lines[$start])
	for ($i = $start + 1; $i -lt $lines.Count; $i++) {
		$line = $lines[$i]
		if ($line.Trim() -and ($line.Length - $line.TrimStart().Length) -le $indent -and -not $line.TrimStart().StartsWith('#')) { break }
		$body += $line
	}
	return , $body
}

# The step's script is the block scalar under its `run: |`, indented deeper than the key.
function Get-StepScript {
	$step = Get-StepLines -Name $script:StepName
	if (-not $step) { throw "No '$script:StepName' step in $script:Workflow." }

	$start = -1
	for ($i = 0; $i -lt $step.Count; $i++) {
		if ($step[$i] -match '^(\s*)run: \|\s*$') { $start = $i + 1; $indent = $Matches[1].Length; break }
	}
	if ($start -lt 0) { throw "The '$script:StepName' step has no 'run: |' block." }

	$body = @()
	for ($i = $start; $i -lt $step.Count; $i++) {
		$line = $step[$i]
		if ($line.Trim() -and ($line.Length - $line.TrimStart().Length) -le $indent) { break }
		$body += if ($line.Length -gt $indent + 2) { $line.Substring($indent + 2) } else { $line.Trim() }
	}
	return ($body -join "`n") + "`n"
}

# A dotnet that appends each call to the log and fails a pack whose project path contains
# DOTNET_STUB_FAIL.
$stub = @'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$DOTNET_STUB_LOG"
if [[ -n "$DOTNET_STUB_FAIL" && "$1" == "pack" && "$2" == *"$DOTNET_STUB_FAIL"* ]]; then
  echo "error CP0015: Cannot change arguments of attribute 'System.Runtime.CompilerServices.NullableContextAttribute'" >&2
  exit 1
fi
exit 0
'@

$fixture = @{
	'Widget.slnx'                         = '<Solution />'
	'Widget/Widget.csproj'                = '<Project Sdk="ktsu.Sdk"><PropertyGroup><TargetFrameworks>net10.0;net9.0</TargetFrameworks></PropertyGroup></Project>'
	'Widget.Core/Widget.Core.csproj'      = '<Project Sdk="ktsu.Sdk"></Project>'
	'Widget.Test/Widget.Test.csproj'      = '<Project Sdk="MSTest.Sdk"></Project>'
	'Checks/Checks.csproj'                = '<Project Sdk="Microsoft.NET.Sdk"><ItemGroup><PackageReference Include="Microsoft.NET.Test.Sdk" /></ItemGroup></Project>'
	'Widget.Demo/Widget.Demo.csproj'      = '<Project Sdk="ktsu.Sdk.App"></Project>'
	'examples/Gallery/Gallery.csproj'     = '<Project Sdk="ktsu.Sdk.App"></Project>'
	'Widget.Mobile/Widget.Mobile.csproj'  = '<Project Sdk="ktsu.Sdk"><PropertyGroup><TargetFramework>net10.0-ios</TargetFramework></PropertyGroup></Project>'
}

function Invoke-PackStep {
	param([string]$Fail, [hashtable]$Files = $fixture)

	$dir = Join-Path ([System.IO.Path]::GetTempPath()) "dotnet-pr-pack-$([guid]::NewGuid())"
	$workspace = Join-Path $dir 'workspace'
	$bin = Join-Path $dir 'bin'
	$temp = Join-Path $dir 'temp'
	New-Item -ItemType Directory -Path $workspace, $bin, $temp | Out-Null
	try {
		foreach ($path in $Files.Keys) {
			$full = Join-Path $workspace $path
			New-Item -ItemType Directory -Path (Split-Path $full) -Force | Out-Null
			Set-Content -LiteralPath $full -Value $Files[$path] -NoNewline
		}

		$dotnet = Join-Path $bin 'dotnet'
		Set-Content -LiteralPath $dotnet -Value $stub -NoNewline
		chmod +x $dotnet
		$scriptPath = Join-Path $dir 'step.ps1'
		Set-Content -LiteralPath $scriptPath -Value (Get-StepScript) -NoNewline
		$log = Join-Path $dir 'dotnet.log'

		$env:PATH = "$bin$([System.IO.Path]::PathSeparator)$script:OriginalPath"
		$env:DOTNET_STUB_LOG = $log
		$env:DOTNET_STUB_FAIL = $Fail
		$env:GITHUB_WORKSPACE = $workspace
		$env:RUNNER_TEMP = $temp

		$output = & pwsh -NoProfile -NonInteractive -File $scriptPath 2>&1 | Out-String
		$code = $LASTEXITCODE
		$calls = @(if (Test-Path -LiteralPath $log) { Get-Content -LiteralPath $log })
		return [pscustomobject]@{ Code = $code; Output = $output; Calls = [string[]]$calls; Workspace = $workspace; Temp = $temp }
	}
	finally {
		$env:PATH = $script:OriginalPath
		Remove-Item Env:DOTNET_STUB_LOG, Env:DOTNET_STUB_FAIL, Env:GITHUB_WORKSPACE, Env:RUNNER_TEMP -ErrorAction SilentlyContinue
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

$script:OriginalPath = $env:PATH

Test-Case -Name 'a pull request run packs, after the build and before Release' -Assertion {
	$lines = Get-Content -LiteralPath $script:Workflow
	$pipeline = [array]::FindIndex($lines, [Predicate[string]] { param($l) $l -match '^\s*- name: Run KtsuBuild Pipeline\s*$' })
	$pack = [array]::FindIndex($lines, [Predicate[string]] { param($l) $l -match "^\s*- name: $script:StepName\s*$" })
	$release = [array]::FindIndex($lines, [Predicate[string]] { param($l) $l -match '^\s*- name: Release\s*$' })
	if ($pack -lt 0) { return "dotnet.yml has no '$script:StepName' step, so a pull request never runs dotnet pack." }
	if (-not ($pipeline -lt $pack -and $pack -lt $release)) { return "the step must sit after 'Run KtsuBuild Pipeline', which builds what it packs with --no-build, and before 'Release'." }

	$step = (Get-StepLines -Name $script:StepName) -join "`n"
	if ($step -notmatch "if:.*github\.event_name == 'pull_request'") { return "the step is not gated on pull_request, so it would pack a second time on main." }
	if ($step -notmatch "if:.*steps\.pipeline\.outputs\.build_skipped != 'true'") { return "the step would pack a build the pipeline skipped." }
	if ($step -match 'secrets\.|nuget push|ktsubuild release|git tag') { return "the step can publish or tag; a pull request run must do neither." }
}

$run = Invoke-PackStep

Test-Case -Name 'packs every deliverable with --no-build in Release, into a folder outside the workspace' -Assertion {
	if ($run.Code -ne 0) { return "a clean pack failed the step (exit $($run.Code)): $($run.Output.Trim())" }
	$packs = @($run.Calls | Where-Object { $_ -like 'pack *' })
	$packed = @($packs | ForEach-Object { [System.IO.Path]::GetFileNameWithoutExtension(($_ -split ' ')[1]) } | Sort-Object)
	if (($packed -join ',') -ne 'Widget,Widget.Core') { return "expected Widget and Widget.Core to be packed, got: $($packed -join ', ')" }
	foreach ($call in $packs) {
		if ($call -notmatch '--configuration Release') { return "not packed in Release, as the release packs: $call" }
		if ($call -notmatch '--no-build') { return "packed without --no-build, so it is not the build the pipeline validated: $call" }
		if ($call -notmatch "--output $([regex]::Escape((Join-Path $run.Temp 'pr-pack')))") { return "not packed into RUNNER_TEMP: $call" }
		if ($call -notmatch "-p:SolutionDir=$([regex]::Escape($run.Workspace))/") { return "packed without SolutionDir, which ktsu.Sdk reads package metadata from: $call" }
		if ($call -notmatch '-p:SolutionName=Widget') { return "packed without SolutionName: $call" }
	}
}

Test-Case -Name 'skips tests, demos, examples and iOS-only projects, as the release does' -Assertion {
	foreach ($skipped in 'Widget.Test', 'Checks', 'Widget.Demo', 'Gallery', 'Widget.Mobile') {
		if (@($run.Calls | Where-Object { $_ -like "*$skipped.csproj*" }).Count -gt 0) { return "$skipped was packed, but ktsubuild release does not pack it." }
	}
}

Test-Case -Name 'a pack that fails package validation fails the step and names the project' -Assertion {
	$r = Invoke-PackStep -Fail 'Widget.Core'
	if ($r.Code -eq 0) { return "a failing pack passed the step, so the pull request stays green." }
	if ($r.Output -notmatch 'Widget\.Core') { return "the failure does not name the project: $($r.Output.Trim())" }
	if (@($r.Calls | Where-Object { $_ -like 'pack *Widget.csproj*' }).Count -ne 1) { return "a failure stopped the other projects from being packed, so one run would not report them all." }
}

Test-Case -Name 'a repository with nothing to pack passes' -Assertion {
	$r = Invoke-PackStep -Files @{ 'App.Demo/App.Demo.csproj' = '<Project Sdk="ktsu.Sdk.App"></Project>' }
	if ($r.Code -ne 0) { return "nothing to pack failed the step: $($r.Output.Trim())" }
	if ($r.Calls.Count -ne 0) { return "dotnet was called with nothing to pack: $($r.Calls -join '; ')" }
}

Write-Host ''
if ($script:Failures -gt 0) {
	Write-Host "$script:Failures of $script:Count case(s) failed." -ForegroundColor Red
	exit 1
}
Write-Host "All $script:Count case(s) passed." -ForegroundColor Green
