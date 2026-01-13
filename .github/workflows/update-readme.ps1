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
        $nugetStableVersionCheck = $null
        $nugetPrereleaseVersionCheck = $null
        $githubVersionCheck =  $null
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
            $githubVersionCheck = -not (gh api "/repos/$org/$($repo.name)/releases/latest" -q '.tag_name' 2>$null| Out-String).Contains("Not Found")
        } catch {
            Write-Output "$_"
        }

        try
        {
            $nugetStableVersionCheck = Find-Package -Name "$nuget.$($repo.name)" -AllVersions 2>$null | Where-Object { -not $_.Version.IsPrerelease } | Select-Object -First 1
        } catch {
            Write-Output "$_"
        }

        try
        {
            $nugetPrereleaseVersionCheck = Find-Package -Name "$nuget.$($repo.name)" -AllowPrereleaseVersions -AllVersions 2>$null | Where-Object { $_.Version.IsPrerelease } | Select-Object -First 1
        } catch {
            Write-Output "$_"
        }

        try
        {
            $workflowCheck = gh api "/repos/$org/$($repo.name)/actions/workflows/dotnet.yml/runs" -q '.workflow_runs[0].status' 2>$null
        } catch {
            Write-Output "$_"
        }

        $hasNugetStableRelease = $null -ne $nugetStableVersionCheck
        $hasNugetPrereleaseRelease = $null -ne $nugetPrereleaseVersionCheck
        $hasGithubRelease = $githubVersionCheck
        $hasStableRelease = $hasNugetStableRelease -or $hasGithubRelease

        # Only show projects that have at least one stable release
        if (-not $hasStableRelease) {
            Write-Host "  Skipping repo with no stable release: $($repo.name)"
            continue
        }

        # Determine if this is a library or application by checking the project file
        $isApplication = $false
        try {
            # Function to recursively search for csproj files
            function Search-CsprojRecursive {
                param([string]$path = "")

                $contents = gh api "repos/$org/$($repo.name)/contents/$path" 2>$null | ConvertFrom-Json

                foreach ($item in $contents) {
                    if ($item.type -eq "file" -and $item.name -like "*.csproj") {
                        return $item.path
                    }
                }

                # Search subdirectories
                foreach ($item in $contents) {
                    if ($item.type -eq "dir") {
                        $found = Search-CsprojRecursive -path $item.path
                        if ($found) {
                            return $found
                        }
                    }
                }

                return $null
            }

            $csprojPath = Search-CsprojRecursive
            if ($csprojPath) {
                Write-Host "  Found csproj: $csprojPath"
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
        if ($hasNugetStableRelease) {
            $readmeLine += "|![NuGet Version](https://img.shields.io/nuget/v/$nuget.$($repo.name)?label=&logo=nuget)"
        }
        elseif ($hasGithubRelease) {
            $readmeLine += "|![GitHub Version](https://img.shields.io/github/v/release/$org/$($repo.name)?label=&logo=github)"
        }
        else {
            $readmeLine += "| "
        }

        # Prerelease version column
        if ($hasNugetPrereleaseRelease) {
            $readmeLine += "|![NuGet Prerelease Version](https://img.shields.io/nuget/vpre/$nuget.$($repo.name)?label=&logo=nuget)"
        }
        else {
            $readmeLine += "| "
        }

        if ($hasNugetStableRelease -or $hasNugetPrereleaseRelease) { $readmeLine += "|![NuGet Downloads](https://img.shields.io/nuget/dt/$nuget.$($repo.name)?label=&logo=nuget)" }
        #elseif ($hasGithubRelease) { $readmeLine += "|![GitHub Downloads](https://img.shields.io/github/downloads/$org/$($repo.name)/total?label=&logo=github)" }
        else { $readmeLine += "| " }
        
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

Write-Host $readme

$readme | Out-File -FilePath ./profile/README.md
