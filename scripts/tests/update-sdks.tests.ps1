<#
.SYNOPSIS
	Checks update-sdks.ps1 against the failures the workflow it replaces actually had.

.DESCRIPTION
	Every case here is a defect observed in the previous workflow against the real feed,
	not a hypothetical. Run with pwsh: ./scripts/tests/update-sdks.tests.ps1

	-Version is used throughout so the cases do not depend on the network or on which
	version happens to be current the day they run.
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:Script = Join-Path $PSScriptRoot '..' 'update-sdks.ps1' | Resolve-Path
$script:Failures = 0
$script:Count = 0

function New-Fixture {
	param([hashtable]$Files)

	$root = Join-Path ([System.IO.Path]::GetTempPath()) "update-sdks-$([guid]::NewGuid())"
	New-Item -ItemType Directory -Path $root | Out-Null
	foreach ($name in $Files.Keys) {
		$path = Join-Path $root $name
		New-Item -ItemType Directory -Path (Split-Path -Parent $path) -Force | Out-Null
		Set-Content -LiteralPath $path -Value $Files[$name] -NoNewline
	}
	return $root
}

function Test-Case {
	param([string]$Name, [hashtable]$Files, [string]$Version, [hashtable]$Expected)

	$script:Count++
	$root = New-Fixture -Files $Files
	try {
		& $script:Script -Path $root -Version $Version 6>$null | Out-Null

		foreach ($file in $Expected.Keys) {
			$actual = Get-Content -LiteralPath (Join-Path $root $file) -Raw
			if ($actual -ne $Expected[$file]) {
				$script:Failures++
				Write-Host "FAIL  $Name" -ForegroundColor Red
				Write-Host "      $file expected:" -ForegroundColor Red
				Write-Host "      $($Expected[$file] -replace "`n", "`n      ")" -ForegroundColor Red
				Write-Host "      actual:" -ForegroundColor Red
				Write-Host "      $($actual -replace "`n", "`n      ")" -ForegroundColor Red
				return
			}
		}

		Write-Host "ok    $Name" -ForegroundColor Green
	}
	finally {
		Remove-Item -LiteralPath $root -Recurse -Force
	}
}

# The bare ktsu.Sdk entry. "ktsu.Sdk" -like "ktsu.Sdk.*" is False and the old csproj pattern
# required a suffix, so the package nearly every repository pins was never tracked. VST, which
# pins only ktsu.Sdk, reported "No ktsu SDKs found" and sat on 2.8.0 while the org moved on.
Test-Case -Name 'the bare prefix package is tracked' -Version '2.29.0' `
	-Files @{ 'global.json' = '{"msbuild-sdks":{"ktsu.Sdk":"2.8.0"}}' } `
	-Expected @{ 'global.json' = '{"msbuild-sdks":{"ktsu.Sdk":"2.29.0"}}' }

# A package that merely starts with the prefix is not in the family.
Test-Case -Name 'an adjacent package name is left alone' -Version '2.29.0' `
	-Files @{ 'global.json' = '{"msbuild-sdks":{"ktsu.SdkAdjacent":"1.0.0","MSTest.Sdk":"4.4.0"}}' } `
	-Expected @{ 'global.json' = '{"msbuild-sdks":{"ktsu.SdkAdjacent":"1.0.0","MSTest.Sdk":"4.4.0"}}' }

# The headline requirement. A dependency update that bumps some entries and not others leaves
# the repository resolving two versions of the same SDK. The old code recorded the first
# version it saw per package and skipped the package entirely when that one was already
# current, so the stragglers stayed behind forever.
Test-Case -Name 'a partial bump is repaired even when one entry is already current' -Version '2.29.0' `
	-Files @{ 'global.json' = "{`n  `"msbuild-sdks`": {`n    `"ktsu.Sdk`": `"2.29.0`",`n    `"ktsu.Sdk.Tool`": `"2.25.0`",`n    `"ktsu.Sdk.App`": `"2.25.0`"`n  }`n}" } `
	-Expected @{ 'global.json' = "{`n  `"msbuild-sdks`": {`n    `"ktsu.Sdk`": `"2.29.0`",`n    `"ktsu.Sdk.Tool`": `"2.29.0`",`n    `"ktsu.Sdk.App`": `"2.29.0`"`n  }`n}" }

# The same disagreement across file kinds rather than within one file.
Test-Case -Name 'global.json and a csproj are converged on one version' -Version '2.29.0' `
	-Files @{
		'global.json' = '{"msbuild-sdks":{"ktsu.Sdk.Tool":"2.29.0"}}'
		'src/App/App.csproj' = '<Project Sdk="ktsu.Sdk.Tool/2.25.0"></Project>'
	} `
	-Expected @{
		'global.json' = '{"msbuild-sdks":{"ktsu.Sdk.Tool":"2.29.0"}}'
		'src/App/App.csproj' = '<Project Sdk="ktsu.Sdk.Tool/2.29.0"></Project>'
	}

# The old replacement pattern matched digits and dots only, so it rewrote the 2.0.0 inside
# 2.0.0-pre.1 and left the suffix dangling on a version that was never published.
Test-Case -Name 'a prerelease pin is replaced whole, not in part' -Version '2.29.0' `
	-Files @{ 'src/App/App.csproj' = '<Project Sdk="ktsu.Sdk.Tool/2.0.0-pre.1"></Project>' } `
	-Expected @{ 'src/App/App.csproj' = '<Project Sdk="ktsu.Sdk.Tool/2.29.0"></Project>' }

# Formatting, key order, unrelated entries and the trailing newline all survive, because the
# file is edited rather than re-serialized.
$formatted = "{`n  `"sdk`": { `"version`": `"10.0.100`" },`n  `"msbuild-sdks`": {`n    `"MSTest.Sdk`": `"4.4.0`",`n    `"ktsu.Sdk`": `"2.25.0`"`n  },`n  `"test`": { `"runner`": `"Microsoft.Testing.Platform`" }`n}`n"
Test-Case -Name 'unrelated content and formatting survive' -Version '2.29.0' `
	-Files @{ 'global.json' = $formatted } `
	-Expected @{ 'global.json' = $formatted.Replace('"ktsu.Sdk": "2.25.0"', '"ktsu.Sdk": "2.29.0"') }

# Nothing to do must write nothing at all, so a scheduled run on a current repository has an
# empty diff rather than a whitespace-only commit.
Test-Case -Name 'an already-current repository is untouched' -Version '2.29.0' `
	-Files @{ 'global.json' = "{`n  `"msbuild-sdks`": {`n    `"ktsu.Sdk`": `"2.29.0`"`n  }`n}`n" } `
	-Expected @{ 'global.json' = "{`n  `"msbuild-sdks`": {`n    `"ktsu.Sdk`": `"2.29.0`"`n  }`n}`n" }

Write-Host ''
if ($script:Failures -gt 0) {
	Write-Host "$script:Failures of $script:Count case(s) failed." -ForegroundColor Red
	exit 1
}

Write-Host "All $script:Count case(s) passed." -ForegroundColor Green
