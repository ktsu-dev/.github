$org = "ktsu-dev"
$nuget = "ktsu"

# Load System.Web assembly for URL encoding
Add-Type -AssemblyName System.Web

$readme = Get-Content -Path ./profile/README.template -Raw

$libraryRows = @()
$applicationRows = @()

$per_page = 30
$page = 1

# Package manager check functions
function Test-WingetPackage {
    param([string]$packageName, [string]$version)
    try {
        # Winget packages are typically organized as: manifests/<first-letter>/<publisher>/<package>/<version>/
        # For ktsu-dev packages, publisher is likely "ktsu" or "ktsu-dev"

        # Try different possible publisher names
        $possiblePublishers = @("ktsu", "ktsu-dev", "ktsu.dev")

        foreach ($publisher in $possiblePublishers) {
            try {
                # Get the package directory to find all versions
                $manifestPath = "manifests/" + $publisher.Substring(0,1).ToLower() + "/$publisher/$packageName"
                $contents = gh api "repos/microsoft/winget-pkgs/contents/$manifestPath" 2>$null | ConvertFrom-Json

                if ($contents) {
                    # Get all version directories
                    $versions = $contents | Where-Object { $_.type -eq "dir" } | ForEach-Object { $_.name }

                    if ($versions) {
                        # Find the latest version (simple string comparison, should work for semantic versions)
                        $latestVersion = $versions | Sort-Object -Descending | Select-Object -First 1

                        return @{ available = $true; version = $latestVersion }
                    }
                }
            } catch {
                # Try next publisher
                continue
            }
        }
    } catch {
        # Silently fail if search doesn't work - winget availability is a nice-to-have
    }
    return @{ available = $false; version = $null }
}

function Test-ChocoPackage {
    param([string]$packageName, [string]$version)
    try {
        $searchUrl = "https://community.chocolatey.org/api/v2/Packages()?`$filter=Id eq '$packageName'&`$top=1"
        $response = Invoke-RestMethod -Uri $searchUrl -Method Get -ErrorAction SilentlyContinue
        if ($response.entry) {
            $chocoVersion = $response.entry.properties.Version.'#text'
            return @{ available = $true; hasLatest = ($chocoVersion -eq $version) }
        }
    } catch {
        Write-Host "  Error checking choco: $_"
    }
    return @{ available = $false; hasLatest = $false }
}

function Test-BrewPackage {
    param([string]$packageName, [string]$version)
    try {
        $searchUrl = "https://formulae.brew.sh/api/formula/$packageName.json"
        $response = Invoke-RestMethod -Uri $searchUrl -Method Get -ErrorAction SilentlyContinue
        if ($response) {
            $brewVersion = $response.versions.stable
            return @{ available = $true; hasLatest = ($brewVersion -eq $version) }
        }
    } catch {
        Write-Host "  Error checking brew: $_"
    }
    return @{ available = $false; hasLatest = $false }
}

function Test-ScoopPackage {
    param([string]$packageName, [string]$version)
    try {
        # Check the main Scoop bucket on GitHub
        $searchUrl = "https://raw.githubusercontent.com/ScoopInstaller/Main/master/bucket/$packageName.json"
        $response = Invoke-RestMethod -Uri $searchUrl -Method Get -ErrorAction SilentlyContinue
        if ($response) {
            return @{ available = $true; hasLatest = ($response.version -eq $version) }
        }
    } catch {
        Write-Host "  Error checking scoop: $_"
    }
    return @{ available = $false; hasLatest = $false }
}

function Test-AptPackage {
    param([string]$packageName, [string]$version)
    try {
        # Check packages.ubuntu.com for the package
        $searchUrl = "https://packages.ubuntu.com/search?keywords=$packageName&searchon=names&suite=all&section=all"
        $response = Invoke-WebRequest -Uri $searchUrl -Method Get -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200 -and $response.Content -match $packageName) {
            return @{ available = $true; hasLatest = $false }
        }
    } catch {
        Write-Host "  Error checking apt: $_"
    }
    return @{ available = $false; hasLatest = $false }
}

