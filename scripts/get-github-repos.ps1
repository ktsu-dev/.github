<#
.SYNOPSIS
    Fetches comprehensive data about all public repositories for a GitHub user or organization.

.DESCRIPTION
    This script uses the GitHub API to retrieve detailed information about all public repositories
    for a specified GitHub user or organization. It includes repository metadata, topics, languages,
    README content, and other contextual information.

    The script includes graceful rate limiting handling:
    - Checks rate limit status before starting and monitors it throughout execution
    - Automatically waits for rate limit reset when exhausted
    - Implements exponential backoff for secondary rate limits (429 errors)
    - Retries failed requests due to server errors with exponential backoff
    - Provides clear feedback about rate limit status and wait times

.PARAMETER GitHubUserOrOrg
    The GitHub username or organization name to fetch repositories for. This is a positional parameter.

.PARAMETER OutputPath
    The path where the summary JSON output file will be saved. Defaults to "github-repos-{username}-summary.json".

.PARAMETER OutputDirectory
    The directory where individual repository detail files will be saved. Defaults to "github-repos-{username}" in the current directory.
    Each repository will have its own JSON file named "{repo-name}.json" containing full details.

.PARAMETER GitHubToken
    Optional GitHub personal access token for higher rate limits and access to additional data.
    If not provided, the script will automatically attempt to use authentication from GitHub CLI (gh).
    If GitHub CLI is not authenticated, the script will use unauthenticated requests (lower rate limit).

.PARAMETER IncludeArchived
    Include archived repositories in the results. Default is false.

.PARAMETER IncludeForks
    Include forked repositories in the results. Default is false.

.PARAMETER Help
    Display this help information and exit.

.EXAMPLE
    .\get-github-repos.ps1 -GitHubUserOrOrg "octocat"
    Uses GitHub CLI authentication if available, otherwise unauthenticated.

.EXAMPLE
    .\get-github-repos.ps1 -GitHubUserOrOrg "microsoft" -GitHubToken "ghp_xxxxxxxxxxxx" -IncludeArchived -OutputPath "microsoft-repos-summary.json" -OutputDirectory "microsoft-repos"
    Uses explicit token for authentication and specifies custom output paths.

.EXAMPLE
    .\get-github-repos.ps1 octocat
    Uses positional parameter for username and automatic GitHub CLI authentication.

.EXAMPLE
    .\get-github-repos.ps1 -Help
    .\get-github-repos.ps1 --help
    .\get-github-repos.ps1 -h
    Display help information using various methods.
#>

param(
    [Parameter(Mandatory = $false, Position = 0)]
    [string]$GitHubUserOrOrg,

    [Parameter(Mandatory = $false)]
    [string]$OutputPath = "",

    [Parameter(Mandatory = $false)]
    [string]$OutputDirectory = "",

    [Parameter(Mandatory = $false)]
    [string]$GitHubToken = "",

    [Parameter(Mandatory = $false)]
    [switch]$IncludeArchived = $false,

    [Parameter(Mandatory = $false)]
    [switch]$IncludeForks = $false,

    [Parameter(Mandatory = $false)]
    [switch]$Help = $false
)

# Handle help parameter or --help argument
# Check both the parameter and any raw arguments passed to the script
if ($Help -or $GitHubUserOrOrg -eq "--help" -or $GitHubUserOrOrg -eq "-h" -or $GitHubUserOrOrg -eq "help") {
    Get-Help $MyInvocation.MyCommand.Path -Full
    exit 0
}

# Validate required parameters
if (-not $GitHubUserOrOrg) {
    Write-Error "GitHubUserOrOrg parameter is required. Use -Help for usage information."
    exit 1
}

# Set default output paths if not provided
if (-not $OutputPath) {
    $OutputPath = "github-repos-$GitHubUserOrOrg-summary.json"
}

if (-not $OutputDirectory) {
    $OutputDirectory = "github-repos-$GitHubUserOrOrg"
}

# Create output directory if it doesn't exist
if (-not (Test-Path -Path $OutputDirectory)) {
    Write-Host "Creating output directory: $OutputDirectory"
    New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
}

# Global variable to track rate limit information
$script:RateLimitInfo = @{
    Remaining = $null
    Limit = $null
    Reset = $null
    LastChecked = $null
}

