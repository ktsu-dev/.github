# Script to revert changes in specific files across multiple repositories
# Usage:
# .\discard-changes.ps1 -filePatterns @("CHANGELOG.md", "LICENSE.md")
# .\discard-changes.ps1 -filePatterns "README.md" -workspaceRoot "C:\custom\path"
# .\discard-changes.ps1 -filePatterns @("*.md", "*.json")
# .\discard-changes.ps1 -filePatterns @("*.md") -includeUntracked $true
#
# Patterns are wildcards (*, ?, [abc]) matched against the whole name, never a substring of it.
# A pattern without a '/' is matched against the file name, at any depth, so "*.cs" selects
# src/Program.cs but not Lib/Lib.csproj, and "LICENSE.md" selects docs/LICENSE.md but not
# NOTLICENSE.md. A pattern with a '/' is matched against the whole repository-relative path.
#
# A staged file that is not in HEAD has nothing to revert to, so it is unstaged instead and its
# contents are left on disk.

param (
    [Parameter(Mandatory=$true)]
    [string[]]$filePatterns,

    [Parameter(Mandatory=$false)]
    [string]$workspaceRoot = (Get-Location).Path,

    [Parameter(Mandatory=$false)]
    [bool]$includeUntracked = $false
)

# A path is selected when any pattern matches all of its file name, or all of the path for a
# pattern that names a directory. An unanchored regex would match "*.cs" inside "X.csproj".
function Test-PatternMatch {
    param([string]$Path)

    $leaf = ($Path -split '/')[-1]
    foreach ($pattern in $filePatterns) {
        $normalized = $pattern.Replace('\', '/')
        $subject = if ($normalized.Contains('/')) { $Path } else { $leaf }
        if ($subject -like $normalized) {
            return $true
        }
    }
    return $false
}

function Get-MatchingFiles {
    param([string[]]$GitArgs)

    # core.quotePath=false keeps non-ASCII names as names rather than octal-escaped strings.
    return @(git -c core.quotePath=false @GitArgs | Where-Object { $_ -and (Test-PatternMatch $_) })
}

# Get all git repositories in the workspace
Write-Host "Scanning for git repositories in $workspaceRoot..." -ForegroundColor Cyan
$gitRepos = Get-ChildItem -Path $workspaceRoot -Directory -Recurse -Depth 3 -Force |
    Where-Object { Test-Path -Path (Join-Path $_.FullName ".git") -PathType Container } |
    Select-Object -ExpandProperty FullName

if ($gitRepos.Count -eq 0) {
    Write-Host "No git repositories found in the workspace." -ForegroundColor Red
    exit 1
}

Write-Host "Found $($gitRepos.Count) git repositories." -ForegroundColor Green
Write-Host "Looking for files matching: $($filePatterns -join ', ')" -ForegroundColor Cyan
if ($includeUntracked) {
    Write-Host "Including untracked files in the search." -ForegroundColor Cyan
}

$allModifiedFiles = @()
$allUntrackedFiles = @()

# For each repository, find modified files matching the patterns
foreach ($repo in $gitRepos) {
    Write-Host "`nChecking repository: $repo" -ForegroundColor Cyan

    # Change to the repository directory
    Push-Location $repo

    try {
        # Find both unstaged and staged modified files matching the patterns
        $modifiedFiles = @()

        # Staged files that are not in HEAD: "git checkout HEAD" has nothing to restore them from
        $stagedNewFiles = Get-MatchingFiles @('diff', '--cached', '--name-only', '--diff-filter=A')

        # Unstaged changes
        $modifiedFiles += Get-MatchingFiles @('ls-files', '--modified')

        # Staged changes (that haven't been committed yet)
        $modifiedFiles += Get-MatchingFiles @('diff', '--cached', '--name-only')

        # Remove duplicates (files that are both staged and have unstaged changes), and the new files
        $modifiedFiles = @($modifiedFiles | Select-Object -Unique | Where-Object { $stagedNewFiles -notcontains $_ })

        foreach ($file in $stagedNewFiles) {
            Write-Host "  $file is staged but not in HEAD, so it will be unstaged and kept on disk." -ForegroundColor Yellow
            $allModifiedFiles += [PSCustomObject]@{
                Repository = $repo
                File = $file
                FullPath = Join-Path -Path $repo -ChildPath $file
                Type = "StagedNew"
            }
        }

        if ($modifiedFiles.Count -gt 0) {
            Write-Host "  Found $($modifiedFiles.Count) modified files matching the patterns." -ForegroundColor Yellow

            foreach ($file in $modifiedFiles) {
                $allModifiedFiles += [PSCustomObject]@{
                    Repository = $repo
                    File = $file
                    FullPath = Join-Path -Path $repo -ChildPath $file
                    Type = "Tracked"
                }
            }
        } else {
            Write-Host "  No modified files matching the patterns in this repository." -ForegroundColor Gray
        }

        # Find untracked files if requested
        if ($includeUntracked) {
            $untrackedFiles = Get-MatchingFiles @('ls-files', '--others', '--exclude-standard')

            if ($untrackedFiles -and $untrackedFiles.Count -gt 0) {
                Write-Host "  Found $($untrackedFiles.Count) untracked files matching the patterns." -ForegroundColor Yellow

                foreach ($file in $untrackedFiles) {
                    $allUntrackedFiles += [PSCustomObject]@{
                        Repository = $repo
                        File = $file
                        FullPath = Join-Path -Path $repo -ChildPath $file
                        Type = "Untracked"
                    }
                }
            } else {
                Write-Host "  No untracked files matching the patterns in this repository." -ForegroundColor Gray
            }
        }
    }
    catch {
        Write-Host "  Error processing repository: $_" -ForegroundColor Red
    }
    finally {
        # Return to the original directory
        Pop-Location
    }
}

# Combine the files lists
$allFiles = $allModifiedFiles + $allUntrackedFiles

# Display results and ask for confirmation
if ($allFiles.Count -eq 0) {
    if ($includeUntracked) {
        Write-Host "`nNo modified or untracked files matching the patterns found in any repository." -ForegroundColor Yellow
    } else {
        Write-Host "`nNo modified files matching the patterns found in any repository." -ForegroundColor Yellow
    }
    exit 0
}

Write-Host "`nThe following files will be reverted/removed:" -ForegroundColor Yellow
$allFiles | ForEach-Object {
    $actionType = switch ($_.Type) { "Untracked" { "REMOVE" } "StagedNew" { "UNSTAGE" } default { "REVERT" } }
    Write-Host "  - $($_.Repository) → $($_.File) [$actionType]" -ForegroundColor Gray
}

$confirmation = Read-Host "`nDo you want to proceed? (y/n)"
if ($confirmation -ne 'y') {
    Write-Host "Operation cancelled." -ForegroundColor Red
    exit 0
}

# Process each file
$successCount = 0
$failCount = 0

foreach ($fileObj in $allFiles) {
    if ($fileObj.Type -eq "Tracked") {
        Write-Host "`nReverting $($fileObj.File) in $($fileObj.Repository)..." -ForegroundColor Cyan
    } elseif ($fileObj.Type -eq "StagedNew") {
        Write-Host "`nUnstaging new file $($fileObj.File) in $($fileObj.Repository)..." -ForegroundColor Cyan
    } else {
        Write-Host "`nRemoving untracked file $($fileObj.File) in $($fileObj.Repository)..." -ForegroundColor Cyan
    }

    Push-Location $fileObj.Repository

    try {
        if ($fileObj.Type -eq "Tracked") {
            # This will revert both staged and unstaged changes
            git checkout HEAD -- $fileObj.File
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  ✓ Successfully reverted" -ForegroundColor Green
                $successCount++
            } else {
                Write-Host "  ✗ Failed to revert" -ForegroundColor Red
                $failCount++
            }
        } elseif ($fileObj.Type -eq "StagedNew") {
            # Not in HEAD, so drop it from the index and leave the working copy alone
            git restore --staged -- $fileObj.File
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  ✓ Successfully unstaged" -ForegroundColor Green
                $successCount++
            } else {
                Write-Host "  ✗ Failed to unstage" -ForegroundColor Red
                $failCount++
            }
        } else {
            # This will remove untracked files
            Remove-Item -Path $fileObj.FullPath -Force
            if ($?) {
                Write-Host "  ✓ Successfully removed" -ForegroundColor Green
                $successCount++
            } else {
                Write-Host "  ✗ Failed to remove" -ForegroundColor Red
                $failCount++
            }
        }
    }
    catch {
        Write-Host "  ✗ Error: $_" -ForegroundColor Red
        $failCount++
    }
    finally {
        Pop-Location
    }
}

Write-Host "`nOperation completed: $successCount files processed successfully, $failCount failures." -ForegroundColor Green
