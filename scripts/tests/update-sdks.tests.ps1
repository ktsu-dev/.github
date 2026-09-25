<#
.SYNOPSIS
	Checks update-sdks.ps1 against the failures the workflow it replaces actually had.

.DESCRIPTION
	Every case here is a defect observed in the previous workflow against the real feed,
	not a hypothetical. Run with pwsh: ./scripts/tests/update-sdks.tests.ps1

	-Version is used for the rewriting cases so they do not depend on the network or on which
	version happens to be current the day they run. The resolution cases deliberately omit it,
	because that is the only path that calls the feed at all, and they point the script at a
	closed port or at an in-process stub feed rather than at nuget.org.
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

# A flat container index, served in process. The feed is the only thing the resolution path
# touches that the rewriting cases never reach, so it is the only thing that has to be faked.
# Versions maps a lower-case package id -- the flat container addresses packages in lower case --
# to the versions it publishes, and an id that is absent is answered with 404 so a lookup
# failure and a package with no release can both be provoked in one run.
function Start-StubFeed {
	param([hashtable]$Versions)

	$listener = [System.Net.HttpListener]::new()
	$port = 0
	foreach ($candidate in 18080..18179) {
		try {
			$listener.Prefixes.Clear()
			$listener.Prefixes.Add("http://127.0.0.1:$candidate/")
			$listener.Start()
			$port = $candidate
			break
		}
		catch {
			# The port is taken. Try the next one.
		}
	}

	if ($port -eq 0) {
		throw 'No free port in 18080-18179 for the stub feed.'
	}

	$job = Start-ThreadJob -ScriptBlock {
		param($Listener, $Map)

		try {
			while ($Listener.IsListening) {
				$context = $Listener.GetContext()
				# /<id>/index.json
				$id = $context.Request.Url.Segments[1].TrimEnd('/')

				if ($Map.ContainsKey($id)) {
					$body = '{"versions":["' + ($Map[$id] -join '","') + '"]}'
					$bytes = [System.Text.Encoding]::UTF8.GetBytes($body)
					$context.Response.ContentType = 'application/json'
					$context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
				}
				else {
					$context.Response.StatusCode = 404
				}

				$context.Response.Close()
			}
		}
		catch {
			# Stopping the listener is how this loop ends.
		}
	} -ArgumentList $listener, $Versions

	return [pscustomobject]@{ Listener = $listener; Job = $job; Url = "http://127.0.0.1:$port" }
}

function Stop-StubFeed {
	param($Feed)

	$Feed.Listener.Stop()
	$Feed.Listener.Close()
	Remove-Job -Job $Feed.Job -Force
}

# The resolution path fails the run rather than rewriting anything, so these cases assert on the
# message the run fails with and on the fixture being left alone, not on a rewritten file.
function Test-ResolutionFailure {
	param([string]$Name, [hashtable]$Files, [string]$FeedUrl, [string[]]$Reports, [hashtable]$Unchanged)

	$script:Count++
	$root = New-Fixture -Files $Files
	try {
		$message = $null
		try {
			& $script:Script -Path $root -FeedUrl $FeedUrl 6>$null 2>$null | Out-Null
		}
		catch {
			$message = $_.Exception.Message
		}

		if ($null -eq $message) {
			$script:Failures++
			Write-Host "FAIL  $Name" -ForegroundColor Red
			Write-Host '      the run was expected to fail, and did not.' -ForegroundColor Red
			return
		}

		$missing = @($Reports | Where-Object { $message -notlike "*$_*" })
		if ($missing.Count -gt 0) {
			$script:Failures++
			Write-Host "FAIL  $Name" -ForegroundColor Red
			Write-Host "      the failure never named: $($missing -join ', ')" -ForegroundColor Red
			Write-Host "      it said: $message" -ForegroundColor Red
			return
		}

		if ($Unchanged) {
			foreach ($file in $Unchanged.Keys) {
				$actual = Get-Content -LiteralPath (Join-Path $root $file) -Raw
				if ($actual -ne $Unchanged[$file]) {
					$script:Failures++
					Write-Host "FAIL  $Name" -ForegroundColor Red
					Write-Host "      $file was written despite the failure:" -ForegroundColor Red
					Write-Host "      $actual" -ForegroundColor Red
					return
				}
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

# $ErrorActionPreference is Stop inside the script, which makes a bare Write-Error terminating.
# The first unresolvable package therefore threw out of the script and the `continue` beneath it
# never ran, so a maintainer saw one failure per run: fix it, rerun, discover the next. The
# packages are grouped alphabetically, so ktsu.Sdk failing used to hide the other two entirely.
$threePackages = '{"msbuild-sdks":{"ktsu.Sdk":"1.0.0","ktsu.Sdk.App":"1.0.0","ktsu.Sdk.Tool":"1.0.0"}}'
Test-ResolutionFailure -Name 'every unresolvable package is reported, not just the first' `
	-Files @{ 'global.json' = $threePackages } `
	-FeedUrl 'http://127.0.0.1:9' `
	-Reports @('ktsu.Sdk.App', 'ktsu.Sdk.Tool') `
	-Unchanged @{ 'global.json' = $threePackages }

# The same defect on the other branch, and the reason the run must fail before it writes. Here
# ktsu.Sdk resolves to a version the fixture is behind, so a fix that reported the failures and
# carried on would converge that one reference and leave the other two pinned to 1.0.0 -- the
# partially applied state this script exists to repair. ktsu.Sdk.App 404s (the catch branch) and
# ktsu.Sdk.Tool publishes only a prerelease (the "no released version" branch).
$mixed = '{"msbuild-sdks":{"ktsu.Sdk":"1.0.0","ktsu.Sdk.App":"1.0.0","ktsu.Sdk.Tool":"1.0.0"}}'
$feed = Start-StubFeed -Versions @{ 'ktsu.sdk' = @('2.29.0'); 'ktsu.sdk.tool' = @('1.0.0-pre.1') }
try {
	Test-ResolutionFailure -Name 'a resolvable package neither hides a failure nor is written past one' `
		-Files @{ 'global.json' = $mixed } `
		-FeedUrl $feed.Url `
		-Reports @('ktsu.Sdk.App', 'ktsu.Sdk.Tool') `
		-Unchanged @{ 'global.json' = $mixed }
}
finally {
	Stop-StubFeed -Feed $feed
}

Write-Host ''
if ($script:Failures -gt 0) {
	Write-Host "$script:Failures of $script:Count case(s) failed." -ForegroundColor Red
	exit 1
}

Write-Host "All $script:Count case(s) passed." -ForegroundColor Green
