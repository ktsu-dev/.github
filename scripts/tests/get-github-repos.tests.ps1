<#
.SYNOPSIS
	Checks that get-github-repos.ps1 waits out GitHub's rate limits instead of saving them as
	missing data.

.DESCRIPTION
	get-github-repos.ps1 used to give up on a secondary-limit 403 (which arrives with quota still
	left) and on a primary-limit 429 after 14 seconds of backoff, and return $null. Its callers
	read $null as "this repository has none", so the JSON recorded readme: null, topics: null and
	no releases for repositories that have them, and the run still exited 0
	(ktsu-dev/.github#31). It also wrote local time with a literal Z as generated_at.

	The script is pointed at an in-process stub of the REST API with -ApiBaseUrl, so the cases
	need no network and no token. Each case queues the rate-limit responses one endpoint returns
	before it starts answering normally.

	Run with pwsh: ./scripts/tests/get-github-repos.tests.ps1
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:Script = Join-Path $PSScriptRoot '..' 'get-github-repos.ps1' | Resolve-Path
$script:Pwsh = [System.Environment]::ProcessPath
$script:Failures = 0
$script:Count = 0

function ConvertTo-Base64 {
	param([string]$Text)
	return [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Text))
}

# What the stub answers once an endpoint's queued failures are used up.
$script:Fixture = @{
	'/rate_limit' = '{"resources":{"core":{"remaining":5000,"limit":5000,"used":0,"reset":' + ([DateTimeOffset]::UtcNow.AddHours(1).ToUnixTimeSeconds()) + '}}}'
	'/users/acme' = '{"login":"acme","name":"Acme","type":"Organization","html_url":"https://github.com/acme"}'
	'/users/acme/repos' = '[{"id":1,"name":"widget","full_name":"acme/widget","owner":{"login":"acme","type":"Organization"},"archived":false,"fork":false,"topics":["dotnet"]}]'
	'/repos/acme/widget/readme' = '{"name":"README.md","path":"README.md","size":9,"encoding":"base64","content":"' + (ConvertTo-Base64 '# Widget') + '"}'
	'/repos/acme/widget/languages' = '{"C#":100}'
	'/repos/acme/widget/topics' = '{"names":["dotnet"]}'
	'/repos/acme/widget/releases' = '[{"name":"v1.0.0","tag_name":"v1.0.0","published_at":"2026-01-01T00:00:00Z","prerelease":false,"draft":false,"body":""}]'
	'/repos/acme/widget/contributors' = '[{"login":"octocat","contributions":1,"type":"User"}]'
}

# Failures maps a path to the responses it returns, in order, before falling back to the fixture.
# Each response is @{ Status = <int>; Headers = @{...}; Body = <string> }. A response with
# Repeat = $true is returned forever.
function Start-StubApi {
	param([hashtable]$Failures)

	$queues = [hashtable]::Synchronized(@{})
	foreach ($path in $Failures.Keys) {
		$queue = [System.Collections.Concurrent.ConcurrentQueue[object]]::new()
		foreach ($response in $Failures[$path]) { $queue.Enqueue($response) }
		$queues[$path] = $queue
	}
	$hits = [System.Collections.Concurrent.ConcurrentDictionary[string, int]]::new()

	$listener = [System.Net.HttpListener]::new()
	$port = 0
	foreach ($candidate in 18180..18279) {
		try {
			$listener.Prefixes.Clear()
			$listener.Prefixes.Add("http://127.0.0.1:$candidate/")
			$listener.Start()
			$port = $candidate
			break
		}
		catch {
			# The port is taken. Try the next one.
		}
	}

	if ($port -eq 0) {
		throw 'No free port in 18180-18279 for the stub API.'
	}

	$job = Start-ThreadJob -ScriptBlock {
		param($Listener, $Fixture, $Queues, $Hits)

		try {
			while ($Listener.IsListening) {
				$context = $Listener.GetContext()
				$path = $context.Request.Url.AbsolutePath
				$Hits.AddOrUpdate($path, 1, { param($k, $v) $v + 1 }) | Out-Null

				$response = $null
				$queue = $Queues[$path]
				if ($queue) {
					$next = $null
					if ($queue.TryPeek([ref]$next) -and $next.ContainsKey('Repeat') -and $next.Repeat) {
						$response = $next
					}
					elseif ($queue.TryDequeue([ref]$next)) {
						$response = $next
					}
				}

				if ($response) {
					$context.Response.StatusCode = $response.Status
					foreach ($name in $response.Headers.Keys) {
						$value = $response.Headers[$name]
						if ($value -is [scriptblock]) { $value = & $value }
						$context.Response.Headers.Add($name, [string]$value)
					}
					$body = $response.Body
				}
				elseif ($Fixture.ContainsKey($path)) {
					$body = $Fixture[$path]
				}
				else {
					$context.Response.StatusCode = 404
					$body = '{"message":"Not Found"}'
				}

				$bytes = [System.Text.Encoding]::UTF8.GetBytes($body)
				$context.Response.ContentType = 'application/json'
				$context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
				$context.Response.Close()
			}
		}
		catch {
			# Stopping the listener is how this loop ends.
		}
	} -ArgumentList $listener, $script:Fixture, $queues, $hits

	return [pscustomobject]@{ Listener = $listener; Job = $job; Url = "http://127.0.0.1:$port"; Hits = $hits }
}