# Function to get current rate limit status
function Get-RateLimitStatus {
    param(
        [hashtable]$Headers
    )

    try {
        $rateLimitUri = "https://api.github.com/rate_limit"
        $response = Invoke-RestMethod -Uri $rateLimitUri -Headers $Headers -ErrorAction Stop

        $coreLimit = $response.resources.core

        return @{
            Remaining = $coreLimit.remaining
            Limit = $coreLimit.limit
            Reset = [DateTimeOffset]::FromUnixTimeSeconds($coreLimit.reset).LocalDateTime
            Used = $coreLimit.used
        }
    }
    catch {
        Write-Warning "Failed to get rate limit status: $($_.Exception.Message)"
        return $null
    }
}

# Function to wait for rate limit reset
function Wait-ForRateLimitReset {
    param(
        [DateTime]$ResetTime
    )

    $now = Get-Date
    $waitTime = ($ResetTime - $now).TotalSeconds

    if ($waitTime -gt 0) {
        Write-Host "`nRate limit exceeded. Waiting until reset at $($ResetTime.ToString('HH:mm:ss'))..." -ForegroundColor Yellow
        Write-Host "Wait time: $([Math]::Ceiling($waitTime)) seconds" -ForegroundColor Yellow

        # Wait in chunks to show progress
        $remainingSeconds = [Math]::Ceiling($waitTime)
        while ($remainingSeconds -gt 0) {
            $minutes = [Math]::Floor($remainingSeconds / 60)
            $seconds = $remainingSeconds % 60
            Write-Progress -Activity "Waiting for rate limit reset" -Status "Time remaining: $minutes minutes $seconds seconds" -PercentComplete ((($waitTime - $remainingSeconds) / $waitTime) * 100)
            Start-Sleep -Seconds 1
            $remainingSeconds--
        }

        Write-Progress -Activity "Waiting for rate limit reset" -Completed
        Write-Host "Rate limit reset. Resuming requests..." -ForegroundColor Green
    }
}

# Function to update rate limit info from response headers
function Update-RateLimitFromHeaders {
    param(
        $Headers
    )

    if ($Headers) {
        try {
            # Access headers from Invoke-WebRequest response
            $remaining = $null
            $limit = $null
            $reset = $null

            if ($Headers["X-RateLimit-Remaining"]) {
                $remaining = $Headers["X-RateLimit-Remaining"]
                if ($remaining -is [array]) {
                    $remaining = $remaining[0]
                }
            }

            if ($Headers["X-RateLimit-Limit"]) {
                $limit = $Headers["X-RateLimit-Limit"]
                if ($limit -is [array]) {
                    $limit = $limit[0]
                }
            }

            if ($Headers["X-RateLimit-Reset"]) {
                $reset = $Headers["X-RateLimit-Reset"]
                if ($reset -is [array]) {
                    $reset = $reset[0]
                }
            }

            if ($remaining -and $limit -and $reset) {
                $script:RateLimitInfo.Remaining = [int]$remaining
                $script:RateLimitInfo.Limit = [int]$limit
                $script:RateLimitInfo.Reset = [DateTimeOffset]::FromUnixTimeSeconds([long]$reset).LocalDateTime
                $script:RateLimitInfo.LastChecked = Get-Date
            }
        }
        catch {
            # Headers might not be available or parseable, silently continue
        }
    }
}

