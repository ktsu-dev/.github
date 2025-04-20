# Script to find and fix common Markdown issues in files
# Usage:
# .\fix-markdown.ps1
# .\fix-markdown.ps1 -rootDirectory "C:\custom\path"
# .\fix-markdown.ps1 -excludePatterns @("node_modules", "vendor")

param (
    [Parameter(Mandatory=$false)]
    [string]$rootDirectory = (Get-Location).Path,

    [Parameter(Mandatory=$false)]
    [string[]]$excludePatterns = @()
)

# Create regex pattern for exclusions
$excludeRegex = if ($excludePatterns.Count -gt 0) {
    ($excludePatterns | ForEach-Object { [regex]::Escape($_).Replace("\*", ".*") }) -join "|"
} else {
    "^$" # Match nothing by default
}

Write-Host "Scanning for Markdown files in $rootDirectory..." -ForegroundColor Cyan

# Find all markdown files
$markdownFiles = Get-ChildItem -Path $rootDirectory -Filter "*.md" -File -Recurse |
    Where-Object { $_.FullName -notmatch $excludeRegex }

if ($markdownFiles.Count -eq 0) {
    Write-Host "No Markdown files found in the workspace." -ForegroundColor Yellow
    exit 0
}

Write-Host "Found $($markdownFiles.Count) Markdown files." -ForegroundColor Green

# Function to fix common Markdown issues
function Fix-CommonMarkdownIssues {
    param (
        [Parameter(Mandatory=$true)]
        [string]$content
    )

    # Fix 1: Ensure one space after list markers (* - +)
    $content = $content -replace '(^|\n)([*\-+])([^\s])', '$1$2 $3'

    # Fix 2: Ensure space after heading markers (#)
    $content = $content -replace '(^|\n)(#{1,6})([^\s#])', '$1$2 $3'

    # Fix 3: Fix common link syntax issues
    $content = $content -replace '\]\s*\(', ']('
    $content = $content -replace '\s*\)', ')'

    # Fix 4: Ensure blank line before headings
    $content = $content -replace '([^\n])\n(#{1,6}\s)', '$1' + "`n`n" + '$2'

    # Fix 5: Fix table formatting - ensure at least 3 dashes in separator row
    $content = $content -replace '(\|[-]{1,2}\|)+', { $_.Value -replace '-', '---' }

    # Fix 6: Ensure proper fenced code blocks (```) have language specified or are properly closed
    $content = $content -replace '```\s*\n', "```\n"

    # Fix 7: Consistent line endings (ensure Windows-style CRLF)
    $content = $content -replace '\n', "`r`n"
    $content = $content -replace '\r\r\n', "`r`n"

    # Fix 8: Trim trailing whitespace from lines
    $content = $content -replace '[ \t]+\r\n', "`r`n"

    # Fix 9: Ensure document ends with a newline
    if (!$content.EndsWith("`r`n")) {
        $content = $content + "`r`n"
    }

    return $content
}

# Process each file
$changedFiles = 0
$unchangedFiles = 0
$errorFiles = 0

foreach ($file in $markdownFiles) {
    Write-Host "Processing $($file.FullName)..." -ForegroundColor Cyan

    try {
        # Read file content
        $originalContent = Get-Content -Path $file.FullName -Raw -ErrorAction Stop

        # Fix markdown issues
        $fixedContent = Fix-CommonMarkdownIssues -content $originalContent

        # Compare original and fixed content
        if ($originalContent -ne $fixedContent) {
            # Backup the original file
            $backupPath = "$($file.FullName).bak"
            Copy-Item -Path $file.FullName -Destination $backupPath -Force -ErrorAction Stop

            # Write fixed content back to file
            Set-Content -Path $file.FullName -Value $fixedContent -NoNewline -ErrorAction Stop

            Write-Host "  ✓ Fixed issues and created backup at $backupPath" -ForegroundColor Green
            $changedFiles++
        }
        else {
            Write-Host "  ✓ No issues found" -ForegroundColor Gray
            $unchangedFiles++
        }
    }
    catch {
        Write-Host "  ✗ Error processing file: $_" -ForegroundColor Red
        $errorFiles++
    }
}

# Display summary
Write-Host "`nOperation completed:" -ForegroundColor Cyan
Write-Host "  $changedFiles files fixed" -ForegroundColor Green
Write-Host "  $unchangedFiles files unchanged" -ForegroundColor Gray
if ($errorFiles -gt 0) {
    Write-Host "  $errorFiles files encountered errors" -ForegroundColor Red
}

Write-Host "`nIf you'd like to review the changes, check the .bak files next to the modified Markdown files." -ForegroundColor Yellow
Write-Host "To revert changes, you can run:" -ForegroundColor Yellow
Write-Host "  Get-ChildItem -Path $rootDirectory -Filter '*.md.bak' -Recurse | ForEach-Object { Move-Item -Path `$_.FullName -Destination `$_.FullName.TrimEnd('.bak') -Force }" -ForegroundColor Gray
