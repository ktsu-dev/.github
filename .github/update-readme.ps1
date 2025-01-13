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
        $readme += "|[$($repo.name)](https://github.com/$org/$($repo.name))"
        $readme += "|![NuGet Version](https://img.shields.io/nuget/v/$nuget.$($repo.name)?label=&logo=nuget)"
        $readme += "|![GitHub commit activity](https://img.shields.io/github/commit-activity/m/$org/$($repo.name)?label=&logo=github)"
        $readme += "|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/$org/$($repo.name)/dotnet.yml?label=&logo=github)"
        $readme += "|`n"
    }
    $page++
} while ($repos.Count -eq $per_page)

Write-Host $readme

$readme | Out-File -FilePath profile/README.md