function Test-AurPackage {
    param([string]$packageName, [string]$version)
    try {
        $searchUrl = "https://aur.archlinux.org/rpc/?v=5&type=info&arg=$packageName"
        $response = Invoke-RestMethod -Uri $searchUrl -Method Get -ErrorAction SilentlyContinue
        if ($response.resultcount -gt 0) {
            $aurVersion = $response.results[0].Version
            return @{ available = $true; hasLatest = ($aurVersion -eq $version) }
        }
    } catch {
        Write-Host "  Error checking aur: $_"
    }
    return @{ available = $false; hasLatest = $false }
}

function Test-YumPackage {
    param([string]$packageName, [string]$version)
    try {
        # Check rpmfind.net for the package
        $searchUrl = "https://rpmfind.net/linux/rpm2html/search.php?query=$packageName"
        $response = Invoke-WebRequest -Uri $searchUrl -Method Get -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200 -and $response.Content -match $packageName) {
            return @{ available = $true; hasLatest = $false }
        }
    } catch {
        Write-Host "  Error checking yum: $_"
    }
    return @{ available = $false; hasLatest = $false }
}

function Get-NuGetPackageInfo {
    param([string]$packageName)
    try {
        $indexUrl = "https://api.nuget.org/v3-flatcontainer/$packageName/index.json"
        $response = Invoke-RestMethod -Uri $indexUrl -Method Get -ErrorAction SilentlyContinue

        if ($response.versions) {
            $versions = $response.versions
            $stableVersions = $versions | Where-Object { $_ -notmatch '-' }
            $prereleaseVersions = $versions | Where-Object { $_ -match '-' }

            $stableVersion = if ($stableVersions) { $stableVersions[-1] } else { $null }
            $prereleaseVersion = if ($prereleaseVersions) { $prereleaseVersions[-1] } else { $null }

            # Get download count from NuGet API v3
            $registrationUrl = "https://api.nuget.org/v3/registration5-semver1/$($packageName.ToLower())/index.json"
            $registrationResponse = Invoke-RestMethod -Uri $registrationUrl -Method Get -ErrorAction SilentlyContinue

            $totalDownloads = 0
            if ($registrationResponse) {
                foreach ($page in $registrationResponse.items) {
                    foreach ($item in $page.items) {
                        if ($item.catalogEntry.version) {
                            # Sum up downloads from all versions (downloads are typically at package level)
                            # Note: Individual version downloads aren't easily available, so we'll get total from the catalog
                        }
                    }
                }
                # Try to get total downloads from the catalog
                $catalogUrl = "https://api.nuget.org/v3/registration5-semver1/$($packageName.ToLower())/index.json"
                $catalogData = Invoke-RestMethod -Uri $catalogUrl -Method Get -ErrorAction SilentlyContinue
                # NuGet API doesn't directly expose download counts in registration, need to use different endpoint
            }

            # Get download count from nuget.org statistics API
            try {
                $statsUrl = "https://azuresearch-usnc.nuget.org/query?q=packageid:$packageName&prerelease=true"
                $statsResponse = Invoke-RestMethod -Uri $statsUrl -Method Get -ErrorAction SilentlyContinue
                if ($statsResponse.data -and $statsResponse.data.Count -gt 0) {
                    $totalDownloads = $statsResponse.data[0].totalDownloads
                }
            } catch {
                Write-Host "  Could not fetch download stats: $_"
            }

            return @{
                hasPackage = $true
                stableVersion = $stableVersion
                prereleaseVersion = $prereleaseVersion
                totalDownloads = $totalDownloads
            }
        }
    } catch {
        Write-Host "  Error fetching NuGet info: $_"
    }

    return @{
        hasPackage = $false
        stableVersion = $null
        prereleaseVersion = $null
        totalDownloads = 0
    }
}

function Get-GitHubCommitActivity {
    param([string]$org, [string]$repo)
    try {
        # Get commits from the last 30 days
        $since = (Get-Date).AddDays(-30).ToString("yyyy-MM-ddTHH:mm:ssZ")
        $commits = gh api "/repos/$org/$repo/commits?since=$since&per_page=100" 2>$null | ConvertFrom-Json
        return $commits.Count
    } catch {
        Write-Host "  Error fetching commit activity: $_"
        return 0
    }
}

