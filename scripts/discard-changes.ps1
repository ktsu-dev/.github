# Script to revert changes in specific files across multiple repositories
# Usage:
# .\discard-changes.ps1 -filePatterns @("CHANGELOG.md", "LICENSE.md")
# .\discard-changes.ps1 -filePatterns "README.md" -workspaceRoot "C:\custom\path"
# .\discard-changes.ps1 -filePatterns @("*.md", "*.json")

param (
    [Parameter(Mandatory=$true)]
    [string[]]$filePatterns,

    [Parameter(Mandatory=$false)]
    [string]$workspaceRoot = (Get-Location).Path
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

$allModifiedFiles = @()

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
                }
            }
        } else {
            Write-Host "  No modified files matching the patterns in this repository." -ForegroundColor Gray
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

# Display results and ask for confirmation
if ($allModifiedFiles.Count -eq 0) {
    Write-Host "`nNo modified files matching the patterns found in any repository." -ForegroundColor Yellow
    exit 0
}

Write-Host "`nThe following files will be reverted:" -ForegroundColor Yellow
$allModifiedFiles | ForEach-Object {
    Write-Host "  - $($_.Repository) → $($_.File)" -ForegroundColor Gray
}

$confirmation = Read-Host "`nDo you want to proceed with reverting these files? (y/n)"
if ($confirmation -ne 'y') {
    Write-Host "Operation cancelled." -ForegroundColor Red
    exit 0
}

# Revert each file
$successCount = 0
$failCount = 0

foreach ($fileObj in $allModifiedFiles) {
    Write-Host "`nReverting $($fileObj.File) in $($fileObj.Repository)..." -ForegroundColor Cyan

    Push-Location $fileObj.Repository

    try {
        # This will revert both staged and unstaged changes
        git checkout HEAD -- $fileObj.File
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✓ Successfully reverted" -ForegroundColor Green
            $successCount++
        } else {
            Write-Host "  ✗ Failed to revert" -ForegroundColor Red
            $failCount++
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

Write-Host "`nOperation completed: $successCount files reverted successfully, $failCount failures." -ForegroundColor Green
