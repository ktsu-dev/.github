<#
.SYNOPSIS
    Fetches comprehensive data about all public repositories for a GitHub user or organization.

.DESCRIPTION
    This script uses the GitHub API to retrieve detailed information about all public repositories
    for a specified GitHub user or organization. It includes repository metadata, topics, languages,
    README content, and other contextual information.

.PARAMETER GitHubUserOrOrg
    The GitHub username or organization name to fetch repositories for. This is a positional parameter.

.PARAMETER OutputPath
    The path where the JSON output file will be saved. Defaults to "github-repos-{username}.json".

.PARAMETER GitHubToken
    Optional GitHub personal access token for higher rate limits and access to additional data.
    If not provided, the script will use unauthenticated requests (lower rate limit).

.PARAMETER IncludeArchived
    Include archived repositories in the results. Default is false.

.PARAMETER IncludeForks
    Include forked repositories in the results. Default is false.

.PARAMETER Help
    Display this help information and exit.

.EXAMPLE
    .\get-github-repos.ps1 -GitHubUserOrOrg "octocat"
    
.EXAMPLE
    .\get-github-repos.ps1 -GitHubUserOrOrg "microsoft" -GitHubToken "ghp_xxxxxxxxxxxx" -IncludeArchived -OutputPath "microsoft-repos.json"

.EXAMPLE
    .\get-github-repos.ps1 octocat
    Uses positional parameter for username.

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

# Set default output path if not provided
if (-not $OutputPath) {
    $OutputPath = "github-repos-$GitHubUserOrOrg.json"
}

# Function to make GitHub API requests with proper error handling
function Invoke-GitHubApi {
    param(
        [string]$Uri,
        [hashtable]$Headers = @{}
    )
    
    try {
        $response = Invoke-RestMethod -Uri $Uri -Headers $Headers -ErrorAction Stop
        return $response
    }
    catch {
        if ($_.Exception.Response.StatusCode -eq 404) {
            Write-Warning "Resource not found: $Uri"
            return $null
        }
        elseif ($_.Exception.Response.StatusCode -eq 403) {
            Write-Warning "Rate limit exceeded or access forbidden: $Uri"
            return $null
        }
        else {
            Write-Error "Failed to fetch data from $Uri : $($_.Exception.Message)"
            return $null
        }
    }
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

if ($GitHubToken) {
    $headers["Authorization"] = "token $GitHubToken"
    Write-Host "Using authenticated requests with provided token"
}
else {
    Write-Host "Using unauthenticated requests (rate limited to 60 requests per hour)"
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
$repoData = @()
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
    
    # Create comprehensive repository object
    $repoObject = @{
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
    
    $repoData += $repoObject
    
    # Add a small delay to avoid hitting rate limits too hard
    Start-Sleep -Milliseconds 100
}

Write-Progress -Activity "Processing repositories" -Completed

# Create final output object
$output = @{
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
        authenticated = [bool]$GitHubToken
    }
    
    repositories = $repoData
}

# Convert to JSON and save
Write-Host "Converting to JSON and saving to: $OutputPath"
$jsonOutput = $output | ConvertTo-Json -Depth 10 -Compress:$false

try {
    $jsonOutput | Out-File -FilePath $OutputPath -Encoding UTF8
    Write-Host "Successfully saved repository data to: $OutputPath" -ForegroundColor Green
    Write-Host "Total repositories processed: $($repoData.Count)" -ForegroundColor Green
    
    # Display summary statistics
    $languageStats = @{}
    $topicStats = @{}
    
    foreach ($repo in $repoData) {
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
    
    $totalStars = ($repoData | Measure-Object -Property stargazers_count -Sum).Sum
    $totalForks = ($repoData | Measure-Object -Property forks_count -Sum).Sum
    Write-Host "`nTotal Stars: $totalStars" -ForegroundColor Green
    Write-Host "Total Forks: $totalForks" -ForegroundColor Green
}
catch {
    Write-Error "Failed to save file: $($_.Exception.Message)"
    exit 1
}

Write-Host "`nScript completed successfully!" -ForegroundColor Green 