function Get-GitHubWorkflowStatus {
    param([string]$org, [string]$repo, [string]$workflowFile)
    try {
        $runs = gh api "/repos/$org/$repo/actions/workflows/$workflowFile/runs?per_page=1" 2>$null | ConvertFrom-Json
        if ($runs.workflow_runs -and $runs.workflow_runs.Count -gt 0) {
            $latestRun = $runs.workflow_runs[0]
            return @{
                exists = $true
                status = $latestRun.status
                conclusion = $latestRun.conclusion
            }
        }
    } catch {
        Write-Host "  Error fetching workflow status: $_"
    }

    return @{
        exists = $false
        status = $null
        conclusion = $null
    }
}

function Format-Number {
    param([int]$number)

    if ($number -ge 1000000) {
        return "$([math]::Round($number / 1000000, 1))M"
    }
    elseif ($number -ge 1000) {
        return "$([math]::Round($number / 1000, 1))K"
    }
    else {
        return "$number"
    }
}

function New-CustomBadge {
    param(
        [string]$label,
        [string]$message,
        [string]$color,
        [string]$logo = "",
        [string]$logoColor = "white"
    )

    $encodedLabel = [System.Web.HttpUtility]::UrlEncode($label)
    $encodedMessage = [System.Web.HttpUtility]::UrlEncode($message)

    $url = "https://img.shields.io/badge/$encodedLabel-$encodedMessage-$color"
    if ($logo) {
        $url += "?logo=$logo&logoColor=$logoColor"
    }

    return $url
}

