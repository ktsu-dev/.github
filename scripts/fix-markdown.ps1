<#
.SYNOPSIS
	Fixes Markdown lint issues in every .md file under a directory, using markdownlint.

.DESCRIPTION
	Each file is passed to `markdownlint --fix` with the nearest markdownlint config found by
	walking up from the file (a .markdownlint.* file in a directory or its .github folder).

	markdownlint is required. This script used to fall back to its own regex rewrites when
	markdownlint was missing or exited non-zero, and those rewrites changed what documents
	rendered: every line became a hard break, code fences were destroyed, snake_case became
	emphasis and nested lists were flattened (ktsu-dev/.github#30). There is no fallback now.

	When markdownlint is missing the script stops before touching any file. When markdownlint
	fixes what it can but violations remain, the file keeps markdownlint's fixes, the remaining
	violations are printed, and the script exits non-zero.

	Install markdownlint with: npm install -g markdownlint-cli

.PARAMETER rootDirectory
	The directory to search for .md files. Defaults to the current directory.

.PARAMETER excludePatterns
	Path fragments to skip. `*` matches any run of characters.

.PARAMETER createBackups
	Write a .md.bak copy of each file before fixing it. Backups of files that did not change
	are removed again.

.EXAMPLE
	./fix-markdown.ps1

.EXAMPLE
	./fix-markdown.ps1 -rootDirectory "C:\custom\path" -excludePatterns @("node_modules", "vendor")
#>
param (
	[Parameter(Mandatory = $false)]
	[string]$rootDirectory = (Get-Location).Path,

	[Parameter(Mandatory = $false)]
	[string[]]$excludePatterns = @(),

	[Parameter(Mandatory = $false)]
	[bool]$createBackups = $false
)

# Find the closest markdownlint config by walking up from the file.
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

	while (-not [string]::IsNullOrEmpty($directory)) {
		foreach ($candidateDir in @($directory, (Join-Path -Path $directory -ChildPath ".github"))) {
			foreach ($configName in $configNames) {
				$configPath = Join-Path -Path $candidateDir -ChildPath $configName
				if (Test-Path -LiteralPath $configPath -PathType Leaf) {
					return $configPath
				}
			}
		}

		$parent = [System.IO.Directory]::GetParent($directory)
		if ($null -eq $parent) {
			break
		}
		$directory = $parent.FullName
	}

	return $null
}

function Get-FileHashOrNull {
	param ([string]$path)
	return (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash
}

$markdownlint = Get-Command "markdownlint" -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $markdownlint) {
	Write-Host "✗ markdownlint was not found on PATH." -ForegroundColor Red
	Write-Host "  Install it with: npm install -g markdownlint-cli" -ForegroundColor Red
	Write-Host "  No files were changed." -ForegroundColor Red
	exit 2
}

Write-Host "Using markdownlint at $($markdownlint.Source)" -ForegroundColor Cyan
Write-Host "Backup creation: $(if ($createBackups) { 'Enabled' } else { 'Disabled' })" -ForegroundColor Cyan

# Create regex pattern for exclusions
$excludeRegex = if ($excludePatterns.Count -gt 0) {
	($excludePatterns | ForEach-Object { [regex]::Escape($_).Replace("\*", ".*") }) -join "|"
} else {
	"^$" # Match nothing by default
}

Write-Host "Scanning for Markdown files in $rootDirectory..." -ForegroundColor Cyan

$markdownFiles = @(Get-ChildItem -Path $rootDirectory -Filter "*.md" -File -Recurse |
	Where-Object { $_.FullName -notmatch $excludeRegex })

if ($markdownFiles.Count -eq 0) {
	Write-Host "No Markdown files found in the workspace." -ForegroundColor Yellow
	exit 0
}

Write-Host "Found $($markdownFiles.Count) Markdown files." -ForegroundColor Green

$changedFiles = 0
$unchangedFiles = 0
$filesWithRemainingIssues = 0
$errorFiles = 0
$backupFiles = 0

foreach ($file in $markdownFiles) {
	Write-Host "Processing $($file.FullName)..." -ForegroundColor Cyan

	try {
		$nearestConfigFile = Find-NearestConfigFile -filePath $file.FullName
		if ($nearestConfigFile) {
			Write-Host "  ℹ Using config from: $nearestConfigFile" -ForegroundColor Cyan
		} else {
			Write-Host "  ℹ No config found in parent directories" -ForegroundColor Gray
		}

		$backupPath = "$($file.FullName).bak"
		if ($createBackups) {
			Copy-Item -LiteralPath $file.FullName -Destination $backupPath -Force -ErrorAction Stop
			$backupFiles++
			Write-Host "  ✓ Created backup at $backupPath" -ForegroundColor Gray
		}

		$before = Get-FileHashOrNull -path $file.FullName

		$markdownlintArgs = @("--fix")
		if ($nearestConfigFile) {
			$markdownlintArgs += @("--config", $nearestConfigFile)
		}
		$markdownlintArgs += @("--", $file.FullName)

		$output = & $markdownlint.Source @markdownlintArgs 2>&1
		$exitCode = $LASTEXITCODE

		$isModified = (Get-FileHashOrNull -path $file.FullName) -ne $before

		if ($isModified) {
			$changedFiles++
			Write-Host "  ✓ Fixed with markdownlint" -ForegroundColor Green
		} else {
			$unchangedFiles++
			if ($createBackups) {
				Remove-Item -LiteralPath $backupPath -Force -ErrorAction SilentlyContinue
				$backupFiles--
				Write-Host "  ℹ Removed backup as no changes were made" -ForegroundColor Gray
			}
		}

		if ($exitCode -ne 0) {
			$filesWithRemainingIssues++
			Write-Host "  ⚠ markdownlint could not fix everything (exit $exitCode); fix these by hand:" -ForegroundColor Yellow
			foreach ($line in $output) {
				Write-Host "    $line" -ForegroundColor Yellow
			}
		} elseif (-not $isModified) {
			Write-Host "  ✓ No issues found" -ForegroundColor Gray
		}
	}
	catch {
		Write-Host "  ✗ Error processing file: $_" -ForegroundColor Red
		$errorFiles++
	}
}

Write-Host "`nOperation completed:" -ForegroundColor Cyan
Write-Host "  $changedFiles files fixed" -ForegroundColor Green
Write-Host "  $unchangedFiles files unchanged" -ForegroundColor Gray
if ($backupFiles -gt 0) {
	Write-Host "  $backupFiles backup files created" -ForegroundColor Cyan
}
if ($filesWithRemainingIssues -gt 0) {
	Write-Host "  $filesWithRemainingIssues files still have issues markdownlint cannot fix" -ForegroundColor Yellow
}
if ($errorFiles -gt 0) {
	Write-Host "  $errorFiles files encountered errors" -ForegroundColor Red
}

if ($createBackups -and $backupFiles -gt 0) {
	Write-Host "`nBackup files were created with .bak extension." -ForegroundColor Yellow
	Write-Host "To revert changes, you can run:" -ForegroundColor Yellow
	Write-Host "  Get-ChildItem -Path $rootDirectory -Filter '*.md.bak' -Recurse | ForEach-Object { Move-Item -Path `$_.FullName -Destination (`$_.FullName -replace '\.bak$', '') -Force }" -ForegroundColor Gray
}

if ($errorFiles -gt 0 -or $filesWithRemainingIssues -gt 0) {
	exit 1
}

exit 0
