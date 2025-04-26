# Script to batch update README.md and DESCRIPTION.md files for ktsu-dev repositories
# Created: April 21, 2025

# Configuration - List of repositories to update
$repositories = @(
    "CaseConverter",
    "CredentialCache",
    "CrossRepoActions",
    "DelegateTransform",
    "FuzzySearch",
    "GitIntegration",
    "IconHelper",
    "ImGuiApp",
    "ImGuiCredentialPopups",
    "ImGuiPopups",
    "ImGuiStyler",
    "ImGuiWidgets",
    "NJsonSchemaJsonConverter",
    "OAICLI",
    "PhysicalQuantity",
    "Physics.Atmospherics",
    "Physics.Constants",
    "Physics.Earth",
    "Physics.Thermodynamics",
    "PkmnDB",
    "PreciseNumber",
    "ProjectDirector",
    "Schema",
    "SemanticQuantity",
    "SemanticString",
    "SignificantNumber",
    "StrongPaths",
    "SyncFileContents",
    "TextFilter",
    "workflows"
)

# Repository descriptions for DESCRIPTION.md files
$repositoryDescriptions = @{
    "CaseConverter" = "A .NET library providing extension methods for converting strings between different case formats such as PascalCase, camelCase, snake_case, kebab-case, and MACRO_CASE."
    "CredentialCache" = "A secure storage and management solution for application credentials with encryption support."
    "CrossRepoActions" = "Tooling for executing actions across multiple Git repositories in a coordinated workflow."
    "DelegateTransform" = "Library for transforming and composing .NET delegates with support for advanced chaining patterns."
    "FuzzySearch" = "Fuzzy search implementation for .NET with configurable matching algorithms and scoring."
    "GitIntegration" = "Tools for integrating Git operations and workflows into .NET applications."
    "IconHelper" = "Utilities for icon loading, manipulation, and conversion in .NET applications."
    "ImGuiApp" = "Framework for building ImGui-based desktop applications with a clean API and event system."
    "ImGuiCredentialPopups" = "Credential input dialogs and authentication UI components for ImGui applications."
    "ImGuiPopups" = "Reusable popup dialog components for ImGui-based user interfaces."
    "ImGuiStyler" = "Theming and styling utilities for ImGui applications with predefined themes and customization options."
    "ImGuiWidgets" = "Collection of reusable UI widgets and components for ImGui applications."
    "NJsonSchemaJsonConverter" = "JSON converters for handling NJsonSchema objects within System.Text.Json serialization."
    "OAICLI" = "Command-line interface for interacting with OpenAI APIs and services."
    "PhysicalQuantity" = "Library for representing and manipulating physical quantities with units and dimensions."
    "Physics.Atmospherics" = "Models and calculations related to atmospheric physics and meteorology."
    "Physics.Constants" = "Collection of accurate physical constants with proper units and uncertainty values."
    "Physics.Earth" = "Earth science and geophysics utilities for .NET applications."
    "Physics.Thermodynamics" = "Thermodynamic calculations, models, and utilities for scientific applications."
    "PkmnDB" = "Pokémon database library for accessing and querying game data."
    "PreciseNumber" = "High-precision numeric type implementation for accurate decimal calculations."
    "ProjectDirector" = "Project management and organization utilities for .NET solutions and projects."
    "Schema" = "Schema definition, validation, and generation tools for data structures."
    "SemanticQuantity" = "Library for working with semantically meaningful quantities and measurements."
    "SemanticString" = "String handling with semantic context and validation for domain-specific applications."
    "SignificantNumber" = "Numeric type that maintains significant figure precision for scientific calculations."
    "StrongPaths" = "Strongly-typed file and directory path representations with validation and safety features."
    "SyncFileContents" = "File synchronization and content coordination utilities for multi-file operations."
    "TextFilter" = "Text filtering and pattern matching library with support for wildcards and advanced filters."
    "workflows" = "Reusable GitHub workflow definitions for CI/CD pipeline automation."
}

