<#
.SYNOPSIS
	Runs ci-shared.yml's detect step against a stub gh and checks which tree it classifies.

.DESCRIPTION
	The detect job selects the .NET pipeline when the repository has the `dotnet` topic and a
	global.json. The global.json has to be looked for in the commit being built. Without a ref
	the Contents API answers for the default branch, so the pull request that adds global.json
	fails and the one that removes it passes (ktsu-dev/.github#38).

	The step's bash is taken from the workflow as written and run with a `gh` on PATH. The stub
	reports a public, non-fork repository with the `dotnet` topic. It has global.json only at
	the refs each case names, where `default` stands for a request that names no ref.

	Run with pwsh: ./scripts/tests/ci-shared-detect.tests.ps1
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:Workflow = Join-Path $PSScriptRoot '..' '..' '.github' 'workflows' 'ci-shared.yml' | Resolve-Path
$script:Failures = 0
$script:Count = 0
$script:Head = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'

# The detect step is the first `run: |` block in the file.
function Get-DetectScript {
	$lines = Get-Content -LiteralPath $script:Workflow
	$start = -1
	for ($i = 0; $i -lt $lines.Count; $i++) {
		if ($lines[$i] -match '^(\s*)run: \|\s*$') { $start = $i + 1; $indent = $Matches[1].Length; break }
	}
	if ($start -lt 0) { throw "No 'run: |' step in $script:Workflow." }

	$body = @()
	for ($i = $start; $i -lt $lines.Count; $i++) {
		$line = $lines[$i]
		if ($line.Trim() -and ($line.Length - $line.TrimStart().Length) -le $indent) { break }
		$body += if ($line.Length -gt $indent + 2) { $line.Substring($indent + 2) } else { $line.Trim() }
	}
	return ($body -join "`n") + "`n"
}

$stub = @'
#!/usr/bin/env bash
[ "$1" = "api" ] || { echo "stub gh: unexpected call: $*" >&2; exit 99; }
path="$2"
case "$path" in
  "repos/$GITHUB_REPOSITORY")
    printf '{"private":false,"fork":false,"topics":["dotnet"]}\n'; exit 0 ;;
  "repos/$GITHUB_REPOSITORY/contents/global.json"*)
    ref=default
    case "$path" in *"?ref="*) ref="${path#*\?ref=}" ;; esac
    for have in $STUB_GLOBAL_JSON_AT; do
      [ "$have" = "$ref" ] && exit 0
    done
    echo 'gh: Not Found (HTTP 404)' >&2; exit 1 ;;
esac
echo "stub gh: unexpected call: $*" >&2
exit 99
'@

function Invoke-Detect {
	param([string]$GlobalJsonAt)

	$dir = Join-Path ([System.IO.Path]::GetTempPath()) "ci-shared-detect-$([guid]::NewGuid())"
	New-Item -ItemType Directory -Path $dir | Out-Null
	$originalPath = $env:PATH
	try {
		$gh = Join-Path $dir 'gh'
		Set-Content -LiteralPath $gh -Value $stub -NoNewline
		chmod +x $gh
		$scriptPath = Join-Path $dir 'detect.sh'
		Set-Content -LiteralPath $scriptPath -Value (Get-DetectScript) -NoNewline
		$outputFile = Join-Path $dir 'github_output'
		New-Item -ItemType File -Path $outputFile | Out-Null

		$env:PATH = "$dir$([System.IO.Path]::PathSeparator)$originalPath"
		$env:GITHUB_REPOSITORY = 'ktsu-dev/Example'
		$env:GITHUB_OUTPUT = $outputFile
		$env:GH_TOKEN = 'unused'
		$env:BUILD_REF = $script:Head
		$env:STUB_GLOBAL_JSON_AT = $GlobalJsonAt

		$output = & bash $scriptPath 2>&1 | Out-String
		$code = $LASTEXITCODE
		$stack = (Get-Content -LiteralPath $outputFile | Where-Object { $_ -like 'stack=*' }) -replace '^stack=', ''
		return [pscustomobject]@{ Code = $code; Output = $output; Stack = "$stack" }
	}
	finally {
		$env:PATH = $originalPath
		Remove-Item -LiteralPath $dir -Recurse -Force -ErrorAction SilentlyContinue
	}
}

function Test-Case {
	param([string]$Name, [string]$GlobalJsonAt, [string]$ExpectedStack)

	$script:Count++
	$r = Invoke-Detect -GlobalJsonAt $GlobalJsonAt
	$problem = $null
	if ($ExpectedStack -and ($r.Code -ne 0 -or $r.Stack -ne $ExpectedStack)) {
		$problem = "expected stack=$ExpectedStack; got exit $($r.Code), stack '$($r.Stack)'."
	}
	elseif (-not $ExpectedStack -and $r.Code -eq 0) {
		$problem = "expected classification to fail; it selected '$($r.Stack)'."
	}

	if ($problem) {
		$script:Failures++
		Write-Host "FAIL  $Name" -ForegroundColor Red
		Write-Host "      $problem" -ForegroundColor Red
		Write-Host "      $($r.Output.Trim() -replace "`n", "`n      ")" -ForegroundColor Red
		return
	}
	Write-Host "ok    $Name" -ForegroundColor Green
}

Test-Case -Name 'a commit that has global.json, as the default branch does, is .NET' `
	-GlobalJsonAt "default $script:Head" -ExpectedStack 'dotnet'

# The onboarding pull request: it adds global.json, and the default branch does not have one yet.
Test-Case -Name 'a pull request that adds global.json is .NET' `
	-GlobalJsonAt $script:Head -ExpectedStack 'dotnet'

# The removal: the default branch still has global.json, the commit being built does not.
Test-Case -Name 'a pull request that removes global.json is not .NET' `
	-GlobalJsonAt 'default' -ExpectedStack ''

Write-Host ''
if ($script:Failures -gt 0) {
	Write-Host "$script:Failures of $script:Count case(s) failed." -ForegroundColor Red
	exit 1
}

Write-Host "All $script:Count case(s) passed." -ForegroundColor Green