function Stop-StubApi {
	param($Api)

	$Api.Listener.Stop()
	$Api.Listener.Close()
	Remove-Job -Job $Api.Job -Force
}

# Runs the script against the stub in a scratch directory. TZ is set far from UTC so a
# local-time generated_at can't pass for UTC by accident on a machine that runs in UTC.
function Invoke-GetRepos {
	param($Api)

	$work = Join-Path ([System.IO.Path]::GetTempPath()) "get-github-repos-$([guid]::NewGuid())"
	New-Item -ItemType Directory -Path $work | Out-Null

	$savedTz = $env:TZ
	try {
		$env:TZ = 'Pacific/Kiritimati'
		$summary = Join-Path $work 'summary.json'
		$details = Join-Path $work 'details'
		$output = & $script:Pwsh -NoProfile -NonInteractive -File $script:Script `
			-GitHubUserOrOrg acme -GitHubToken test-token -ApiBaseUrl $Api.Url `
			-OutputPath $summary -OutputDirectory $details 2>&1 6>&1
		$exitCode = $LASTEXITCODE

		$detail = $null
		$detailPath = Join-Path $details 'widget.json'
		if (Test-Path -LiteralPath $detailPath) {
			$detail = Get-Content -LiteralPath $detailPath -Raw | ConvertFrom-Json
		}

		$summaryJson = $null
		if (Test-Path -LiteralPath $summary) {
			$summaryJson = Get-Content -LiteralPath $summary -Raw
		}

		return [pscustomobject]@{
			ExitCode = $exitCode
			Output = ($output | Out-String)
			Detail = $detail
			Summary = $summaryJson
		}
	}
	finally {
		$env:TZ = $savedTz
		Remove-Item -LiteralPath $work -Recurse -Force
	}
}

function Test-Case {
	param([string]$Name, [hashtable]$Failures, [scriptblock]$Assertion)

	$script:Count++
	$api = Start-StubApi -Failures $Failures
	try {
		$result = Invoke-GetRepos -Api $api
		$problem = & $Assertion $result $api
		if ($problem) {
			$script:Failures++
			Write-Host "FAIL  $Name" -ForegroundColor Red
			Write-Host "      $problem" -ForegroundColor Red
			Write-Host "      output: $($result.Output -replace "`n", "`n      ")" -ForegroundColor Red
			return
		}
		Write-Host "ok    $Name" -ForegroundColor Green
	}
	finally {
		Stop-StubApi -Api $api
	}
}

function Get-Hits {
	param($Api, [string]$Path)
	$count = 0
	[void]$Api.Hits.TryGetValue($Path, [ref]$count)
	return $count
}