# Function to make GitHub API requests with proper error handling and rate limiting
function Invoke-GitHubApi {
    param(
        [string]$Uri,
        [hashtable]$Headers = @{},
        [int]$MaxRetries = 3
    )

    $retryCount = 0
    $baseDelaySeconds = 2

    while ($retryCount -le $MaxRetries) {
        try {
            # Check rate limit before making request
            if ($script:RateLimitInfo.Remaining -ne $null -and $script:RateLimitInfo.Remaining -lt 5) {
                Write-Host "Approaching rate limit ($($script:RateLimitInfo.Remaining) requests remaining). Checking status..." -ForegroundColor Yellow
                $rateLimitStatus = Get-RateLimitStatus -Headers $Headers

                if ($rateLimitStatus -and $rateLimitStatus.Remaining -eq 0) {
                    Wait-ForRateLimitReset -ResetTime $rateLimitStatus.Reset
                }
            }

            # Make the request using Invoke-WebRequest to get headers
            $webResponse = Invoke-WebRequest -Uri $Uri -Headers $Headers -ErrorAction Stop

            # Update rate limit info from response headers
            Update-RateLimitFromHeaders -Headers $webResponse.Headers

            # Parse JSON response
            $response = $webResponse.Content | ConvertFrom-Json

            # Display rate limit info periodically
            if ($script:RateLimitInfo.Remaining -ne $null -and $script:RateLimitInfo.LastChecked) {
                $timeSinceCheck = (Get-Date) - $script:RateLimitInfo.LastChecked
                if ($timeSinceCheck.TotalMinutes -ge 1) {
                    Write-Host "Rate limit: $($script:RateLimitInfo.Remaining)/$($script:RateLimitInfo.Limit) requests remaining" -ForegroundColor Cyan
                    $script:RateLimitInfo.LastChecked = Get-Date
                }
            }

            return $response
        }
        catch {
            $statusCode = $_.Exception.Response.StatusCode.value__

            if ($statusCode -eq 404) {
                Write-Warning "Resource not found: $Uri"
                return $null
            }
            elseif ($statusCode -eq 403) {
                # Check if this is a rate limit error
                $rateLimitStatus = Get-RateLimitStatus -Headers $Headers

                if ($rateLimitStatus -and $rateLimitStatus.Remaining -eq 0) {
                    Write-Host "Rate limit exceeded (403 Forbidden). Waiting for reset..." -ForegroundColor Yellow
                    Wait-ForRateLimitReset -ResetTime $rateLimitStatus.Reset
                    $retryCount++
                    continue
                }
                else {
                    Write-Warning "Access forbidden (403): $Uri"
                    return $null
                }
            }
            elseif ($statusCode -eq 429) {
                # Secondary rate limiting
                Write-Host "Secondary rate limit hit (429 Too Many Requests). Implementing exponential backoff..." -ForegroundColor Yellow
                $retryCount++

                if ($retryCount -le $MaxRetries) {
                    $delaySeconds = $baseDelaySeconds * [Math]::Pow(2, $retryCount - 1)
                    Write-Host "Retry $retryCount/$MaxRetries - Waiting $delaySeconds seconds..." -ForegroundColor Yellow
                    Start-Sleep -Seconds $delaySeconds
                    continue
                }
                else {
                    Write-Error "Max retries exceeded for $Uri after hitting secondary rate limit"
                    return $null
                }
            }
            elseif ($statusCode -ge 500) {
                # Server error - retry with exponential backoff
                $retryCount++

                if ($retryCount -le $MaxRetries) {
                    $delaySeconds = $baseDelaySeconds * [Math]::Pow(2, $retryCount - 1)
                    Write-Host "Server error ($statusCode). Retry $retryCount/$MaxRetries - Waiting $delaySeconds seconds..." -ForegroundColor Yellow
                    Start-Sleep -Seconds $delaySeconds
                    continue
                }
                else {
                    Write-Error "Max retries exceeded for $Uri due to server errors"
                    return $null
                }
            }
            else {
                Write-Error "Failed to fetch data from $Uri : $($_.Exception.Message)"
                return $null
            }
        }
    }

    return $null
}

# Function to get README content
function Get-ReadmeContent {
    param(
        [string]$Owner,
        [string]$RepoName,
        [hashtable]$Headers
    )
    
    $readmeUri = "https://api.github.com/repos/$Owner/$RepoName/readme"
    $readme = Invoke-GitHubApi -Uri $readmeUri -Headers $Headers
    
    if ($readme -and $readme.content) {
        try {
            # Decode base64 content
            $decodedContent = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($readme.content))
            return @{
                name = $readme.name
                path = $readme.path
                content = $decodedContent
                size = $readme.size
                encoding = $readme.encoding
            }
        }
        catch {
            Write-Warning "Failed to decode README content for $Owner/$RepoName"
            return $null
        }
    }
    
    return $null
}

# Function to get repository languages
function Get-RepoLanguages {
    param(
        [string]$Owner,
        [string]$RepoName,
        [hashtable]$Headers
    )
    
    $languagesUri = "https://api.github.com/repos/$Owner/$RepoName/languages"
    return Invoke-GitHubApi -Uri $languagesUri -Headers $Headers
}

# Function to get repository topics
function Get-RepoTopics {
    param(
        [string]$Owner,
        [string]$RepoName,
        [hashtable]$Headers
    )
    
    $topicsUri = "https://api.github.com/repos/$Owner/$RepoName/topics"
    $topicsHeaders = $Headers.Clone()
    $topicsHeaders["Accept"] = "application/vnd.github.mercy-preview+json"
    
    $topics = Invoke-GitHubApi -Uri $topicsUri -Headers $topicsHeaders
    return $topics.names
}