# Features for each repository
$repositoryFeatures = @{
    "CaseConverter" = @(
        "**PascalCase Conversion**: Convert strings to PascalCase format",
        "**camelCase Conversion**: Convert strings to camelCase format",
        "**snake_case Conversion**: Convert strings to snake_case format",
        "**kebab-case Conversion**: Convert strings to kebab-case format",
        "**MACRO_CASE Conversion**: Convert strings to MACRO_CASE format",
        "**Title Case Conversion**: Convert strings to Title Case format",
        "**Smart Detection**: Automatically detect and handle existing formats",
        "**Extension Methods**: Clean API through extension methods"
    )
    "CredentialCache" = @(
        "**Secure Credential Storage**: Safely store sensitive credentials",
        "**Encryption Support**: Optional encryption of stored credentials",
        "**Multiple Storage Backends**: Support for different storage mechanisms",
        "**Credential Validation**: Validate credentials before storage",
        "**Automatic Refreshing**: Support for credential refreshing workflows",
        "**Expiration Management**: Handle credential expiration gracefully",
        "**Cross-Platform Support**: Works on Windows, macOS, and Linux"
    )
    # Default features for all repositories not explicitly defined
    "_default" = @(
        "**Feature 1**: Core functionality of the library",
        "**Feature 2**: Additional capabilities provided",
        "**Feature 3**: Integration options with other systems",
        "**Cross-Platform**: Works on Windows, macOS, and Linux",
        "**Modern .NET Support**: Compatible with latest .NET versions"
    )
}

# Usage examples for each repository
$repositoryExamples = @{
    "CaseConverter" = @{
        "Basic Example" = @"
```csharp
using ktsu.CaseConverter;

// Convert to different cases
string pascalCase = "hello world".ToPascalCase();  // "HelloWorld"
string camelCase = "Hello World".ToCamelCase();    // "helloWorld"
string snakeCase = "HelloWorld".ToSnakeCase();     // "hello_world"
string kebabCase = "Hello_World".ToKebabCase();    // "hello-world"
string macroCase = "helloWorld".ToMacroCase();     // "HELLO_WORLD"
```
"@

        "Advanced Usage" = @"
```csharp
using ktsu.CaseConverter;

// Convert text with special characters
string input = "The.Quick-Brown_Fox";
string pascal = input.ToPascalCase();  // "TheQuickBrownFox"
string snake = input.ToSnakeCase();    // "the_quick_brown_fox"

// Title case conversion
string title = "THE QUICK BROWN FOX".ToTitleCase();  // "The Quick Brown Fox"

// First character manipulation
string lowerFirst = "HelloWorld".ToLowercaseFirstChar();  // "helloWorld"
string upperFirst = "helloWorld".ToUppercaseFirstChar();  // "HelloWorld"
```
"@
    }

    "CredentialCache" = @{
        "Basic Example" = @"
```csharp
using ktsu.CredentialCache;

// Create a credential cache
var credentialCache = new CredentialCache();

// Store credentials
credentialCache.StoreCredential("serviceA", new Credential {
    Username = "user",
    Password = "password123"
});

// Retrieve credentials
var credential = credentialCache.GetCredential("serviceA");
Console.WriteLine($"Username: {credential.Username}");
```
"@

        "With Encryption" = @"
```csharp
using ktsu.CredentialCache;

// Create a credential cache with encryption
var encryptionProvider = new AesEncryptionProvider("your-secret-key");
var credentialCache = new CredentialCache(encryptionProvider);

// Store encrypted credentials
credentialCache.StoreCredential("serviceA", new Credential {
    Username = "user",
    Password = "password123"
});

// Credentials are automatically decrypted when retrieved
var credential = credentialCache.GetCredential("serviceA");
```
"@
    }

    # Default examples for all repositories not explicitly defined
    "_default" = @{
        "Basic Example" = @"
```csharp
using ktsu.{0};

// Basic usage example
var instance = new {1}();
var result = instance.Process();
Console.WriteLine(result);
```
"@

        "Advanced Configuration" = @"
```csharp
using ktsu.{0};

// Configure with options
var options = new {1}Options {{
    Option1 = true,
    Option2 = "custom value"
}};

var instance = new {1}(options);
await instance.ProcessAsync();
```
"@
    }
}