# A secondary limit: 403 with retry-after while primary quota remains. The old code only waited
# when /rate_limit reported core.remaining == 0, so this fell through to "Access forbidden".
Test-Case -Name 'a secondary-limit 403 with retry-after is waited out, not saved as no topics' -Failures @{
	'/repos/acme/widget/topics' = @(
		@{ Status = 403; Headers = @{ 'Retry-After' = '1'; 'X-RateLimit-Remaining' = '4999' }; Body = '{"message":"You have exceeded a secondary rate limit."}' }
	)
} -Assertion {
	param($r, $api)
	if ($r.ExitCode -ne 0) { return "expected exit 0, got $($r.ExitCode)" }
	if (-not $r.Detail) { return 'no detail file was written' }
	if (@($r.Detail.topics) -join ',' -ne 'dotnet') { return "expected topics 'dotnet', got '$(@($r.Detail.topics) -join ',')'" }
	if ((Get-Hits $api '/repos/acme/widget/topics') -ne 2) { return "expected exactly one retry of /topics, got $((Get-Hits $api '/repos/acme/widget/topics') - 1)" }
}

# A primary limit returned as 429. The reset is honoured however many times it takes (within the
# wait cap); the old code gave up after three short backoffs and recorded readme: null.
$resetNow = { [DateTimeOffset]::UtcNow.ToUnixTimeSeconds() }
$primary429 = @{ Status = 429; Headers = @{ 'X-RateLimit-Remaining' = '0'; 'X-RateLimit-Reset' = $resetNow }; Body = '{"message":"API rate limit exceeded"}' }
Test-Case -Name 'a primary-limit 429 is waited out until x-ratelimit-reset, not saved as no README' -Failures @{
	'/repos/acme/widget/readme' = @($primary429, $primary429, $primary429, $primary429)
} -Assertion {
	param($r, $api)
	if ($r.ExitCode -ne 0) { return "expected exit 0, got $($r.ExitCode)" }
	if (-not $r.Detail) { return 'no detail file was written' }
	if (-not $r.Detail.readme -or $r.Detail.readme.content -ne '# Widget') { return 'the README was recorded as missing' }
}

# When the limit never lifts, the run must fail rather than write a summary that looks complete.
Test-Case -Name 'a limit that never lifts fails the run instead of saving no releases' -Failures @{
	'/repos/acme/widget/releases' = @(
		@{ Status = 429; Headers = @{ 'Retry-After' = '1' }; Body = '{"message":"rate limited"}'; Repeat = $true }
	)
} -Assertion {
	param($r, $api)
	if ($r.ExitCode -eq 0) { return 'expected a non-zero exit when the limit never lifts' }
	if ($r.Summary) { return 'a summary was written although releases could not be read' }
}

# A 403 that is not a rate limit is a genuine "can't read this", and stays a warning.
Test-Case -Name 'a plain 403 is reported as forbidden without waiting' -Failures @{
	'/repos/acme/widget/contributors' = @(
		@{ Status = 403; Headers = @{}; Body = '{"message":"Must have push access to view repository collaborators."}' }
	)
} -Assertion {
	param($r, $api)
	if ($r.ExitCode -ne 0) { return "expected exit 0, got $($r.ExitCode)" }
	if ((Get-Hits $api '/repos/acme/widget/contributors') -ne 1) { return 'a non-rate-limit 403 was retried' }
	if ($r.Output -notmatch 'Access forbidden') { return 'expected an Access forbidden warning' }
}

Test-Case -Name 'generated_at is the real UTC time' -Failures @{} -Assertion {
	param($r, $api)
	if (-not $r.Summary) { return 'no summary was written' }
	if ($r.Summary -notmatch '"generated_at":\s*"([^"]+)"') { return 'no generated_at in the summary' }
	$stamp = [DateTimeOffset]::Parse($Matches[1], [System.Globalization.CultureInfo]::InvariantCulture)
	$skew = [Math]::Abs(([DateTimeOffset]::UtcNow - $stamp).TotalMinutes)
	if ($skew -gt 5) { return "generated_at $($Matches[1]) is $([Math]::Round($skew)) minutes from UTC now" }
}

Write-Host ''
if ($script:Failures -gt 0) {
	Write-Host "$script:Failures of $script:Count case(s) failed." -ForegroundColor Red
	exit 1
}

Write-Host "All $script:Count case(s) passed." -ForegroundColor Green
