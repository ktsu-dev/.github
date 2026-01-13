# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is the `.github` repository for the ktsu-dev organization. It contains:

- **Organization profile README**: Generated markdown table showcasing all ktsu.dev libraries with their status badges
- **Shared scripts**: PowerShell utilities for repository management, documentation, and markdown linting
- **GitHub Actions workflows**: Automated README generation from repository metadata
- **Configuration files**: Shared `.editorconfig` and `.markdownlint.json` settings

The primary purpose is to maintain the organization's public profile page at https://github.com/ktsu-dev.

## Key Commands

### Update Organization README

```powershell
# Regenerate the profile README with current repository status
./.github/workflows/update-readme.ps1
```

This script:
- Fetches all public repositories from the ktsu-dev organization using `gh api`
- Skips archived repositories
- Generates a markdown table with version badges, download counts, activity metrics, and build status
- Uses `./profile/README.template` as the base content
- Outputs to `./profile/README.md`

### Fetch Repository Metadata

```powershell
# Get comprehensive data about all ktsu-dev repositories
# Automatically uses GitHub CLI (gh) authentication if available
./scripts/get-github-repos.ps1 -GitHubUserOrOrg "ktsu-dev"

# With explicit GitHub token for higher rate limits
./scripts/get-github-repos.ps1 -GitHubUserOrOrg "ktsu-dev" -GitHubToken "ghp_xxxxx"

# Include archived and forked repositories
./scripts/get-github-repos.ps1 -GitHubUserOrOrg "ktsu-dev" -IncludeArchived -IncludeForks
```

This script retrieves detailed information including README content, languages, topics, releases, contributors, and repository statistics. Output is saved as JSON.

**Authentication**: The script automatically uses GitHub CLI authentication (`gh auth token`) if available, falling back to unauthenticated requests. Authenticated requests have much higher rate limits (5000/hour vs 60/hour).

**Rate Limiting**: Includes graceful rate limit handling with automatic waiting, exponential backoff for errors, and detailed status reporting.

### Fix Markdown Issues

```powershell
# Fix markdown linting issues in all .md files
./scripts/fix-markdown.ps1

# With custom root directory
./scripts/fix-markdown.ps1 -rootDirectory "C:\custom\path"

# Create backups before fixing
./scripts/fix-markdown.ps1 -createBackups $true

# Exclude specific patterns
./scripts/fix-markdown.ps1 -excludePatterns @("node_modules", "vendor")
```

This script:
- Searches for `.markdownlint.json` config files by traversing up from each file
- Uses `markdownlint` CLI if available, otherwise falls back to built-in PowerShell fixes
- Supports all major markdownlint rules (MD004, MD007, MD009, MD012, MD018, MD019, MD022, MD023, MD026, MD027, MD030, MD031, MD032, MD035, MD037, MD038, MD039, MD040, MD046, MD047, MD048, MD049, MD050)
- Parses JSON/JSONC config files to respect project-specific settings

## Architecture

### Workflow Automation

**update-readme.yml** (`.github/workflows/update-readme.yml`):
- Triggered on push, daily schedule (cron: `0 0 * * *`), and manual dispatch
- Runs on Windows (requires PowerShell)
- Commits and pushes changes with `[skip ci][bot]` prefix
- Uses GitHub token for API access

### Script Organization

**PowerShell Scripts** (`scripts/`):
- `get-github-repos.ps1`: Comprehensive GitHub API client for organization/user repository metadata with automatic gh CLI authentication and graceful rate limiting
- `fix-markdown.ps1`: Advanced markdown linting and auto-fixing with config file support
- `clean-python-cache.ps1`: Utility for cleaning Python cache directories
- `discard-changes.ps1`: Git utility for discarding changes
- `update-docs.ps1`: Documentation update automation

### Configuration Files

**.editorconfig**: Comprehensive code style configuration
- .NET: Tab indentation, file-scoped namespaces, error-level enforcement of code style rules
- C++: Unreal Engine naming conventions (AActors, SWidgets, UObjects, FStructs, EEnums, TTemplates, bBooleans)
- PowerShell: Tab indentation, 4 space tab width
- JSON/YAML: 2 space indentation
- CRLF line endings (Windows-first development)

**.markdownlint.json**: Markdown linting rules configuration
- Located at repository root
- Scripts search for nearest config by traversing up directory tree

### Organization Context

**ktsu.dev** is a collection of 50+ .NET libraries focused on:
- Strong typing and semantic clarity
- Simplified APIs that eliminate boilerplate
- Modern .NET 8+ features
- Physics calculations, ImGui UI frameworks, persistence, serialization, and utilities

Libraries are distributed as NuGet packages under the `ktsu.*` namespace.

## Development Notes

- This repository uses GitHub CLI (`gh`) extensively for API interactions
- PowerShell scripts are the primary automation tool (Windows-first environment)
- The organization profile README is auto-generated and should not be manually edited
- All repositories follow the .editorconfig standards defined here
- Markdown linting is enforced with auto-fix capabilities
