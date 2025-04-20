# Script to revert changes in specific files across multiple repositories
# Usage:
# .\discard-changes.ps1 -filePatterns @("CHANGELOG.md", "LICENSE.md")
# .\discard-changes.ps1 -filePatterns "README.md" -workspaceRoot "C:\custom\path"
# .\discard-changes.ps1 -filePatterns @("*.md", "*.json")
# .\discard-changes.ps1 -filePatterns @("*.md") -includeUntracked $true

param (
    [Parameter(Mandatory=$true)]
    [string[]]$filePatterns,

    [Parameter(Mandatory=$false)]
    [string]$workspaceRoot = (Get-Location).Path,

    [Parameter(Mandatory=$false)]
    [bool]$includeUntracked = $false
)

# Convert file patterns to a regex pattern for matching
$fileRegexPattern = ($filePatterns | ForEach-Object { [regex]::Escape($_).Replace("\*", ".*") }) -join "|"

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

        # Unstaged changes
        $unstagedFiles = git ls-files --modified | Where-Object { $_ -match $fileRegexPattern }
        if ($unstagedFiles) { $modifiedFiles += $unstagedFiles }

        # Staged changes (that haven't been committed yet)
        $stagedFiles = git diff --cached --name-only | Where-Object { $_ -match $fileRegexPattern }
        if ($stagedFiles) { $modifiedFiles += $stagedFiles }

        # Remove duplicates (files that are both staged and have unstaged changes)
        $modifiedFiles = $modifiedFiles | Select-Object -Unique

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
            $untrackedFiles = git ls-files --others --exclude-standard | Where-Object { $_ -match $fileRegexPattern }

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
    $actionType = if ($_.Type -eq "Untracked") { "REMOVE" } else { "REVERT" }
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