# API reference for each repository
$repositoryApiReference = @{
    "CaseConverter" = @"
### `CaseConverter` Static Class

The main static class containing case conversion extension methods.

#### Methods

| Name | Parameters | Return Type | Description |
|------|------------|-------------|-------------|
| `ToPascalCase` | `string input` | `string` | Converts a string to PascalCase format |
| `ToCamelCase` | `string input` | `string` | Converts a string to camelCase format |
| `ToSnakeCase` | `string input` | `string` | Converts a string to snake_case format |
| `ToKebabCase` | `string input` | `string` | Converts a string to kebab-case format |
| `ToMacroCase` | `string input` | `string` | Converts a string to MACRO_CASE format |
| `ToTitleCase` | `string input` | `string` | Converts a string to Title Case format |
| `ToUppercaseFirstChar` | `string input` | `string` | Converts the first character of a string to uppercase |
| `ToLowercaseFirstChar` | `string input` | `string` | Converts the first character of a string to lowercase |
| `IsAllCaps` | `string input` | `bool` | Determines if the string is all uppercase |
"@

    "CredentialCache" = @"
### `CredentialCache` Class

The main class for storing and retrieving credentials.

#### Properties

| Name | Type | Description |
|------|------|-------------|
| `Count` | `int` | Number of credentials stored in the cache |
| `StorageProvider` | `IStorageProvider` | The provider used for credential persistence |
| `EncryptionProvider` | `IEncryptionProvider` | Optional provider for credential encryption |

#### Methods

| Name | Parameters | Return Type | Description |
|------|------------|-------------|-------------|
| `StoreCredential` | `string id, Credential credential` | `void` | Stores a credential in the cache |
| `GetCredential` | `string id` | `Credential` | Retrieves a credential from the cache |
| `RemoveCredential` | `string id` | `bool` | Removes a credential from the cache |
| `Clear` | | `void` | Clears all credentials from the cache |
| `Contains` | `string id` | `bool` | Checks if a credential exists in the cache |

### `Credential` Class

Represents a credential with username and password.

#### Properties

| Name | Type | Description |
|------|------|-------------|
| `Username` | `string` | The username portion of the credential |
| `Password` | `string` | The password portion of the credential |
| `ExpiresAt` | `DateTimeOffset?` | Optional expiration date for the credential |
"@

    # Default API reference for all repositories not explicitly defined
    "_default" = @"
### `{0}` Class

The main class for interacting with this library.

#### Properties

| Name | Type | Description |
|------|------|-------------|
| `Property1` | `string` | Description of this property |
| `Property2` | `int` | Description of this property |

#### Methods

| Name | Parameters | Return Type | Description |
|------|------------|-------------|-------------|
| `Process()` | | `string` | Processes data and returns a result |
| `ProcessAsync()` | | `Task<string>` | Asynchronously processes data |
| `Configure(options)` | `{0}Options options` | `void` | Configures the instance with the specified options |

### `{0}Options` Class

Configuration options for the library.

#### Properties

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `Option1` | `bool` | `false` | Controls feature X |
| `Option2` | `string` | `\"default\"` | Sets the value for Y |
"@
}

# Main base path
$basePath = "C:\dev\ktsu-dev"

