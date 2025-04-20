# Script to find and fix Markdown issues in files using markdownlint if available
# Usage:
# .\fix-markdown.ps1
# .\fix-markdown.ps1 -rootDirectory "C:\custom\path"
# .\fix-markdown.ps1 -excludePatterns @("node_modules", "vendor")
# .\fix-markdown.ps1 -createBackups $true

param (
    [Parameter(Mandatory=$false)]
    [string]$rootDirectory = (Get-Location).Path,

    [Parameter(Mandatory=$false)]
    [string[]]$excludePatterns = @(),

    [Parameter(Mandatory=$false)]
    [bool]$createBackups = $false
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

# Function to find the closest markdownlint config by traversing up from file path
function Find-NearestConfigFile {
    param (
        [string]$filePath
    )

    $configNames = @(
        ".markdownlint.json",
        ".markdownlint.jsonc",
        ".markdownlint.yaml",
        ".markdownlint.yml"
    )

    $directory = [System.IO.Path]::GetDirectoryName($filePath)
    $foundConfig = $null

    # Keep going up until we find a config file or reach the root
    while (-not $foundConfig -and -not [string]::IsNullOrEmpty($directory)) {
        foreach ($configName in $configNames) {
            $configPath = Join-Path -Path $directory -ChildPath $configName
            if (Test-Path -Path $configPath) {
                $foundConfig = $configPath
                break
            }
        }

        if (-not $foundConfig) {
            # Try .github folder in this directory
            $githubDir = Join-Path -Path $directory -ChildPath ".github"
            if (Test-Path -Path $githubDir -PathType Container) {
                foreach ($configName in $configNames) {
                    $configPath = Join-Path -Path $githubDir -ChildPath $configName
                    if (Test-Path -Path $configPath) {
                        $foundConfig = $configPath
                        break
                    }
                }
            }
        }

        if (-not $foundConfig) {
            # Go up one level if no config found
            $parent = [System.IO.Directory]::GetParent($directory)
            if ($null -eq $parent) {
                # We've reached the root
                break
            }
            $directory = $parent.FullName
        }
    }

    return $foundConfig
}

# Function to parse JSON config file
function Parse-JsonConfigFile {
    param (
        [string]$configFilePath
    )

    if (-not $configFilePath -or -not (Test-Path $configFilePath)) {
        return @{}
    }

    try {
        $content = Get-Content -Path $configFilePath -Raw

        # Remove comments if it's a .jsonc file
        if ($configFilePath -like "*.jsonc") {
            # Remove // comments
            $content = $content -replace '//.*?(\r?\n|$)', '$1'
            # Remove /* */ comments
            $content = $content -replace '/\*.*?\*/', ''
        }

        $config = ConvertFrom-Json -InputObject $content -AsHashtable -ErrorAction Stop
        return $config
    }
    catch {
        Write-Host "  ⚠ Error parsing config file: $_" -ForegroundColor Yellow
        return @{}
    }
}

# Function to get config setting with default value
function Get-ConfigSetting {
    param (
        [hashtable]$config,
        [string]$ruleName,
        [string]$settingName,
        $defaultValue
    )

    if ($config.ContainsKey($ruleName)) {
        $rule = $config[$ruleName]
        if ($rule -is [hashtable] -and $rule.ContainsKey($settingName)) {
            return $rule[$settingName]
        }
    }

    return $defaultValue
}

# Initialize variables
$useMarkdownlint = Test-CommandExists "markdownlint"

# Create regex pattern for exclusions
$excludeRegex = if ($excludePatterns.Count -gt 0) {
    ($excludePatterns | ForEach-Object { [regex]::Escape($_).Replace("\*", ".*") }) -join "|"
} else {
    "^$" # Match nothing by default
}

Write-Host "Markdown linting configuration:" -ForegroundColor Cyan
if ($useMarkdownlint) {
    Write-Host "  ✓ markdownlint command found - will use for automated fixes" -ForegroundColor Green
} else {
    Write-Host "  ⚠ markdownlint command not found - will use built-in fixes" -ForegroundColor Yellow
}

Write-Host "Backup creation: $(if ($createBackups) { 'Enabled' } else { 'Disabled' })" -ForegroundColor Cyan

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

    # Parse config file if provided
    $config = @{}
    if ($configFile) {
        $config = Parse-JsonConfigFile -configFilePath $configFile
    }

    # Default settings
    $defaultSettings = @{
        # MD004 - List style
        "list_style" = "dash"      # dash is default, can be "dash", "asterisk", or "plus"

        # MD007 - List indentation
        "list_indent" = 2          # Default is 2 spaces

        # MD009 - Trailing spaces
        "allow_br_spaces" = 2      # Allow 2 spaces for line breaks by default

        # MD012 - Multiple consecutive blank lines
        "max_blank_lines" = 1      # Max consecutive blank lines

        # MD030 - List marker spacing
        "ul_single_spacing" = 1    # Space after list marker for single-line items
        "ol_single_spacing" = 1    # Space after list marker for single-line items

        # MD035 - Horizontal rule style
        "hr_style" = "---"         # Default horizontal rule style

        # MD046 - Code block style
        "code_block_style" = "fenced"  # Default code block style

        # MD048 - Code fence style
        "code_fence_style" = "backtick"  # Default is backtick (```) instead of tilde

        # MD049 - Emphasis style
        "emphasis_style" = "asterisk"  # Default is asterisk (*) instead of underscore

        # MD050 - Strong style
        "strong_style" = "asterisk"   # Default is asterisk (**) instead of underscore
    }

    # Override defaults with config settings

    # MD004 - List style
    $listStyle = Get-ConfigSetting -config $config -ruleName "MD004" -settingName "style" -defaultValue $defaultSettings.list_style

    # MD007 - List indentation
    $listIndent = Get-ConfigSetting -config $config -ruleName "MD007" -settingName "indent" -defaultValue $defaultSettings.list_indent

    # MD009 - Trailing spaces
    $brSpaces = Get-ConfigSetting -config $config -ruleName "MD009" -settingName "br_spaces" -defaultValue $defaultSettings.allow_br_spaces

    # MD012 - Multiple consecutive blank lines
    $maxBlankLines = Get-ConfigSetting -config $config -ruleName "MD012" -settingName "maximum" -defaultValue $defaultSettings.max_blank_lines

    # MD030 - List marker spacing
    $ulSingleSpacing = Get-ConfigSetting -config $config -ruleName "MD030" -settingName "ul_single" -defaultValue $defaultSettings.ul_single_spacing
    $olSingleSpacing = Get-ConfigSetting -config $config -ruleName "MD030" -settingName "ol_single" -defaultValue $defaultSettings.ol_single_spacing

    # MD035 - Horizontal rule style
    $hrStyle = Get-ConfigSetting -config $config -ruleName "MD035" -settingName "style" -defaultValue $defaultSettings.hr_style

    # MD046 - Code block style
    $codeBlockStyle = Get-ConfigSetting -config $config -ruleName "MD046" -settingName "style" -defaultValue $defaultSettings.code_block_style

    # MD048 - Code fence style
    $codeFenceStyle = Get-ConfigSetting -config $config -ruleName "MD048" -settingName "style" -defaultValue $defaultSettings.code_fence_style

    # MD049 - Emphasis style
    $emphasisStyle = Get-ConfigSetting -config $config -ruleName "MD049" -settingName "style" -defaultValue $defaultSettings.emphasis_style

    # MD050 - Strong style
    $strongStyle = Get-ConfigSetting -config $config -ruleName "MD050" -settingName "style" -defaultValue $defaultSettings.strong_style

    # Check if rules are enabled or disabled
    $ruleEnabled = @{}
    foreach ($key in $config.Keys) {
        if ($key -match '^MD\d+$') {
            $ruleEnabled[$key] = if ($config[$key] -is [bool]) { $config[$key] } else { $true }
        }
    }

    # Default is true if not specified
    function Is-RuleEnabled {
        param ([string]$ruleName)
        if ($ruleEnabled.ContainsKey($ruleName)) {
            return $ruleEnabled[$ruleName]
        }
        # Check if "default" is defined and use it
        if ($config.ContainsKey("default")) {
            return [bool]$config["default"]
        }
        return $true
    }

    # Fix MD018, MD019 - Ensure one space after heading markers (#)
    if (Is-RuleEnabled "MD018" -or Is-RuleEnabled "MD019") {
        $content = $content -replace '(^|\r?\n)(#{1,6})([^\s#])', '$1$2 $3'
        $content = $content -replace '(^|\r?\n)(#{1,6})[ ]{2,}([^\s#])', '$1$2 $3'
    }

    # Fix MD004 - Use configured style for unordered lists
    if (Is-RuleEnabled "MD004") {
        $listMarker = switch ($listStyle) {
            "dash" { "-" }
            "asterisk" { "*" }
            "plus" { "+" }
            default { "-" }
        }

        # Replace all list markers with the configured style
        $content = $content -replace '(^|\r?\n)[ ]*[\*\-\+][ ]', ('$1' + $listMarker + ' ')
    }

    # Fix MD005, MD007 - List indentation
    if (Is-RuleEnabled "MD007") {
        # Create a pattern with the proper indent
        $indentPattern = ' ' * $listIndent
        $content = $content -replace '(^|\r?\n)(\s{1}|\s{3,})([\*\-\+])[ ]', ('$1' + $indentPattern + '$3 ')
    }

    # Fix MD009 - No trailing spaces except for line breaks
    if (Is-RuleEnabled "MD009") {
        # Remove all trailing whitespace first
        $content = $content -replace '[ \t]+$', ''

        # Then add back the correct number of spaces for line breaks
        if ($brSpaces -gt 0) {
            $lineBreakSpace = ' ' * $brSpaces
            $content = $content -replace '(\S)(\r?\n)', ('$1' + $lineBreakSpace + '$2')
        }
    }

    # Fix MD011 - No reversed links
    if (Is-RuleEnabled "MD011") {
        $content = $content -replace '\(\[(.*?)\]\((.*?)\)\)', '[[$1]]($2)'
    }

    # Fix MD012 - No multiple consecutive blank lines
    if (Is-RuleEnabled "MD012") {
        $maxLines = $maxBlankLines + 1  # +1 because we're matching newlines, not blank lines
        $pattern = ('(\r?\n){' + ($maxLines + 1) + ',}')
        $replacement = [string]::Join('', (1..$maxLines | ForEach-Object { "`r`n" }))
        $content = $content -replace $pattern, $replacement
    }

    # Fix MD022 - Headings must be surrounded by blank lines
    if (Is-RuleEnabled "MD022") {
        $content = $content -replace '([^\r\n])(\r?\n)(#{1,6} )', '$1$2$2$3'
        $content = $content -replace '(#{1,6} .*?)(\r?\n)([^\r\n])', '$1$2$2$3'
    }

    # Fix MD023 - Headings must start at the beginning of the line
    if (Is-RuleEnabled "MD023") {
        $content = $content -replace '(^|\r?\n)[ \t]+(#{1,6} )', '$1$2'
    }

    # Fix MD026 - No trailing punctuation in headings
    if (Is-RuleEnabled "MD026") {
        # Get the punctuation characters from config or use default
        $punctuation = Get-ConfigSetting -config $config -ruleName "MD026" -settingName "punctuation" -defaultValue ".,;:!。，；：！"
        $escapedPunctuation = [regex]::Escape($punctuation)
        $content = $content -replace "(^|\r?\n)(#{1,6} .*?)[$escapedPunctuation](\s*?)(\r?\n|$)", '$1$2$3$4'
    }

    # Fix MD027 - No multiple spaces after blockquote symbol
    if (Is-RuleEnabled "MD027") {
        $content = $content -replace '(^|\r?\n)>[ ]{2,}', '$1> '
    }

    # Fix MD030 - Spaces after list markers
    if (Is-RuleEnabled "MD030") {
        # For unordered lists
        $ulSpacing = ' ' * $ulSingleSpacing
        $content = $content -replace '(^|\r?\n)([\*\-\+])([^\s])', ('$1$2' + $ulSpacing + '$3')

        # For ordered lists
        $olSpacing = ' ' * $olSingleSpacing
        $content = $content -replace '(^|\r?\n)(\d+\.)([^\s])', ('$1$2' + $olSpacing + '$3')
    }

    # Fix MD031 - Fenced code blocks should be surrounded by blank lines
    if (Is-RuleEnabled "MD031") {
        $content = $content -replace '([^\r\n])(\r?\n)```', '$1$2$2```'
        $content = $content -replace '```(\r?\n)([^\r\n])', '```$1$1$2'
    }

    # Fix MD032 - Lists should be surrounded by blank lines
    if (Is-RuleEnabled "MD032") {
        $content = $content -replace '([^\r\n])(\r?\n)([ \t]*[\*\-\+][ ])', '$1$2$2$3'
        $content = $content -replace '([ \t]*[\*\-\+][ ].*?)(\r?\n)([^\r\n])', '$1$2$2$3'
    }

    # Fix MD035 - Horizontal rule style
    if (Is-RuleEnabled "MD035") {
        # Find all horizontal rules and replace with configured style
        $hrPatterns = @('^\s*[\*\-_]{3,}\s*$')
        foreach ($pattern in $hrPatterns) {
            $content = $content -replace "(^|\r?\n)$pattern(\r?\n|$)", ('$1' + $hrStyle + '$2')
        }
    }

    # Fix MD037 - No spaces inside emphasis markers
    if (Is-RuleEnabled "MD037") {
        $content = $content -replace '(\*|_)[ ]+(.*?)[ ]+(\*|_)', '$1$2$3'
    }

    # Fix MD038 - No spaces inside code span markers
    if (Is-RuleEnabled "MD038") {
        $content = $content -replace '`[ ]+(.*?)[ ]+`', '`$1`'
    }

    # Fix MD039 - No spaces inside link text
    if (Is-RuleEnabled "MD039") {
        $content = $content -replace '\[[ ]+(.*?)[ ]+\]', '[$1]'
    }

    # Fix MD046, MD048 - Code block style and fence style
    if (Is-RuleEnabled "MD046" -or Is-RuleEnabled "MD048") {
        if ($codeBlockStyle -eq "fenced") {
            # Convert indented code blocks to fenced code blocks?
            # This is complex and might require more sophisticated parsing
        }

        # Set the fence style (``` or ~~~)
        if ($codeFenceStyle -eq "tilde") {
            # Convert backtick fences to tilde
            $content = $content -replace '(?m)^```', '~~~'
        } elseif ($codeFenceStyle -eq "backtick") {
            # Convert tilde fences to backtick
            $content = $content -replace '(?m)^~~~', '```'
        }
    }

    # Fix MD040 - Fenced code blocks should have a language specified
    if (Is-RuleEnabled "MD040") {
        # Only add 'text' to fenced code blocks that don't have a language specified
        if ($codeFenceStyle -eq "tilde") {
            $content = $content -replace '(?m)^~~~(\r?\n)', "~~~text$1"
        } else {
            $content = $content -replace '(?m)^```(\r?\n)', "```text$1"
        }
    }

    # Fix MD047 - Files should end with a single newline character
    if (Is-RuleEnabled "MD047") {
        if (!$content.EndsWith("`r`n")) {
            $content = $content.TrimEnd() + "`r`n"
        }
        # Remove multiple trailing newlines
        $content = $content -replace '(\r?\n)+$', "`r`n"
    }

    # Fix MD049, MD050 - Consistent emphasis and strong emphasis style
    if (Is-RuleEnabled "MD049") {
        if ($emphasisStyle -eq "asterisk") {
            # Convert underscores to asterisks for emphasis
            $content = $content -replace '_([^_\s].*?[^_\s])_', '*$1*'
        } elseif ($emphasisStyle -eq "underscore") {
            # Convert asterisks to underscores for emphasis
            $content = $content -replace '\*([^\*\s].*?[^\*\s])\*', '_$1_'
        }
    }

    if (Is-RuleEnabled "MD050") {
        if ($strongStyle -eq "asterisk") {
            # Convert underscores to asterisks for strong
            $content = $content -replace '__([^_\s].*?[^_\s])__', '**$1**'
        } elseif ($strongStyle -eq "underscore") {
            # Convert asterisks to underscores for strong
            $content = $content -replace '\*\*([^\*\s].*?[^\*\s])\*\*', '__$1__'
        }
    }

    return $content
}

