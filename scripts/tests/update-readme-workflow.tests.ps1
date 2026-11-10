<#
.SYNOPSIS
	Runs the commit step of update-readme.yml against a branch that moved during generation.

.DESCRIPTION
	Update Readme spends about ten minutes generating the profile README before it commits.
	Anything that lands on main in that time made the bare `git push` fail with "fetch first",
	so every burst of merges turned the workflow red. See ktsu-dev/.github#55.

	The step's bash is taken from the workflow as written and run, under `bash -e` as Actions
	runs it, in a shallow clone of a local bare repository, the way actions/checkout leaves the
	runner. The cases move the remote branch underneath it and check that the generated README
	still reaches the branch, on top of what landed meanwhile.

	The concurrency group is also checked for cancel-in-progress, so a newer run replaces one
	that is still generating instead of queueing behind it.

	Run with pwsh: ./scripts/tests/update-readme-workflow.tests.ps1
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:Workflow = Join-Path $PSScriptRoot '..' '..' '.github' 'workflows' 'update-readme.yml' | Resolve-Path
$script:Lines = Get-Content -LiteralPath $script:Workflow
$script:Failures = 0
$script:Count = 0

# The block scalar under `run: |` of the step with the given name.
function Get-StepScript {
	param([string]$StepName)

	$lines = $script:Lines
	$named = -1
	for ($i = 0; $i -lt $lines.Count; $i++) {
		if ($lines[$i] -match "^\s*- name: $([regex]::Escape($StepName))\s*$") { $named = $i; break }
	}
	if ($named -lt 0) { throw "No step named '$StepName' in $script:Workflow." }

	$start = -1
	for ($i = $named + 1; $i -lt $lines.Count; $i++) {
		if ($lines[$i] -match '^\s*- name:') { break }
		if ($lines[$i] -match '^(\s*)run: \|\s*$') { $start = $i + 1; $indent = $Matches[1].Length; break }
	}
	if ($start -lt 0) { throw "Step '$StepName' has no 'run: |' block." }

	$body = @()
	for ($i = $start; $i -lt $lines.Count; $i++) {
		$line = $lines[$i]
		if ($line.Trim() -and ($line.Length - $line.TrimStart().Length) -le $indent) { break }
		$body += if ($line.Length -gt $indent + 2) { $line.Substring($indent + 2) } else { $line.Trim() }
	}
	return ($body -join "`n") + "`n"
}

function Invoke-Git {
	param([string]$Dir, [Parameter(ValueFromRemainingArguments)][string[]]$GitArgs)
	$out = & git -C $Dir @GitArgs 2>&1 | Out-String
	if ($LASTEXITCODE -ne 0) { throw "git $($GitArgs -join ' ') failed in ${Dir}:`n$out" }
	return $out.Trim()
}

function Write-File {
	param([string]$Path, [string]$Text)
	New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Path) | Out-Null
	Set-Content -LiteralPath $Path -Value $Text -NoNewline
}

