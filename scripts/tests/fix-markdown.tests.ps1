<#
.SYNOPSIS
	Checks that fix-markdown.ps1 never rewrites a file itself.

.DESCRIPTION
	fix-markdown.ps1 used to fall back to its own regex rewrites when markdownlint was missing
	or exited non-zero, and those rewrites corrupted documents: every line became a hard break,
	code fences turned into a backtick and a tab, snake_case became emphasis and nested lists
	were flattened (ktsu-dev/.github#30). These cases pin the replacement behaviour: the only
	thing that changes a file is markdownlint, a missing markdownlint stops the run, and
	violations markdownlint cannot fix fail the run instead of being "fixed" some other way.

	markdownlint is replaced by a stub on PATH, so the cases need neither Node nor the network.
	The stubs are shell scripts, so this test runs on Linux and macOS.

	Run with pwsh: ./scripts/tests/fix-markdown.tests.ps1
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:Script = Join-Path $PSScriptRoot '..' 'fix-markdown.ps1' | Resolve-Path
$script:Pwsh = [System.Environment]::ProcessPath
$script:Failures = 0
$script:Count = 0

# A document every one of the old fallback's rewrites damaged: soft wraps (MD009), a bare fence
# (MD040), snake_case (MD049) and a nested list (MD004/MD007).
$script:Document = @'
# Sample

This paragraph wraps
onto a second line.

```
get_github_repos --org ktsu-dev
```

- parent
  - child

See get_github_repos and update_sdks.
'@ -replace "`r`n", "`n"

function New-Fixture {
	param([string]$Stub)

	$root = Join-Path ([System.IO.Path]::GetTempPath()) "fix-markdown-$([guid]::NewGuid())"
	$docs = Join-Path $root 'docs'
	$bin = Join-Path $root 'bin'
	New-Item -ItemType Directory -Path $docs, $bin | Out-Null

	Set-Content -LiteralPath (Join-Path $docs 'README.md') -Value $script:Document -NoNewline
	Set-Content -LiteralPath (Join-Path $docs '.markdownlint.json') -Value '{ "default": true }' -NoNewline

	if ($Stub) {
		$stubPath = Join-Path $bin 'markdownlint'
		Set-Content -LiteralPath $stubPath -Value "#!/bin/sh`n$Stub`n" -NoNewline
		chmod +x $stubPath
	}

	return [pscustomobject]@{
		Root = $root
		Docs = $docs
		Bin = $bin
		File = Join-Path $docs 'README.md'
		Args = Join-Path $root 'args.txt'
	}
}

# Runs the script with PATH holding only the fixture's bin folder, so a markdownlint installed on
# the machine running the test can't stand in for the stub.
function Invoke-FixMarkdown {
	param($Fixture)

	$savedPath = $env:PATH
	$savedArgs = $env:FIX_MARKDOWN_TEST_ARGS
	try {
		$env:PATH = $Fixture.Bin
		$env:FIX_MARKDOWN_TEST_ARGS = $Fixture.Args
		$output = & $script:Pwsh -NoProfile -NonInteractive -File $script:Script -rootDirectory $Fixture.Docs 2>&1 6>&1
		return [pscustomobject]@{ ExitCode = $LASTEXITCODE; Output = ($output | Out-String) }
	}
	finally {
		$env:PATH = $savedPath
		$env:FIX_MARKDOWN_TEST_ARGS = $savedArgs
	}
}

function Test-Case {
	param([string]$Name, [string]$Stub, [scriptblock]$Assertion)

	$script:Count++
	$fixture = New-Fixture -Stub $Stub
	try {
		$result = Invoke-FixMarkdown -Fixture $fixture
		$problem = & $Assertion $fixture $result
		if ($problem) {
			$script:Failures++
			Write-Host "FAIL  $Name" -ForegroundColor Red
			Write-Host "      $problem" -ForegroundColor Red
			Write-Host "      output: $($result.Output -replace "`n", "`n      ")" -ForegroundColor Red
			return
		}
		Write-Host "ok    $Name" -ForegroundColor Green
	}
	finally {
		Remove-Item -LiteralPath $fixture.Root -Recurse -Force
	}
}

function Get-Content-Raw {
	param([string]$Path)
	return [System.IO.File]::ReadAllText($Path)
}

Test-Case -Name 'a missing markdownlint fails the run and leaves the document untouched' -Stub $null -Assertion {
	param($f, $r)
	if ($r.ExitCode -eq 0) { return 'expected a non-zero exit when markdownlint is missing' }
	if ((Get-Content-Raw $f.File) -cne $script:Document) { return 'the document was rewritten without markdownlint' }
	if ($r.Output -notmatch 'markdownlint was not found') { return 'expected the run to say markdownlint is missing' }
}

# markdownlint --fix exits 1 whenever a violation it can't fix remains. That used to trigger the
# fallback; now it must leave the file as markdownlint left it and fail the run.
Test-Case -Name 'unfixable violations fail the run and leave the document as markdownlint left it' `
	-Stub 'echo "README.md:3 MD013/line-length Line length" >&2; exit 1' -Assertion {
	param($f, $r)
	if ($r.ExitCode -eq 0) { return 'expected a non-zero exit when markdownlint reports remaining violations' }
	if ((Get-Content-Raw $f.File) -cne $script:Document) { return 'the document was rewritten after markdownlint gave up' }
	if ($r.Output -notmatch 'MD013/line-length') { return "expected markdownlint's remaining violations in the output" }
}

# markdownlint fixes at most one violation per line in a pass: a `*` list straight after a
# paragraph gets MD004 fixed in the first pass and MD032 in the second (ktsu-dev/.github#58).
# The stub fixes one thing per call and reports the rest, as markdownlint does.
Test-Case -Name 'violations a second markdownlint pass fixes do not fail the run' `
	-Stub 'for last; do :; done; read -r l < "$last"; if [ "$l" = pass1 ]; then printf "fixed\n" > "$last"; exit 0; fi; printf "pass1\n" > "$last"; echo "README.md:4 MD032/blanks-around-lists" >&2; exit 1' -Assertion {
	param($f, $r)
	if ($r.ExitCode -ne 0) { return "expected exit 0 once a second pass fixed everything, got $($r.ExitCode)" }
	if ((Get-Content-Raw $f.File) -cne "fixed`n") { return "expected the second pass's fix to be kept" }
	if ($r.Output -match 'fix these by hand') { return 'violations the second pass fixed were reported as needing a fix by hand' }
	if ($r.Output -notmatch '1 files fixed') { return 'expected the changed file to be counted' }
}

# A pass that keeps changing the file but never comes clean must not loop forever.
Test-Case -Name 'repeated passes stop at the cap and the remaining violations fail the run' `
	-Stub 'for last; do :; done; printf "x" >> "$last"; printf "x\n" >> "$FIX_MARKDOWN_TEST_ARGS"; echo "README.md:3 MD013/line-length" >&2; exit 1' -Assertion {
	param($f, $r)
	if ($r.ExitCode -eq 0) { return 'expected a non-zero exit when violations remain after the last pass' }
	$passes = @(Get-Content -LiteralPath $f.Args).Count
	if ($passes -ne 5) { return "expected 5 markdownlint passes, got $passes" }
	if ($r.Output -notmatch 'MD013/line-length') { return "expected the last pass's violations in the output" }
}

Test-Case -Name 'a clean markdownlint run succeeds and reports the fix it made' `
	-Stub 'for last; do :; done; printf "fixed\n" > "$last"; exit 0' -Assertion {
	param($f, $r)
	if ($r.ExitCode -ne 0) { return "expected exit 0, got $($r.ExitCode)" }
	if ((Get-Content-Raw $f.File) -cne "fixed`n") { return "expected markdownlint's output to be kept" }
	if ($r.Output -notmatch '1 files fixed') { return 'expected the changed file to be counted' }
}

Test-Case -Name 'a file markdownlint leaves alone is counted as unchanged, not fixed' -Stub 'exit 0' -Assertion {
	param($f, $r)
	if ($r.ExitCode -ne 0) { return "expected exit 0, got $($r.ExitCode)" }
	if ($r.Output -notmatch '0 files fixed') { return 'an untouched file was reported as fixed' }
}

Test-Case -Name 'markdownlint gets --fix and the nearest config' `
	-Stub 'printf "%s\n" "$@" > "$FIX_MARKDOWN_TEST_ARGS"; exit 0' -Assertion {
	param($f, $r)
	$received = @(Get-Content -LiteralPath $f.Args)
	$expected = @('--fix', '--config', (Join-Path $f.Docs '.markdownlint.json'), '--', $f.File)
	if (($received -join '|') -cne ($expected -join '|')) {
		return "expected arguments '$($expected -join ' ')', got '$($received -join ' ')'"
	}
}

Write-Host ''
if ($script:Failures -gt 0) {
	Write-Host "$script:Failures of $script:Count case(s) failed." -ForegroundColor Red
	exit 1
}

Write-Host "All $script:Count case(s) passed." -ForegroundColor Green