# Function to get release information
function Get-RepoReleases {
    param(
        [string]$Owner,
        [string]$RepoName,
        [hashtable]$Headers
    )
    
    $releasesUri = "https://api.github.com/repos/$Owner/$RepoName/releases?per_page=5"
    $releases = Invoke-GitHubApi -Uri $releasesUri -Headers $Headers
    
    if ($releases) {
        return $releases | ForEach-Object {
            @{
                name = $_.name
                tag_name = $_.tag_name
                published_at = $_.published_at
                prerelease = $_.prerelease
                draft = $_.draft
                body = $_.body
            }
        }
    }
    
    return @()
}

# Function to get repository contributors
function Get-RepoContributors {
    param(
        [string]$Owner,
        [string]$RepoName,
        [hashtable]$Headers
    )
    
    $contributorsUri = "https://api.github.com/repos/$Owner/$RepoName/contributors?per_page=10"
    $contributors = Invoke-GitHubApi -Uri $contributorsUri -Headers $Headers
    
    if ($contributors) {
        return $contributors | ForEach-Object {
            @{
                login = $_.login
                contributions = $_.contributions
                type = $_.type
            }
        }
    }
    
    return @()
}

# Setup headers for API requests
$headers = @{
    "User-Agent" = "PowerShell-GitHub-Repo-Scanner"
    "Accept" = "application/vnd.github.v3+json"
}

# Try to get authentication token
$authToken = $GitHubToken