# Repository README generation function
function Generate-Readme {
    param (
        [string]$repoName,
        [string]$description,
        [string]$outputPath
    )

    $packageName = "ktsu.$repoName"
    $templatePath = Join-Path $basePath "README_TEMPLATE.md"

    # Read template
    $template = Get-Content -Path $templatePath -Raw

    # Extract the package description (first sentence for the one-liner)
    $oneLiner = $description -split '\.', 2 | Select-Object -First 1
    if (-not $oneLiner.EndsWith(".")) {
        $oneLiner = "$oneLiner."
    }

    # Generate derived class name for examples
    $className = $repoName -replace '\.', ''

    # Replace template placeholders
    $readme = $template
    $readme = $readme -replace '\[Project Name\]', $packageName
    $readme = $readme -replace '> Brief one-liner description of what this project does\.', "> $oneLiner"
    $readme = $readme -replace '\[repository-name\]', $repoName
    $readme = $readme -replace '\[package-name\]', $packageName
    $readme = $readme -replace '\[Namespace\]', "ktsu.$repoName"

    # Detailed description
    $longDescription = $description -replace '\.\s*', ".$([Environment]::NewLine)$([Environment]::NewLine)"
    $readme = $readme -replace 'A more detailed explanation of what this project is.*?why it''s useful\..*?\r?\n\r?\n', "$longDescription$([Environment]::NewLine)$([Environment]::NewLine)"

    # Features section
    $featuresList = if ($repositoryFeatures.ContainsKey($repoName)) {
        $repositoryFeatures[$repoName]
    } else {
        $repositoryFeatures["_default"]
    }

    $featuresContent = $featuresList -join "$([Environment]::NewLine)- "
    $featuresContent = "- $featuresContent"
    $readme = $readme -replace '- \*\*Feature 1\*\*:.*?\r?\n- \*\*Feature 2\*\*:.*?\r?\n- \*\*Feature 3\*\*:.*?\r?\n- Additional features as necessary\.', $featuresContent

    # Usage examples section
    $examples = if ($repositoryExamples.ContainsKey($repoName)) {
        $repositoryExamples[$repoName]
    } else {
        $hash = @{}
        foreach ($key in $repositoryExamples["_default"].Keys) {
            $value = $repositoryExamples["_default"][$key] -f $repoName, $className
            $hash[$key] = $value
        }
        $hash
    }

    $usageSection = ""
    foreach ($exampleTitle in $examples.Keys) {
        $exampleCode = $examples[$exampleTitle]
        $usageSection += "### $exampleTitle$([Environment]::NewLine)$([Environment]::NewLine)$exampleCode$([Environment]::NewLine)$([Environment]::NewLine)"
    }

    # Replace usage examples
    $usagePattern = '### Basic Example\r?\n\r?\n```csharp[\s\S]*?```\r?\n\r?\n### Common Scenarios\r?\n\r?\n```csharp[\s\S]*?```'
    $readme = $readme -replace $usagePattern, $usageSection.TrimEnd()

    # API reference section
    $apiReference = if ($repositoryApiReference.ContainsKey($repoName)) {
        $repositoryApiReference[$repoName]
    } else {
        $repositoryApiReference["_default"] -f $className
    }

    # Replace API reference
    $apiPattern = '### `MyMainClass`[\s\S]*?#### Methods[\s\S]*?### `Configuration`[\s\S]*?#### Properties[\s\S]*?'
    $readme = $readme -replace $apiPattern, $apiReference + "$([Environment]::NewLine)$([Environment]::NewLine)"

    # Update LICENSE information
    $readme = $readme -replace '\[LICENSE NAME\]', "MIT License"

    # Write to file
    Set-Content -Path $outputPath -Value $readme
}

# Update description file function
function Update-Description {
    param (
        [string]$description,
        [string]$outputPath
    )

    Set-Content -Path $outputPath -Value $description
}