# Builds a bare `origin` holding main, a shallow checkout of it standing in for the runner,
# and a second clone that plays whoever merges while the README is generated. The checkout
# has the newly generated README staged, as the Check for Changes step leaves it. $Meanwhile
# runs against the second clone before the step does.
function Invoke-CommitStep {
	param([scriptblock]$Meanwhile)

	$dir = Join-Path ([System.IO.Path]::GetTempPath()) "update-readme-$([guid]::NewGuid())"
	New-Item -ItemType Directory -Path $dir | Out-Null
	try {
		$origin = Join-Path $dir 'origin.git'
		$seed = Join-Path $dir 'seed'
		$runner = Join-Path $dir 'runner'
		$other = Join-Path $dir 'other'

		& git init -q --bare -b main $origin
		& git init -q -b main $seed
		Invoke-Git $seed config user.email 'seed@example.com' | Out-Null
		Invoke-Git $seed config user.name 'seed' | Out-Null
		Write-File (Join-Path $seed 'profile' 'README.md') "old readme`n"
		Write-File (Join-Path $seed 'scripts' 'a.ps1') "one`n"
		Invoke-Git $seed add -A | Out-Null
		Invoke-Git $seed commit -q -m 'seed' | Out-Null
		Invoke-Git $seed push -q $origin main | Out-Null

		& git clone -q --depth 1 --branch main "file://$origin" $runner 2>&1 | Out-Null
		& git clone -q "file://$origin" $other 2>&1 | Out-Null
		Invoke-Git $other config user.email 'other@example.com' | Out-Null
		Invoke-Git $other config user.name 'other' | Out-Null

		if ($Meanwhile) { & $Meanwhile $other }

		Write-File (Join-Path $runner 'profile' 'README.md') "generated readme`n"
		Invoke-Git $runner add ./profile/README.md | Out-Null

		$scriptPath = Join-Path $dir 'step.sh'
		Set-Content -LiteralPath $scriptPath -Value (Get-StepScript -StepName 'Commit Changes') -NoNewline
		$env:GITHUB_REF_NAME = 'main'
		Push-Location $runner
		try {
			$output = & bash -e $scriptPath 2>&1 | Out-String
			$code = $LASTEXITCODE
		}
		finally {
			Pop-Location
			Remove-Item Env:GITHUB_REF_NAME -ErrorAction SilentlyContinue
		}

		$readme = Invoke-Git $origin show main:profile/README.md
		$scriptText = Invoke-Git $origin show main:scripts/a.ps1
		$subjects = @((Invoke-Git $origin log --format=%s main) -split "`n")
		return [pscustomobject]@{ Code = $code; Output = $output; Readme = $readme; Script = $scriptText; Subjects = $subjects }
	}
	finally {
		Remove-Item -LiteralPath $dir -Recurse -Force -ErrorAction SilentlyContinue
	}
}

function Test-Case {
	param([string]$Name, [scriptblock]$Meanwhile, [scriptblock]$Assertion)

	$script:Count++
	$result = Invoke-CommitStep -Meanwhile $Meanwhile
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

Test-Case -Name 'pushes the README when main has not moved' -Assertion {
	param($r)
	if ($r.Code -ne 0) { return 'the step failed on an unmoved branch.' }
	if ($r.Readme -ne 'generated readme') { return "main's README is '$($r.Readme)'." }
}

Test-Case -Name 'pushes the README on top of a commit that landed during generation' -Meanwhile {
	param($other)
	Write-File (Join-Path $other 'scripts' 'a.ps1') "two`n"
	Invoke-Git $other commit -q -am 'merged meanwhile' | Out-Null
	Invoke-Git $other push -q origin main | Out-Null
} -Assertion {
	param($r)
	if ($r.Code -ne 0) { return 'the push was rejected because main moved during generation.' }
	if ($r.Readme -ne 'generated readme') { return "main's README is '$($r.Readme)', not the generated one." }
	if ($r.Script -ne 'two') { return 'the commit that landed meanwhile is no longer on main.' }
	if ($r.Subjects[0] -ne '[skip ci][bot] Update README.md') { return "main's tip is '$($r.Subjects[0])'." }
}

Test-Case -Name 'the generated README wins over one another run pushed meanwhile' -Meanwhile {
	param($other)
	Write-File (Join-Path $other 'profile' 'README.md') "someone else's readme`n"
	Invoke-Git $other commit -q -am 'readme meanwhile' | Out-Null
	Invoke-Git $other push -q origin main | Out-Null
} -Assertion {
	param($r)
	if ($r.Code -ne 0) { return 'the step failed when the README itself had changed on main.' }
	if ($r.Readme -ne 'generated readme') { return "main's README is '$($r.Readme)', not the generated one." }
}

$script:Count++
$concurrency = $false
$cancels = $false
foreach ($line in $script:Lines) {
	if ($line -match '^concurrency:\s*$') { $concurrency = $true; continue }
	if ($concurrency -and $line -match '^\S') { break }
	if ($concurrency -and $line -match '^\s+cancel-in-progress:\s*true\s*$') { $cancels = $true }
}
if ($cancels) {
	Write-Host 'ok    a newer run cancels the one still generating' -ForegroundColor Green
}
else {
	$script:Failures++
	Write-Host 'FAIL  a newer run cancels the one still generating' -ForegroundColor Red
	Write-Host '      the top-level concurrency group does not set cancel-in-progress: true.' -ForegroundColor Red
}

Write-Host ''
if ($script:Failures -gt 0) {
	Write-Host "$script:Failures of $script:Count case(s) failed." -ForegroundColor Red
	exit 1
}

Write-Host "All $script:Count case(s) passed." -ForegroundColor Green