if (-not $authToken) {
    # Try to get token from gh CLI
    try {
        Write-Host "No token provided. Checking for GitHub CLI authentication..."
        $ghToken = gh auth token 2>$null
        if ($LASTEXITCODE -eq 0 -and $ghToken) {
            $authToken = $ghToken
            Write-Host "Using authentication from GitHub CLI (gh)" -ForegroundColor Green
        }
        else {
            Write-Host "GitHub CLI not authenticated. Run 'gh auth login' to authenticate." -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "GitHub CLI (gh) not found or not authenticated." -ForegroundColor Yellow
    }
}

if ($authToken) {
    $headers["Authorization"] = "token $authToken"
    if ($GitHubToken) {
        Write-Host "Using authenticated requests with provided token"
    }
}
else {
    Write-Host "Using unauthenticated requests (rate limited to 60 requests per hour)" -ForegroundColor Yellow
    Write-Host "Consider running 'gh auth login' or providing a token with -GitHubToken for higher rate limits" -ForegroundColor Yellow
}

# Check initial rate limit status
Write-Host "Checking initial rate limit status..."
$initialRateLimit = Get-RateLimitStatus -Headers $headers
if ($initialRateLimit) {
    Write-Host "Rate limit: $($initialRateLimit.Remaining)/$($initialRateLimit.Limit) requests remaining" -ForegroundColor Cyan
    Write-Host "Rate limit resets at: $($initialRateLimit.Reset.ToString('HH:mm:ss'))" -ForegroundColor Cyan

    if ($initialRateLimit.Remaining -eq 0) {
        Write-Warning "Rate limit already exhausted!"
        Wait-ForRateLimitReset -ResetTime $initialRateLimit.Reset
    }
    elseif ($initialRateLimit.Remaining -lt 20) {
        Write-Warning "Low rate limit remaining. Consider waiting or using a GitHub token for higher limits."
    }

    # Initialize tracking info
    $script:RateLimitInfo.Remaining = $initialRateLimit.Remaining
    $script:RateLimitInfo.Limit = $initialRateLimit.Limit
    $script:RateLimitInfo.Reset = $initialRateLimit.Reset
    $script:RateLimitInfo.LastChecked = Get-Date
}

# Determine if this is a user or organization
Write-Host "Checking if '$GitHubUserOrOrg' is a user or organization..."
$userUri = "https://api.github.com/users/$GitHubUserOrOrg"
$userInfo = Invoke-GitHubApi -Uri $userUri -Headers $headers

if (-not $userInfo) {
    Write-Error "Could not find user or organization: $GitHubUserOrOrg"
    exit 1
}

$isOrganization = $userInfo.type -eq "Organization"
Write-Host "Found $($userInfo.type.ToLower()): $($userInfo.name)"

# Get all repositories
Write-Host "Fetching repositories..."
$allRepos = @()
$page = 1
$perPage = 100

do {
    $reposUri = "https://api.github.com/users/$GitHubUserOrOrg/repos?type=public&sort=updated&per_page=$perPage&page=$page"
    $repos = Invoke-GitHubApi -Uri $reposUri -Headers $headers
    
    if ($repos) {
        $allRepos += $repos
        Write-Host "Fetched page $page with $($repos.Count) repositories"
        $page++
    }
} while ($repos -and $repos.Count -eq $perPage)

# Filter repositories based on parameters
$filteredRepos = $allRepos | Where-Object {
    $includeRepo = $true
    
    if (-not $IncludeArchived -and $_.archived) {
        $includeRepo = $false
    }
    
    if (-not $IncludeForks -and $_.fork) {
        $includeRepo = $false
    }
    
    return $includeRepo
}

Write-Host "Processing $($filteredRepos.Count) repositories (filtered from $($allRepos.Count) total)"

# Process each repository to get detailed information
$repoSummaryData = @()
$counter = 0

foreach ($repo in $filteredRepos) {
    $counter++
    Write-Progress -Activity "Processing repositories" -Status "Processing $($repo.name) ($counter/$($filteredRepos.Count))" -PercentComplete (($counter / $filteredRepos.Count) * 100)

    Write-Host "Processing repository: $($repo.name)"

    # Get additional data for each repository
    $readme = Get-ReadmeContent -Owner $repo.owner.login -RepoName $repo.name -Headers $headers
    $languages = Get-RepoLanguages -Owner $repo.owner.login -RepoName $repo.name -Headers $headers
    $topics = Get-RepoTopics -Owner $repo.owner.login -RepoName $repo.name -Headers $headers
    $releases = Get-RepoReleases -Owner $repo.owner.login -RepoName $repo.name -Headers $headers
    $contributors = Get-RepoContributors -Owner $repo.owner.login -RepoName $repo.name -Headers $headers

    # Create comprehensive repository object with full details
    $repoDetailObject = @{
        # Basic repository information
        id = $repo.id
        name = $repo.name
        full_name = $repo.full_name
        description = $repo.description
        url = $repo.html_url
        clone_url = $repo.clone_url
        ssh_url = $repo.ssh_url

        # Repository metadata
        owner = @{
            login = $repo.owner.login
            type = $repo.owner.type
            url = $repo.owner.html_url
        }

        # Repository properties
        private = $repo.private
        fork = $repo.fork
        archived = $repo.archived
        disabled = $repo.disabled

        # Repository stats
        size = $repo.size
        stargazers_count = $repo.stargazers_count
        watchers_count = $repo.watchers_count
        forks_count = $repo.forks_count
        open_issues_count = $repo.open_issues_count

        # Language and topics
        language = $repo.language
        languages = $languages
        topics = $topics

        # Dates
        created_at = $repo.created_at
        updated_at = $repo.updated_at
        pushed_at = $repo.pushed_at

        # Repository settings
        default_branch = $repo.default_branch
        allow_forking = $repo.allow_forking
        visibility = $repo.visibility

        # License information
        license = if ($repo.license) {
            @{
                key = $repo.license.key
                name = $repo.license.name
                spdx_id = $repo.license.spdx_id
            }
        } else { $null }

        # Homepage and additional URLs
        homepage = $repo.homepage

        # README content
        readme = $readme

        # Recent releases
        recent_releases = $releases

        # Top contributors
        top_contributors = $contributors

        # Repository features
        has_issues = $repo.has_issues
        has_projects = $repo.has_projects
        has_wiki = $repo.has_wiki
        has_pages = $repo.has_pages
        has_downloads = $repo.has_downloads
        has_discussions = $repo.has_discussions
    }

    # Save detailed repository data to individual file
    $repoFileName = "$($repo.name).json"
    $repoFilePath = Join-Path -Path $OutputDirectory -ChildPath $repoFileName
    Write-Host "  Saving detailed data to: $repoFileName"

    try {
        $repoDetailObject | ConvertTo-Json -Depth 10 -Compress:$false | Out-File -FilePath $repoFilePath -Encoding UTF8
    }
    catch {
        Write-Warning "Failed to save detail file for $($repo.name): $($_.Exception.Message)"
    }

    # Create summary object for this repository (without large data like readme, releases, contributors)
    $repoSummaryObject = @{
        # Basic repository information
        id = $repo.id
        name = $repo.name
        full_name = $repo.full_name
        description = $repo.description
        url = $repo.html_url

        # Repository properties
        private = $repo.private
        fork = $repo.fork
        archived = $repo.archived
        disabled = $repo.disabled

        # Repository stats
        size = $repo.size
        stargazers_count = $repo.stargazers_count
        watchers_count = $repo.watchers_count
        forks_count = $repo.forks_count
        open_issues_count = $repo.open_issues_count

        # Language and topics
        language = $repo.language
        topics = $topics

        # Dates
        created_at = $repo.created_at
        updated_at = $repo.updated_at
        pushed_at = $repo.pushed_at

        # License information
        license = if ($repo.license) {
            @{
                key = $repo.license.key
                name = $repo.license.name
                spdx_id = $repo.license.spdx_id
            }
        } else { $null }

        # Homepage
        homepage = $repo.homepage

        # Detail file reference
        detail_file = $repoFileName
    }

    $repoSummaryData += $repoSummaryObject

    # Add a small delay to avoid hitting rate limits too hard
    Start-Sleep -Milliseconds 100
}

Write-Progress -Activity "Processing repositories" -Completed

# Create final summary output object
$summaryOutput = @{
    user_or_org = @{
        login = $userInfo.login
        name = $userInfo.name
        type = $userInfo.type
        url = $userInfo.html_url
        public_repos = $userInfo.public_repos
        followers = $userInfo.followers
        following = $userInfo.following
        created_at = $userInfo.created_at
        bio = $userInfo.bio
        blog = $userInfo.blog
        location = $userInfo.location
        company = $userInfo.company
    }

    metadata = @{
        generated_at = Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fffZ"
        total_repositories_found = $allRepos.Count
        repositories_included = $filteredRepos.Count
        filters_applied = @{
            include_archived = $IncludeArchived
            include_forks = $IncludeForks
        }
        api_rate_limit_used = $true
        authenticated = [bool]$authToken
        detail_directory = $OutputDirectory
    }

    repositories = $repoSummaryData
}

# Convert to JSON and save summary
Write-Host "`nSaving summary file..."
Write-Host "Summary path: $OutputPath" -ForegroundColor Cyan
$jsonOutput = $summaryOutput | ConvertTo-Json -Depth 10 -Compress:$false

try {
    $jsonOutput | Out-File -FilePath $OutputPath -Encoding UTF8
    Write-Host "Successfully saved summary to: $OutputPath" -ForegroundColor Green
    Write-Host "Successfully saved $($repoSummaryData.Count) detail files to: $OutputDirectory" -ForegroundColor Green
    Write-Host "Total repositories processed: $($repoSummaryData.Count)" -ForegroundColor Green
    
    # Display summary statistics
    $languageStats = @{}
    $topicStats = @{}

    foreach ($repo in $repoSummaryData) {
        if ($repo.language) {
            if ($languageStats.ContainsKey($repo.language)) {
                $languageStats[$repo.language] = $languageStats[$repo.language] + 1
            } else {
                $languageStats[$repo.language] = 1
            }
        }

        if ($repo.topics) {
            foreach ($topic in $repo.topics) {
                if ($topicStats.ContainsKey($topic)) {
                    $topicStats[$topic] = $topicStats[$topic] + 1
                } else {
                    $topicStats[$topic] = 1
                }
            }
        }
    }

    Write-Host "`nSummary Statistics:" -ForegroundColor Cyan
    Write-Host "Top Languages:" -ForegroundColor Yellow
    $languageStats.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 10 | ForEach-Object {
        Write-Host "  $($_.Key): $($_.Value) repositories"
    }

    Write-Host "`nTop Topics:" -ForegroundColor Yellow
    $topicStats.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 10 | ForEach-Object {
        Write-Host "  $($_.Key): $($_.Value) repositories"
    }

    $totalStars = ($repoSummaryData | Measure-Object -Property stargazers_count -Sum).Sum
    $totalForks = ($repoSummaryData | Measure-Object -Property forks_count -Sum).Sum
    Write-Host "`nTotal Stars: $totalStars" -ForegroundColor Green
    Write-Host "Total Forks: $totalForks" -ForegroundColor Green

    # Display final rate limit status
    Write-Host "`nFinal Rate Limit Status:" -ForegroundColor Cyan
    $finalRateLimit = Get-RateLimitStatus -Headers $headers
    if ($finalRateLimit) {
        $apiCallsUsed = $finalRateLimit.Limit - $finalRateLimit.Remaining
        Write-Host "API calls used: $apiCallsUsed" -ForegroundColor Cyan
        Write-Host "Remaining: $($finalRateLimit.Remaining)/$($finalRateLimit.Limit)" -ForegroundColor Cyan
        Write-Host "Resets at: $($finalRateLimit.Reset.ToString('HH:mm:ss'))" -ForegroundColor Cyan
    }
}
catch {
    Write-Error "Failed to save file: $($_.Exception.Message)"
    exit 1
}

Write-Host "`nScript completed successfully!" -ForegroundColor Green 