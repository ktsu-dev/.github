<#
.SYNOPSIS
	Runs the merge step of dependabot-merge.yml against a stub gh and checks what it merges.

.DESCRIPTION
	The step finds the pull request whose head is the commit CI reported on, reads every
	check run on that commit, and merges. The head can move between the lookup and the merge,
	so the merge has to name the commit that was checked, or GitHub merges whatever the head
	is by then. See ktsu-dev/.github#40.

	The step's bash is taken from the workflow as written and run with a `gh` on PATH that
	answers the lookup and check-run calls, records the merge call, and answers it the way the
	case asks: accepted, refused with 409 because the head moved, or refused for another reason.

	Run with pwsh: ./scripts/tests/dependabot-merge.tests.ps1
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:Workflow = Join-Path $PSScriptRoot '..' '..' '.github' 'workflows' 'dependabot-merge.yml' | Resolve-Path
$script:Failures = 0
$script:Count = 0
$script:Sha = '0123456789abcdef0123456789abcdef01234567'

# The step's script is the block scalar under its `run: |`, indented deeper than the key.
function Get-MergeScript {
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

# A gh that answers the two lookups as a green Dependabot PR #7 at $SHA would, and answers
# the merge with whatever GH_STUB_MERGE says. Every merge attempt is appended to the log.
$stub = @'
#!/usr/bin/env bash
args="$*"
case "$args" in
  *"/check-runs"*) exit 0 ;;
  *"/pulls?state=open"*) printf '7\tdependabot[bot]\n'; exit 0 ;;
esac
if [[ "$args" == *"/merge"* || "$args" == "pr merge"* ]]; then
  printf '%s\n' "$args" >> "$GH_STUB_LOG"
  case "$GH_STUB_MERGE" in
    ok) printf '{"merged":true}\n'; exit 0 ;;
    409) echo 'gh: Head branch was modified. Review and try the merge again. (HTTP 409)' >&2; exit 1 ;;
    *) echo 'gh: Pull Request is not mergeable (HTTP 405)' >&2; exit 1 ;;
  esac
fi
echo "stub gh: unexpected call: $args" >&2
exit 99
'@

function Invoke-MergeStep {
	param([string]$MergeAnswer)

	$dir = Join-Path ([System.IO.Path]::GetTempPath()) "dependabot-merge-$([guid]::NewGuid())"
	New-Item -ItemType Directory -Path $dir | Out-Null
	try {
		$gh = Join-Path $dir 'gh'
		Set-Content -LiteralPath $gh -Value $stub -NoNewline
		chmod +x $gh
		$scriptPath = Join-Path $dir 'step.sh'
		Set-Content -LiteralPath $scriptPath -Value (Get-MergeScript) -NoNewline
		$log = Join-Path $dir 'merges.log'

		$env:PATH = "$dir$([System.IO.Path]::PathSeparator)$script:OriginalPath"
		$env:GH_STUB_LOG = $log
		$env:GH_STUB_MERGE = $MergeAnswer
		$env:SHA = $script:Sha
		$env:SELF = 'Merge green Dependabot PR'
		$env:GITHUB_REPOSITORY = 'ktsu-dev/Example'
		$env:RUNNER_TEMP = $dir

		$output = & bash $scriptPath 2>&1 | Out-String
		$code = $LASTEXITCODE
		$merges = @(if (Test-Path -LiteralPath $log) { Get-Content -LiteralPath $log })
		return [pscustomobject]@{ Code = $code; Output = $output; Merges = [string[]]$merges }
	}
	finally {
		$env:PATH = $script:OriginalPath
		Remove-Item -LiteralPath $dir -Recurse -Force -ErrorAction SilentlyContinue
	}
}

function Test-Case {
	param([string]$Name, [string]$MergeAnswer, [scriptblock]$Assertion)

	$script:Count++
	$result = Invoke-MergeStep -MergeAnswer $MergeAnswer
	$problem = & $Assertion $result
	if ($problem) {
		$script:Failures++
		Write-Host "FAIL  $Name" -ForegroundColor Red
		Write-Host "      $problem" -ForegroundColor Red
		Write-Host "      exit $($result.Code); output:`n      $($result.Output.Trim() -replace "`n", "`n      ")" -ForegroundColor Red
		return
	}
	Write-Host "ok    $Name" -ForegroundColor Green
}

$script:OriginalPath = $env:PATH

Test-Case -Name 'the merge is pinned to the commit whose checks were read' -MergeAnswer 'ok' -Assertion {
	param($r)
	if ($r.Code -ne 0) { return "a green PR did not merge cleanly." }
	if ($r.Merges.Count -ne 1) { return "expected one merge call, got $($r.Merges.Count)." }
	if ($r.Merges[0] -notmatch "sha=$script:Sha" -and $r.Merges[0] -notmatch "--match-head-commit $script:Sha") {
		return "the merge call does not name $script:Sha, so GitHub merges whatever the head is by then: $($r.Merges[0])"
	}
}

Test-Case -Name 'a head that moved after the checks were read is left for the next run' -MergeAnswer '409' -Assertion {
	param($r)
	if ($r.Code -ne 0) { return "a refused merge because the head moved failed the job; CI on the new head re-fires it." }
	if ($r.Output -notmatch 'moved') { return "the job does not say why it did not merge." }
}

Test-Case -Name 'any other refusal still fails the job' -MergeAnswer '405' -Assertion {
	param($r)
	if ($r.Code -eq 0) { return "a merge refused for a reason other than a moved head was reported as success." }
}

Write-Host ''
if ($script:Failures -gt 0) {
	Write-Host "$script:Failures of $script:Count case(s) failed." -ForegroundColor Red
	exit 1
}

Write-Host "All $script:Count case(s) passed." -ForegroundColor Green
