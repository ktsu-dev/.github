<#
.SYNOPSIS
	Checks which files discard-changes.ps1 selects, against a real git repository.

.DESCRIPTION
	The script is destructive: it reverts tracked files and, with -includeUntracked, deletes
	untracked ones. Each case builds a throwaway workspace holding one repository, runs the script
	in a child pwsh with "y" on stdin for its confirmation prompt, and then checks what git and the
	file system say happened. Run with pwsh: ./scripts/tests/discard-changes.tests.ps1

	The cases come from ktsu-dev/.github#51, where patterns were turned into an unanchored regex,
	so "*.cs" also selected .csproj and .cshtml files and "LICENSE.md" selected NOTLICENSE.md.
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:Script = Join-Path $PSScriptRoot '..' 'discard-changes.ps1' | Resolve-Path
$script:Failures = 0
$script:Count = 0

$Committed = @(
	'src/Program.cs'
	'tools/src/Helper.cs'
	'Lib/Lib.csproj'
	'Views/Index.cshtml'
	'LICENSE.md'
	'NOTLICENSE.md'
	'docs/LICENSE.md'
)

function Invoke-Git {
	param([string]$Repo, [string[]]$GitArgs)

	$output = & git -C $Repo -c user.name=test -c user.email=test@example.invalid -c commit.gpgsign=false @GitArgs 2>&1
	if ($LASTEXITCODE -ne 0) {
		throw "git $($GitArgs -join ' ') failed: $output"
	}
	return $output
}

# A workspace with one repository in it, every committed file then modified, plus whatever
# untracked and staged-new files the case asks for.
function New-Workspace {
	param([string[]]$Untracked = @(), [string[]]$StagedNew = @())

	$root = Join-Path ([System.IO.Path]::GetTempPath()) "discard-changes-$([guid]::NewGuid())"
	$repo = Join-Path $root 'repo'
	New-Item -ItemType Directory -Path $repo -Force | Out-Null
	Invoke-Git $repo @('init', '-q') | Out-Null

	foreach ($file in $Committed) {
		$path = Join-Path $repo $file
		New-Item -ItemType Directory -Path (Split-Path -Parent $path) -Force | Out-Null
		Set-Content -LiteralPath $path -Value 'original'
	}
	Invoke-Git $repo @('add', '-A') | Out-Null
	Invoke-Git $repo @('commit', '-q', '-m', 'initial') | Out-Null

	foreach ($file in $Committed) {
		Set-Content -LiteralPath (Join-Path $repo $file) -Value 'edited'
	}
	foreach ($file in $Untracked + $StagedNew) {
		$path = Join-Path $repo $file
		New-Item -ItemType Directory -Path (Split-Path -Parent $path) -Force | Out-Null
		Set-Content -LiteralPath $path -Value 'new'
	}
	foreach ($file in $StagedNew) {
		Invoke-Git $repo @('add', '--', $file) | Out-Null
	}

	return [PSCustomObject]@{ Root = $root; Repo = $repo }
}

