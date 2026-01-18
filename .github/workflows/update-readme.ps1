$org = "ktsu-dev"
$nuget = "ktsu"

$readme = Get-Content -Path ./profile/README.template -Raw

$libraryRows = @()
$applicationRows = @()

$per_page = 30
$page = 1

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

        # Check if NuGet package exists by making a simple HTTP request
        try {
            $nugetUrl = "https://api.nuget.org/v3-flatcontainer/$nuget.$($repo.name)/index.json"
            $response = Invoke-WebRequest -Uri $nugetUrl -Method Head -ErrorAction SilentlyContinue
            if ($response.StatusCode -eq 200) {
                $hasNugetPackage = $true
                Write-Host "  Found NuGet package"
            }
        } catch {
            # Package doesn't exist, which is fine
        }

        try
        {
            $workflowCheck = gh api "/repos/$org/$($repo.name)/actions/workflows/dotnet.yml/runs" -q '.workflow_runs[0].status' 2>$null
        } catch {
            Write-Output "$_"
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

        $readmeLine += "|[$($repo.name)](https://github.com/$org/$($repo.name))"

        # Stable version column
        if ($hasNugetPackage) {
            # If a NuGet package exists, use NuGet badge
            $readmeLine += "|![NuGet Version](https://img.shields.io/nuget/v/$nuget.$($repo.name)?label=&logo=nuget)"
        }
        elseif ($hasStableRelease) {
            # Otherwise use GitHub release badge
            $readmeLine += "|![GitHub Version](https://img.shields.io/github/v/release/$org/$($repo.name)?label=&logo=github)"
        }
        else {
            $readmeLine += "| "
        }

        # Prerelease version column
        if ($hasNugetPackage) {
            # If a NuGet package exists, use NuGet prerelease badge
            $readmeLine += "|![NuGet Prerelease Version](https://img.shields.io/nuget/vpre/$nuget.$($repo.name)?label=&logo=nuget)"
        }
        elseif ($hasPrereleaseRelease) {
            # Otherwise use GitHub prerelease badge
            $readmeLine += "|![GitHub Prerelease](https://img.shields.io/github/v/release/$org/$($repo.name)?include_prereleases&label=&logo=github)"
        }
        else {
            $readmeLine += "| "
        }

        # Downloads column
        if ($hasNugetPackage) {
            $readmeLine += "|![NuGet Downloads](https://img.shields.io/nuget/dt/$nuget.$($repo.name)?label=&logo=nuget)"
        }
        else {
            $readmeLine += "| "
        }
        
        $readmeLine += "|![GitHub commit activity](https://img.shields.io/github/commit-activity/m/$org/$($repo.name)?label=&logo=github)"
        
        if ($null -ne $workflowCheck) { $readmeLine += "|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/$org/$($repo.name)/dotnet.yml?label=&logo=github)" }
        else { $readmeLine += "| " }
        

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

| Repo | Stable | Prerelease | Downloads | Activity | Status | README |
|------|--------|------------|-----------|----------|--------|--------|

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