# Process each file
$changedFiles = 0
$unchangedFiles = 0
$errorFiles = 0
$fixedByMarkdownlint = 0
$configCache = @{}
$backupFiles = 0

foreach ($file in $markdownFiles) {
    Write-Host "Processing $($file.FullName)..." -ForegroundColor Cyan
    $isModified = $false

    try {
        # Find the nearest config file for this specific markdown file
        $nearestConfigFile = Find-NearestConfigFile -filePath $file.FullName

        if ($nearestConfigFile) {
            Write-Host "  ℹ Using config from: $nearestConfigFile" -ForegroundColor Cyan
        } else {
            Write-Host "  ℹ No config found in parent directories" -ForegroundColor Gray
        }

        # Create a backup of the original file if requested
        $backupPath = "$($file.FullName).bak"
        if ($createBackups) {
            Copy-Item -Path $file.FullName -Destination $backupPath -Force -ErrorAction Stop
            $backupFiles++
            Write-Host "  ✓ Created backup at $backupPath" -ForegroundColor Gray
        }

        if ($useMarkdownlint) {
            # Try using markdownlint to fix issues
            $markdownlintArgs = "--fix"

            if ($nearestConfigFile) {
                $markdownlintArgs += " --config `"$nearestConfigFile`""
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

                    # Fix markdown issues with our enhanced function
                    $fixedContent = Fix-CommonMarkdownIssues -content $content -configFile $nearestConfigFile

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

                # Fix markdown issues with our enhanced function
                $fixedContent = Fix-CommonMarkdownIssues -content $content -configFile $nearestConfigFile

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
            $fixedContent = Fix-CommonMarkdownIssues -content $content -configFile $nearestConfigFile

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
            # Remove backup if no changes and backups were created
            if ($createBackups) {
                Remove-Item -Path $backupPath -Force -ErrorAction SilentlyContinue
                $backupFiles--
                Write-Host "  ℹ Removed backup as no changes were made" -ForegroundColor Gray
            }
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
if ($backupFiles -gt 0) {
    Write-Host "  $backupFiles backup files created" -ForegroundColor Cyan
}
if ($errorFiles -gt 0) {
    Write-Host "  $errorFiles files encountered errors" -ForegroundColor Red
}

if ($createBackups -and $backupFiles -gt 0) {
    Write-Host "`nBackup files were created with .bak extension." -ForegroundColor Yellow
    Write-Host "To revert changes, you can run:" -ForegroundColor Yellow
    Write-Host "  Get-ChildItem -Path $rootDirectory -Filter '*.md.bak' -Recurse | ForEach-Object { Move-Item -Path `$_.FullName -Destination `$_.FullName.TrimEnd('.bak') -Force }" -ForegroundColor Gray
}