do {
    $repos = (gh api "/orgs/$org/repos?type=public&sort=full_name&direction=asc&page=$page&per_page=$per_page" | ConvertFrom-Json)
    #$repos | ConvertTo-Json | Out-File -FilePath repos.json

    foreach ($repo in $repos) {
        Write-Host "Processing $($repo.name)"
        
        $readmeLine = ""
        $hasStableRelease = $false
        $hasPrereleaseRelease = $false
        $hasNugetPackage = $false
        $workflowCheck = $null

        # Skip archived repositories
        if ($repo.archived) {
            Write-Host "  Skipping archived repo: $($repo.name)"
            continue
        }

        # Skip ktsu.Sdk (has dedicated section in README)
        if ($repo.name -eq "Sdk") {
            Write-Host "  Skipping Sdk repo (has dedicated section)"
            continue
        }

        try
        {
            # Get all releases from GitHub API
            $releases = gh api "/repos/$org/$($repo.name)/releases" 2>$null | ConvertFrom-Json

            if ($releases -and $releases.Count -gt 0) {
                # Determine stable vs prerelease based on version string format
                # Prerelease versions contain hyphens (e.g., "v1.0.0-pre.1", "v1.0.0-alpha.1")
                # Stable versions do not (e.g., "v1.0.0")

                foreach ($release in $releases) {
                    $version = $release.tag_name -replace '^v', ''
                    $isVersionPrerelease = $version -match '-'

                    if ($isVersionPrerelease) {
                        if (-not $hasPrereleaseRelease) {
                            $hasPrereleaseRelease = $true
                            Write-Host "  Found prerelease (by version string): $($release.tag_name)"
                        }
                    } else {
                        if (-not $hasStableRelease) {
                            $hasStableRelease = $true
                            Write-Host "  Found stable release (by version string): $($release.tag_name)"
                        }
                    }

                    # Stop once we've found both types
                    if ($hasStableRelease -and $hasPrereleaseRelease) {
                        break
                    }
                }
            }
        } catch {
            Write-Output "  Error checking releases: $_"
        }

        # Get NuGet package info (version, downloads)
        $nugetInfo = $null
        try {
            $nugetInfo = Get-NuGetPackageInfo -packageName "$nuget.$($repo.name)"
            if ($nugetInfo.hasPackage) {
                $hasNugetPackage = $true
                Write-Host "  Found NuGet package: v$($nugetInfo.stableVersion), $($nugetInfo.totalDownloads) downloads"
            }
        } catch {
            Write-Host "  Error checking NuGet package: $_"
        }

        # Get GitHub commit activity
        $commitActivity = 0
        try {
            $commitActivity = Get-GitHubCommitActivity -org $org -repo $repo.name
            Write-Host "  Commit activity: $commitActivity commits in last 30 days"
        } catch {
            Write-Host "  Error fetching commit activity: $_"
        }

        # Get workflow status
        $workflowStatus = $null
        try {
            $workflowStatus = Get-GitHubWorkflowStatus -org $org -repo $repo.name -workflowFile "dotnet.yml"
            if ($workflowStatus.exists) {
                Write-Host "  Workflow status: $($workflowStatus.conclusion)"
            }
        } catch {
            Write-Host "  Error fetching workflow status: $_"
        }

        # Only show projects that have at least one stable release
        if (-not $hasStableRelease) {
            Write-Host "  Skipping repo with no stable release: $($repo.name)"
            continue
        }

        # Determine if this is a library or application by checking the primary project
        $isApplication = $false
        try {
            # Function to recursively search for csproj files
            function Search-CsprojRecursive {
                param([string]$path = "")

                $contents = gh api "repos/$org/$($repo.name)/contents/$path" 2>$null | ConvertFrom-Json
                $allCsproj = @()

                foreach ($item in $contents) {
                    if ($item.type -eq "file" -and $item.name -like "*.csproj") {
                        $allCsproj += $item.path
                    }
                }

                # Search subdirectories
                foreach ($item in $contents) {
                    if ($item.type -eq "dir") {
                        $found = Search-CsprojRecursive -path $item.path
                        if ($found) {
                            $allCsproj += $found
                        }
                    }
                }

                return $allCsproj
            }

            $allCsprojPaths = Search-CsprojRecursive

            # Filter out benchmark, test, sample, and example projects
            $filteredCsprojPaths = $allCsprojPaths | Where-Object {
                $_ -notmatch '(Benchmark|Test|Sample|Example)s?\.csproj$'
            }

            # If we filtered everything out, use the original list
            if ($filteredCsprojPaths.Count -eq 0) {
                $filteredCsprojPaths = $allCsprojPaths
            }

            # Strategy: Check if there's a <RepoName>.ConsoleApp or <RepoName>.App project
            # If so, this is likely an application repo (the app is the primary deliverable)
            # Otherwise, check for <RepoName>.csproj (library)
            # This handles cases where repos have both libraries and apps

            $csprojPath = $null

            # First, check if there's a <RepoName>.ConsoleApp or <RepoName>.App project
            $appProject = $filteredCsprojPaths | Where-Object { $_ -match "/$($repo.name)\.(ConsoleApp|App)\.csproj$|^$($repo.name)\.(ConsoleApp|App)\.csproj$" } | Select-Object -First 1

            # Then check if there's a <RepoName>.csproj (exact match, likely the main library)
            $libProject = $filteredCsprojPaths | Where-Object { $_ -match "/$($repo.name)\.csproj$|^$($repo.name)\.csproj$" } | Select-Object -First 1

            # Also check for <RepoName>.Core.csproj (common pattern for libraries)
            if (-not $libProject) {
                $libProject = $filteredCsprojPaths | Where-Object { $_ -match "/$($repo.name)\.Core\.csproj$|^$($repo.name)\.Core\.csproj$" } | Select-Object -First 1
            }

            # Decision logic:
            # If there's an app project matching the repo name, prefer that (app is primary deliverable)
            # Even if there's a Core library, the app is what the repo is about
            if ($appProject) {
                $csprojPath = $appProject
                Write-Host "  Found app project: $csprojPath"
            }
            # If no app, check for library project (pure library repo)
            elseif ($libProject) {
                $csprojPath = $libProject
                Write-Host "  Found library project: $csprojPath"
            }
            # Fallback: use the shortest path (most likely to be the main project)
            elseif ($filteredCsprojPaths.Count -gt 0) {
                $csprojPath = $filteredCsprojPaths | Sort-Object { $_.Length } | Select-Object -First 1
                Write-Host "  Found csproj (fallback): $csprojPath"
            }

            if ($csprojPath) {
                $csprojContent = gh api "repos/$org/$($repo.name)/contents/$csprojPath" -q '.content' 2>$null
                if ($csprojContent) {
                    $csprojContent = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($csprojContent))
                    # Check for both Sdk="ktsu.Sdk.(App|ConsoleApp)" and <Sdk Name="ktsu.Sdk.(App|ConsoleApp)" />
                    if ($csprojContent -match 'Sdk\s*=\s*"ktsu\.Sdk\.(ConsoleApp|App)(/[\d\.]+)?"' -or $csprojContent -match '<Sdk\s+Name\s*=\s*"ktsu\.Sdk\.(ConsoleApp|App)(/[\d\.]+)?"') {
                        $isApplication = $true
                        Write-Host "  Detected as application"
                    } else {
                        Write-Host "  Detected as library"
                    }
                }
            } else {
                Write-Host "  No csproj found, assuming library"
            }
        } catch {
            Write-Output "  Could not determine project type for $($repo.name): $_"
        }

        # Get stable version for package manager checks
        $stableVersion = ""
        if ($hasStableRelease) {
            try {
                $latestRelease = ($releases | Where-Object { -not ($_.tag_name -match '-') } | Select-Object -First 1)
                if ($latestRelease) {
                    $stableVersion = $latestRelease.tag_name -replace '^v', ''
                    Write-Host "  Latest stable version: $stableVersion"
                }
            } catch {
                Write-Host "  Error getting stable version: $_"
            }
        }

        $readmeLine += "|[$($repo.name)](https://github.com/$org/$($repo.name))"

        # For applications, show stable version and package manager availability
        if ($isApplication) {
            # Add stable version column
            if ($hasNugetPackage -and $nugetInfo.stableVersion) {
                # Use custom NuGet badge with version from API
                $badgeUrl = New-CustomBadge -label "" -message "v$($nugetInfo.stableVersion)" -color "004880" -logo "nuget"
                $readmeLine += "|![NuGet Version]($badgeUrl)"
            }
            elseif ($hasStableRelease) {
                # Use custom GitHub release badge
                $badgeUrl = New-CustomBadge -label "" -message "v$stableVersion" -color "181717" -logo "github"
                $readmeLine += "|![GitHub Version]($badgeUrl)"
            }
            else {
                $readmeLine += "| "
            }

            # Check each package manager
            $wingetResult = Test-WingetPackage -packageName $repo.name -version $stableVersion
            # $chocoResult = Test-ChocoPackage -packageName $repo.name -version $stableVersion
            # $brewResult = Test-BrewPackage -packageName $repo.name -version $stableVersion
            # $scoopResult = Test-ScoopPackage -packageName $repo.name -version $stableVersion
            # $aptResult = Test-AptPackage -packageName $repo.name -version $stableVersion
            # $aurResult = Test-AurPackage -packageName $repo.name -version $stableVersion
            # $yumResult = Test-YumPackage -packageName $repo.name -version $stableVersion

            # Add columns with version badges
            if ($wingetResult.available -and $wingetResult.version) {
                $badgeUrl = New-CustomBadge -label "" -message "v$($wingetResult.version)" -color "0078D4" -logo "windows"
                $readmeLine += "|![winget]($badgeUrl)"
            } else {
                $readmeLine += "| "
            }
            # $readmeLine += "|" + $(if ($chocoResult.available) { "v$($chocoResult.version)" } else { " " })
            # $readmeLine += "|" + $(if ($brewResult.available) { "v$($brewResult.version)" } else { " " })
            # $readmeLine += "|" + $(if ($scoopResult.available) { "v$($scoopResult.version)" } else { " " })
            # $readmeLine += "|" + $(if ($aptResult.available) { "v$($aptResult.version)" } else { " " })
            # $readmeLine += "|" + $(if ($aurResult.available) { "v$($aurResult.version)" } else { " " })
            # $readmeLine += "|" + $(if ($yumResult.available) { "v$($yumResult.version)" } else { " " })
        }
        # For libraries, show version badges as before
        else {
            # Stable version column
            if ($hasNugetPackage -and $nugetInfo.stableVersion) {
                # Use custom NuGet badge with version from API
                $badgeUrl = New-CustomBadge -label "" -message "v$($nugetInfo.stableVersion)" -color "004880" -logo "nuget"
                $readmeLine += "|![NuGet Version]($badgeUrl)"
            }
            elseif ($hasStableRelease) {
                # Use custom GitHub release badge
                $badgeUrl = New-CustomBadge -label "" -message "v$stableVersion" -color "181717" -logo "github"
                $readmeLine += "|![GitHub Version]($badgeUrl)"
            }
            else {
                $readmeLine += "| "
            }

            # Prerelease version column
            if ($hasNugetPackage -and $nugetInfo.prereleaseVersion) {
                # Use custom NuGet prerelease badge with version from API
                $badgeUrl = New-CustomBadge -label "" -message "v$($nugetInfo.prereleaseVersion)" -color "004880" -logo "nuget"
                $readmeLine += "|![NuGet Prerelease]($badgeUrl)"
            }
            elseif ($hasPrereleaseRelease) {
                # Get the latest prerelease version
                $latestPrerelease = ($releases | Where-Object { $_.tag_name -match '-' } | Select-Object -First 1)
                if ($latestPrerelease) {
                    $prereleaseVersion = $latestPrerelease.tag_name -replace '^v', ''
                    $badgeUrl = New-CustomBadge -label "" -message "v$prereleaseVersion" -color "181717" -logo "github"
                    $readmeLine += "|![GitHub Prerelease]($badgeUrl)"
                }
                else {
                    $readmeLine += "| "
                }
            }
            else {
                $readmeLine += "| "
            }
        }

        # Downloads column
        if ($hasNugetPackage -and $nugetInfo.totalDownloads -gt 0) {
            $formattedDownloads = Format-Number -number $nugetInfo.totalDownloads
            $badgeUrl = New-CustomBadge -label "" -message $formattedDownloads -color "004880" -logo "nuget"
            $readmeLine += "|![Downloads]($badgeUrl)"
        }
        else {
            $readmeLine += "| "
        }

        # Commit activity column
        if ($commitActivity -gt 0) {
            $badgeUrl = New-CustomBadge -label "" -message "$commitActivity" -color "181717" -logo "github"
            $readmeLine += "|![Activity]($badgeUrl)"
        }
        else {
            $readmeLine += "| "
        }

        # Workflow status column
        if ($workflowStatus.exists) {
            $statusColor = switch ($workflowStatus.conclusion) {
                "success" { "2ea44f" }
                "failure" { "d73a4a" }
                "cancelled" { "6e7681" }
                default { "dbab09" }
            }
            $statusMessage = switch ($workflowStatus.conclusion) {
                "success" { "passing" }
                "failure" { "failing" }
                "cancelled" { "cancelled" }
                default { "unknown" }
            }
            $badgeUrl = New-CustomBadge -label "" -message $statusMessage -color $statusColor -logo "github"
            $readmeLine += "|![Status]($badgeUrl)"
        }
        else {
            $readmeLine += "| "
        }
        

        $readmeContent = gh api "/repos/$org/$($repo.name)/contents/README.md" -q '.content' 2>$null

        $readmeContent = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($readmeContent))

        if ($readmeContent.Length -lt 256) {
            Write-Host "README too short: $($readmeContent.Length)" 
            $readmeLine += "|![README](https://img.shields.io/badge/failing-red?label=&logo=mdbook)"
        } else {
            $readmeLine += "|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)"
        }

        $readmeLine += "|`n"

        # Add to appropriate array
        if ($isApplication) {
            $applicationRows += $readmeLine
        } else {
            $libraryRows += $readmeLine
        }
    }
    $page++
} while ($repos.Count -eq $per_page)

Write-Host ""
Write-Host "Summary: Found $($libraryRows.Count) libraries and $($applicationRows.Count) applications"
Write-Host ""

# Build the Applications section
if ($applicationRows.Count -gt 0) {
    $readme += @"

### Applications

| Repo | Stable | winget | Downloads | Activity | Status | README |
|------|--------|--------|-----------|----------|--------|--------|

"@
    foreach ($row in $applicationRows) {
        $readme += $row
    }
}

# Build the Libraries section
if ($libraryRows.Count -gt 0) {
    $readme += @"

### Libraries

| Repo | Stable | Prerelease | Downloads | Activity | Status | README |
|------|--------|------------|-----------|----------|--------|--------|

"@
    foreach ($row in $libraryRows) {
        $readme += $row
    }
}

Write-Host $readme

$readme | Out-File -FilePath ./profile/README.md
