# Script to find and fix Markdown issues in files using markdownlint if available
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

# Function to check if a command exists
function Test-CommandExists {
    param (
        [string]$command
    )

    $exists = $null
    try {
        $exists = Get-Command $command -ErrorAction Stop
    } catch {
        $exists = $false
    }
    return [bool]$exists
}

# Initialize variables
$useMarkdownlint = Test-CommandExists "markdownlint"
$markdownlintConfigFile = $null

# Check for markdownlint config files
$configPaths = @(
    # Root config
    (Join-Path -Path $rootDirectory -ChildPath ".markdownlint.json"),
    (Join-Path -Path $rootDirectory -ChildPath ".markdownlint.jsonc"),
    (Join-Path -Path $rootDirectory -ChildPath ".markdownlint.yaml"),
    (Join-Path -Path $rootDirectory -ChildPath ".markdownlint.yml"),
    # Config in .github folder
    (Join-Path -Path $rootDirectory -ChildPath ".github/.markdownlint.json"),
    (Join-Path -Path $rootDirectory -ChildPath ".github/.markdownlint.jsonc"),
    (Join-Path -Path $rootDirectory -ChildPath ".github/.markdownlint.yaml"),
    (Join-Path -Path $rootDirectory -ChildPath ".github/.markdownlint.yml")
)

foreach ($path in $configPaths) {
    if (Test-Path -Path $path) {
        $markdownlintConfigFile = $path
        break
    }
}

Write-Host "Markdown linting configuration:" -ForegroundColor Cyan
if ($useMarkdownlint) {
    Write-Host "  ✓ markdownlint command found - will use for automated fixes" -ForegroundColor Green
} else {
    Write-Host "  ⚠ markdownlint command not found - will use built-in fixes" -ForegroundColor Yellow
}

if ($markdownlintConfigFile) {
    Write-Host "  ✓ Using configuration from: $markdownlintConfigFile" -ForegroundColor Green
} else {
    Write-Host "  ⚠ No markdownlint configuration found - using defaults" -ForegroundColor Yellow
}

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

# Function to fix common Markdown issues based on markdownlint rules
function Fix-CommonMarkdownIssues {
    param (
        [Parameter(Mandatory=$true)]
        [string]$content,
        [Parameter(Mandatory=$false)]
        [string]$configFile = $null
    )

    # Fix MD018, MD019 - Ensure one space after heading markers (#)
    $content = $content -replace '(^|\r?\n)(#{1,6})([^\s#])', '$1$2 $3'
    $content = $content -replace '(^|\r?\n)(#{1,6})[ ]{2,}([^\s#])', '$1$2 $3'

    # Fix MD004 - Use dash for unordered lists (based on config)
    $content = $content -replace '(^|\r?\n)[ ]*\*[ ]', '$1- '

    # Fix MD005, MD007 - List indentation (2 spaces per level)
    $content = $content -replace '(^|\r?\n)(\s{1}|\s{3,})-[ ]', '$1  - '

    # Fix MD009 - No trailing spaces except for line breaks (2 spaces)
    $content = $content -replace '[ \t]+$', ''
    # Don't remove trailing spaces for line breaks (2 spaces)
    $content = $content -replace '(\S)[ ]{2}(\r?\n)', '$1  $2'

    # Fix MD011 - No reversed links
    $content = $content -replace '\(\[(.*?)\]\((.*?)\)\)', '[[$1]]($2)'

    # Fix MD012 - No multiple consecutive blank lines
    $content = $content -replace '(\r?\n){3,}', "`r`n`r`n"

    # Fix MD022 - Headings must be surrounded by blank lines
    $content = $content -replace '([^\r\n])(\r?\n)(#{1,6} )', '$1$2$2$3'
    $content = $content -replace '(#{1,6} .*?)(\r?\n)([^\r\n])', '$1$2$2$3'

    # Fix MD023 - Headings must start at the beginning of the line
    $content = $content -replace '(^|\r?\n)[ \t]+(#{1,6} )', '$1$2'

    # Fix MD026 - No trailing punctuation in headings
    $content = $content -replace '(^|\r?\n)(#{1,6} .*?)[.,;:!。，；：！](\s*?)(\r?\n|$)', '$1$2$3$4'

    # Fix MD027 - No multiple spaces after blockquote symbol
    $content = $content -replace '(^|\r?\n)>[ ]{2,}', '$1> '

    # Fix MD030 - Spaces after list markers
    $content = $content -replace '(^|\r?\n)([*\-+])([^\s])', '$1$2 $3'
    $content = $content -replace '(^|\r?\n)(\d+\.)([^\s])', '$1$2 $3'

    # Fix MD031 - Fenced code blocks should be surrounded by blank lines
    $content = $content -replace '([^\r\n])(\r?\n)```', '$1$2$2```'
    $content = $content -replace '```(\r?\n)([^\r\n])', '```$1$1$2'

    # Fix MD032 - Lists should be surrounded by blank lines
    $content = $content -replace '([^\r\n])(\r?\n)([ \t]*[*\-+][ ])', '$1$2$2$3'
    $content = $content -replace '([ \t]*[*\-+][ ].*?)(\r?\n)([^\r\n])', '$1$2$2$3'

    # Fix MD037 - No spaces inside emphasis markers
    $content = $content -replace '(\*|_)[ ]+(.*?)[ ]+(\*|_)', '$1$2$3'

    # Fix MD038 - No spaces inside code span markers
    $content = $content -replace '`[ ]+(.*?)[ ]+`', '`$1`'

    # Fix MD039 - No spaces inside link text
    $content = $content -replace '\[[ ]+(.*?)[ ]+\]', '[$1]'

    # Fix MD047 - Files should end with a single newline character
    if (!$content.EndsWith("`r`n")) {
        $content = $content.TrimEnd() + "`r`n"
    }
    # Remove multiple trailing newlines
    $content = $content -replace '(\r?\n)+$', "`r`n"

    # Fix MD040 - Fenced code blocks should have a language specified
    $content = $content -replace '```(\r?\n)', "```text$1"

    # Fix MD049, MD050 - Consistent emphasis and strong emphasis style (asterisk)
    $content = $content -replace '_([^_\s].*?[^_\s])_', '*$1*'
    $content = $content -replace '__([^_\s].*?[^_\s])__', '**$1**'

    return $content
}

