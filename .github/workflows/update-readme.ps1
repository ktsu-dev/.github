$org = "ktsu-dev"
$nuget = "ktsu"

$readme = @"
# ktsu.dev

A collection of open source libraries and projects established in 2023.

We are focused on creating .NET libraries that contribute to a more expressive and maintainable codebase, while facilitating strict standards to avoid common code and logic errors.

| Repo | Version | Activity | Status |
|------|---------|----------|--------|

"@

$per_page = 30
$page = 1

do {
    $repos = (gh api "/orgs/$org/repos?type=public&sort=full_name&direction=asc&page=$page&per_page=$per_page" | ConvertFrom-Json)
    #$repos | ConvertTo-Json | Out-File -FilePath repos.json

    foreach ($repo in $repos) {
        Write-Host "Processing $($repo.name)"
        
        $readmeLine = ""
        $nugetVersionCheck = $null
        $githubVersionCheck =  $null
        $workflowCheck = $null

        try
        {
            $githubVersionCheck = gh api "/repos/$org/$($repo.name)/releases/latest" -q '.tag_name' 2>$null
        } catch {
            Write-Output "$_"
        }

        try
        {
            $nugetVersionCheck = Find-Package -Name "$nuget.$($repo.name)" -AllowPrereleaseVersions -AllVersions 2>$null
        } catch {
            Write-Output "$_"
        }

        try
        {
            $workflowCheck = gh api "/repos/$org/$($repo.name)/actions/workflows/dotnet.yml/runs" -q '.workflow_runs[0].status' 2>$null
        } catch {
            Write-Output "$_"
        }

        $hasNugetRelease = $null -ne $nugetVersionCheck
        $hasGithubRelease = $githubVersionCheck
        $hasAnyRelease = $hasNugetRelease -or $hasGithubRelease

        if (-not $hasAnyRelease) {
            continue
        }
        
        $readmeLine += "|[$($repo.name)](https://github.com/$org/$($repo.name))"
        
        if ($hasNugetRelease) { $readmeLine += "|![NuGet Version](https://img.shields.io/nuget/v/$nuget.$($repo.name)?label=&logo=nuget)" }
        elseif ($hasGithubRelease) { $readmeLine += "|![GitHub Version](https://img.shields.io/github/v/release/$org/$($repo.name)?label=&logo=github)" }
        else { $readmeLine += "|N/A" }
        
        $readmeLine += "|![GitHub commit activity](https://img.shields.io/github/commit-activity/m/$org/$($repo.name)?label=&logo=github)"
        
        if ($null -ne $workflowCheck) { $readmeLine += "|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/$org/$($repo.name)/dotnet.yml?label=&logo=github)" }
        else { $readmeLine += "|N/A" }
        
        $readmeLine += "|`n"
        $readme += $readmeLine
    }
    $page++
} while ($repos.Count -eq $per_page)

Write-Host $readme

$readme | Out-File -FilePath ../profile/README.md