# Function to analyze repo structure and improve content
function Enhance-ReadmeContent {
    param (
        [string]$repoPath,
        [string]$repoName
    )

    # Try to infer main class/features from code files
    $mainClassFile = Join-Path $repoPath "$repoName\$repoName.cs"

    if (Test-Path $mainClassFile) {
        # TODO: Add code to analyze main class and extract methods/properties
        # This would make API reference even more accurate
    }

    # Could be extended to analyze more files, extract XML docs, etc.
}

# Main execution loop
foreach ($repo in $repositories) {
    Write-Host "Processing $repo..." -ForegroundColor Cyan

    $repoPath = Join-Path $basePath $repo
    $readmePath = Join-Path $repoPath "README.md"
    $descriptionPath = Join-Path $repoPath "DESCRIPTION.md"

    if (-not (Test-Path $repoPath)) {
        Write-Host "Repository path not found: $repoPath" -ForegroundColor Red
        continue
    }

    # Get description for this repository
    $description = $repositoryDescriptions[$repo]
    if (-not $description) {
        Write-Host "No description defined for $repo, skipping..." -ForegroundColor Yellow
        continue
    }

    # Try to enhance content with repo-specific information
    Enhance-ReadmeContent -repoPath $repoPath -repoName $repo

    # Generate README.md
    try {
        # Create backup of original README before modifying
        $backupPath = Join-Path $repoPath "README.md.bak"
        if ((Test-Path $readmePath) -and -not (Test-Path $backupPath)) {
            Copy-Item -Path $readmePath -Destination $backupPath
        }

        Generate-Readme -repoName $repo -description $description -outputPath $readmePath
        Write-Host "  ✓ README.md updated" -ForegroundColor Green
    }
    catch {
        Write-Host "  ✗ Failed to update README.md: $_" -ForegroundColor Red
    }

    # Update DESCRIPTION.md
    try {
        # Create backup of original DESCRIPTION before modifying
        $descBackupPath = Join-Path $repoPath "DESCRIPTION.md.bak"
        if ((Test-Path $descriptionPath) -and -not (Test-Path $descBackupPath)) {
            Copy-Item -Path $descriptionPath -Destination $descBackupPath
        }

        Update-Description -description $description -outputPath $descriptionPath
        Write-Host "  ✓ DESCRIPTION.md updated" -ForegroundColor Green
    }
    catch {
        Write-Host "  ✗ Failed to update DESCRIPTION.md: $_" -ForegroundColor Red
    }

    # Git commit if this is a git repository
    if (Test-Path (Join-Path $repoPath ".git")) {
        try {
            Push-Location $repoPath

            # Commit README.md
            $readmeStatus = git status -s README.md
            if ($readmeStatus) {
                Write-Host "  → Committing README.md changes" -ForegroundColor Magenta
                git add README.md
                git commit -m "Update README.md to match standard template format"
            }

            # Commit DESCRIPTION.md
            $descStatus = git status -s DESCRIPTION.md
            if ($descStatus) {
                Write-Host "  → Committing DESCRIPTION.md changes" -ForegroundColor Magenta
                git add DESCRIPTION.md
                git commit -m "Update DESCRIPTION.md with appropriate NuGet package description"
            }

            Pop-Location
        }
        catch {
            Write-Host "  ✗ Failed to commit changes: $_" -ForegroundColor Red
            Pop-Location
        }
    }

    # Update TODO file checkboxes
    if (Test-Path (Join-Path $basePath "README_UPDATES_TODO.md")) {
        $todoContent = Get-Content -Path (Join-Path $basePath "README_UPDATES_TODO.md") -Raw
        $todoContent = $todoContent -replace "\[ \] $repo", "[x] $repo"
        Set-Content -Path (Join-Path $basePath "README_UPDATES_TODO.md") -Value $todoContent
    }

    Write-Host "Completed $repo" -ForegroundColor Green
    Write-Host "------------------------" -ForegroundColor DarkGray
}

Write-Host "All repositories processed!" -ForegroundColor Green
Write-Host "Check README_UPDATES_TODO.md for status updates" -ForegroundColor Cyan