# Process each file
$changedFiles = 0
$unchangedFiles = 0
$errorFiles = 0
$fixedByMarkdownlint = 0

foreach ($file in $markdownFiles) {
    Write-Host "Processing $($file.FullName)..." -ForegroundColor Cyan
    $isModified = $false

    try {
        # Create a backup of the original file
        $backupPath = "$($file.FullName).bak"
        Copy-Item -Path $file.FullName -Destination $backupPath -Force -ErrorAction Stop

        if ($useMarkdownlint) {
            # Try using markdownlint to fix issues
            $markdownlintArgs = "--fix"

            if ($markdownlintConfigFile) {
                $markdownlintArgs += " --config $markdownlintConfigFile"
            }

            $markdownlintArgs += " `"$($file.FullName)`""

            try {
                $output = Invoke-Expression "markdownlint $markdownlintArgs" 2>&1
                if ($LASTEXITCODE -eq 0) {
                    $fixedByMarkdownlint++
                    $isModified = $true
                    Write-Host "  ✓ Fixed with markdownlint" -ForegroundColor Green
                } else {
                    Write-Host "  ⚠ markdownlint reported issues but couldn't fix them all" -ForegroundColor Yellow
                    Write-Host "  ℹ Falling back to built-in fixes" -ForegroundColor Cyan

                    # Read file content
                    $content = Get-Content -Path $file.FullName -Raw -ErrorAction Stop

                    # Fix markdown issues with our own function
                    $fixedContent = Fix-CommonMarkdownIssues -content $content -configFile $markdownlintConfigFile

                    # Compare original and fixed content
                    if ($content -ne $fixedContent) {
                        # Write fixed content back to file
                        Set-Content -Path $file.FullName -Value $fixedContent -NoNewline -ErrorAction Stop
                        $isModified = $true
                        Write-Host "  ✓ Fixed with built-in rules" -ForegroundColor Green
                    }
                }
            } catch {
                Write-Host "  ⚠ Error running markdownlint: $_" -ForegroundColor Yellow
                Write-Host "  ℹ Falling back to built-in fixes" -ForegroundColor Cyan

                # Read file content
                $content = Get-Content -Path $file.FullName -Raw -ErrorAction Stop

                # Fix markdown issues with our own function
                $fixedContent = Fix-CommonMarkdownIssues -content $content -configFile $markdownlintConfigFile

                # Compare original and fixed content
                if ($content -ne $fixedContent) {
                    # Write fixed content back to file
                    Set-Content -Path $file.FullName -Value $fixedContent -NoNewline -ErrorAction Stop
                    $isModified = $true
                    Write-Host "  ✓ Fixed with built-in rules" -ForegroundColor Green
                }
            }
        } else {
            # Use built-in fixes
            # Read file content
            $content = Get-Content -Path $file.FullName -Raw -ErrorAction Stop

            # Fix markdown issues
            $fixedContent = Fix-CommonMarkdownIssues -content $content -configFile $markdownlintConfigFile

            # Compare original and fixed content
            if ($content -ne $fixedContent) {
                # Write fixed content back to file
                Set-Content -Path $file.FullName -Value $fixedContent -NoNewline -ErrorAction Stop
                $isModified = $true
                Write-Host "  ✓ Fixed with built-in rules" -ForegroundColor Green
            }
        }

        # Check if any changes were made
        if ($isModified) {
            $changedFiles++
        } else {
            $unchangedFiles++
            # Remove backup if no changes
            Remove-Item -Path $backupPath -Force -ErrorAction SilentlyContinue
            Write-Host "  ✓ No issues found" -ForegroundColor Gray
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
if ($useMarkdownlint) {
    Write-Host "  $fixedByMarkdownlint fixed with markdownlint" -ForegroundColor Green
}
Write-Host "  $unchangedFiles files unchanged" -ForegroundColor Gray
if ($errorFiles -gt 0) {
    Write-Host "  $errorFiles files encountered errors" -ForegroundColor Red
}

Write-Host "`nIf you'd like to review the changes, check the .bak files next to the modified Markdown files." -ForegroundColor Yellow
Write-Host "To revert changes, you can run:" -ForegroundColor Yellow
Write-Host "  Get-ChildItem -Path $rootDirectory -Filter '*.md.bak' -Recurse | ForEach-Object { Move-Item -Path `$_.FullName -Destination `$_.FullName.TrimEnd('.bak') -Force }" -ForegroundColor Gray