function Invoke-Discard {
	param([string]$Root, [string[]]$Patterns, [bool]$IncludeUntracked)

	$untracked = if ($IncludeUntracked) { '$true' } else { '$false' }
	$quoted = ($Patterns | ForEach-Object { "'$($_ -replace "'", "''")'" }) -join ','
	$command = "& '$script:Script' -filePatterns @($quoted) -workspaceRoot '$Root' -includeUntracked $untracked"
	return ('y' | pwsh -NoProfile -Command $command 2>&1 | Out-String)
}

function Get-ModifiedFiles {
	param([string]$Repo)
	return @(Invoke-Git $Repo @('ls-files', '--modified'))
}

# Files the run was expected to revert or delete, and the run's own failure count.
function Get-DiscardedProblems {
	param([string]$Repo, [string]$Output, [string[]]$Reverted, [string[]]$Removed)

	$modified = Get-ModifiedFiles $Repo
	$problems = @()
	foreach ($file in $Reverted | Where-Object { $modified -contains $_ }) {
		$problems += "$file should have been reverted"
	}
	foreach ($file in $Removed | Where-Object { Test-Path -LiteralPath (Join-Path $Repo $_) }) {
		$problems += "$file should have been removed"
	}
	if ($Output -notmatch ', 0 failures\.') {
		$problems += 'the run should report 0 failures'
	}
	return $problems
}

# Staged new files: out of the index, still on disk, and reported as UNSTAGE rather than REVERT.
function Get-UnstagedProblems {
	param([string]$Repo, [string]$Output, [string[]]$Unstaged)

	$staged = @(Invoke-Git $Repo @('diff', '--cached', '--name-only'))
	$problems = @()
	foreach ($file in $Unstaged) {
		$listed = [regex]::Escape($file)
		if ($staged -contains $file) { $problems += "$file should have been unstaged" }
		if (-not (Test-Path -LiteralPath (Join-Path $Repo $file))) { $problems += "$file should still be on disk" }
		if ($Output -notmatch "$listed \[UNSTAGE\]") { $problems += "$file should be listed as UNSTAGE" }
		if ($Output -match "$listed \[REVERT\]") { $problems += "$file should not be listed as REVERT" }
	}
	return $problems
}

# Files no pattern selects: still present, and still holding their edit.
function Get-KeptProblems {
	param([string]$Repo, [string[]]$Kept)

	$problems = @()
	foreach ($file in $Kept) {
		$path = Join-Path $Repo $file
		if (-not (Test-Path -LiteralPath $path)) {
			$problems += "$file should not have been removed"
		}
		elseif ((Get-Content -LiteralPath $path -Raw).Trim() -eq 'original') {
			$problems += "$file should not have been reverted"
		}
	}
	return $problems
}

function Test-Case {
	param(
		[string]$Name,
		[string[]]$Patterns,
		[bool]$IncludeUntracked = $false,
		[string[]]$Untracked = @(),
		[string[]]$StagedNew = @(),
		[string[]]$Reverted = @(),
		[string[]]$Removed = @(),
		[string[]]$Unstaged = @(),
		[string[]]$Kept = @()
	)

	$script:Count++
	$workspace = New-Workspace -Untracked $Untracked -StagedNew $StagedNew
	try {
		$output = Invoke-Discard -Root $workspace.Root -Patterns $Patterns -IncludeUntracked $IncludeUntracked
		$problems = @(
			Get-DiscardedProblems -Repo $workspace.Repo -Output $output -Reverted $Reverted -Removed $Removed
			Get-UnstagedProblems -Repo $workspace.Repo -Output $output -Unstaged $Unstaged
			Get-KeptProblems -Repo $workspace.Repo -Kept $Kept
		)

		if ($problems.Count -gt 0) {
			$script:Failures++
			Write-Host "FAIL  $Name" -ForegroundColor Red
			$problems | ForEach-Object { Write-Host "      $_" -ForegroundColor Red }
			Write-Host "      script output:" -ForegroundColor Red
			Write-Host "      $($output.Trim() -replace "`n", "`n      ")" -ForegroundColor Red
			return
		}

		Write-Host "ok    $Name" -ForegroundColor Green
	}
	finally {
		Remove-Item -LiteralPath $workspace.Root -Recurse -Force -ErrorAction SilentlyContinue
	}
}

Test-Case -Name '*.cs selects .cs files at any depth, and not .csproj or .cshtml' `
	-Patterns @('*.cs') `
	-Reverted @('src/Program.cs', 'tools/src/Helper.cs') `
	-Kept @('Lib/Lib.csproj', 'Views/Index.cshtml')

Test-Case -Name 'LICENSE.md selects that file name at any depth, and not NOTLICENSE.md or LICENSE.md.orig' `
	-Patterns @('LICENSE.md') -IncludeUntracked $true `
	-Untracked @('docs/LICENSE.md.orig') `
	-Reverted @('LICENSE.md', 'docs/LICENSE.md') `
	-Kept @('NOTLICENSE.md', 'docs/LICENSE.md.orig')

Test-Case -Name 'with -includeUntracked, *.cs removes an untracked .cs file and keeps an untracked .csproj' `
	-Patterns @('*.cs') -IncludeUntracked $true `
	-Untracked @('src/New.cs', 'New/New.csproj') `
	-Removed @('src/New.cs') `
	-Kept @('New/New.csproj', 'Lib/Lib.csproj')

Test-Case -Name 'a pattern with a / is matched against the whole path' `
	-Patterns @('src/*.cs') `
	-Reverted @('src/Program.cs') `
	-Kept @('tools/src/Helper.cs')

Test-Case -Name 'a staged file not in HEAD is unstaged and kept, not reported as REVERT and then failed' `
	-Patterns @('*.cs') `
	-StagedNew @('src/Staged.cs') `
	-Reverted @('src/Program.cs') `
	-Unstaged @('src/Staged.cs')

Write-Host ''
if ($script:Failures -gt 0) {
	Write-Host "$script:Failures of $script:Count case(s) failed." -ForegroundColor Red
	exit 1
}

Write-Host "All $script:Count case(s) passed." -ForegroundColor Green
