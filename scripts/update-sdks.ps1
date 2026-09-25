<#
.SYNOPSIS
	Pins every ktsu MSBuild SDK reference in a repository to one agreed version.

.DESCRIPTION
	Scans global.json and every .csproj for ktsu SDK references, resolves the version each
	package should be on, and rewrites every reference that disagrees.

	The unit of work is the reference, not the package. A repository whose global.json and
	project files disagree about ktsu.Sdk is repaired even when no newer version exists,
	because a partially applied dependency update leaves exactly that state and a build
	that resolves two versions of the same SDK is not reproducible.

	Versions are compared as semantic versions, so 2.9.0 sorts below 2.28.1 and a
	prerelease sorts below the release it precedes. Prereleases are never a target. A
	reference already ahead of the latest release -- which is how a deliberate prerelease
	pin looks -- is reported and left alone rather than rolled backwards.

	Edits are textual and scoped to the version that follows the package name, so a file's
	formatting, key order, comments and trailing newline survive, and a prerelease pin is
	replaced in full rather than losing its suffix.

.PARAMETER Path
	The repository root to scan. Defaults to the current directory.

.PARAMETER Prefix
	The SDK package name prefix. A package matches when it equals the prefix exactly or
	begins with the prefix followed by a dot, so ktsu.Sdk and ktsu.Sdk.Tool both match
	while ktsu.SdkAdjacent does not.

.PARAMETER Version
	Pins every matched package to this version instead of asking NuGet. Intended for
	pinning a whole repository to a known version, and for testing without a network.

.PARAMETER FeedUrl
	The flat container base address to resolve versions from.

.PARAMETER WhatIf
	Reports what would change without writing anything.

.OUTPUTS
	A summary object with Changed, Files and Updates, so a caller can report the same
	facts this writes to the host.
#>
[CmdletBinding(SupportsShouldProcess)]
param(
	[string]$Path = '.',
	[string]$Prefix = 'ktsu.Sdk',
	[string]$Version,
	[string]$FeedUrl = 'https://api.nuget.org/v3-flatcontainer'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# A package belongs to the family when it is the prefix itself or sits under it. Matching on
# the prefix alone would be wrong in both directions: "ktsu.Sdk.*" as a wildcard misses the
# bare ktsu.Sdk, which is the package nearly every repository pins, and a bare StartsWith
# would claim an unrelated ktsu.SdkSomething.
function Test-InFamily {
	param([string]$Name, [string]$Prefix)

	return $Name -eq $Prefix -or $Name.StartsWith("$Prefix.", [System.StringComparison]::Ordinal)
}

function ConvertTo-SemanticVersion {
	param([string]$Text)

	[System.Management.Automation.SemanticVersion]$parsed = $null
	if ([System.Management.Automation.SemanticVersion]::TryParse($Text, [ref]$parsed)) {
		return $parsed
	}

	return $null
}

# The flat container index lists every published version. It is documented as sorted, but
# sorting it here costs nothing and means a feed that ever stops being sorted -- or a mirror
# that never was -- does not silently hand back the wrong answer.
function Get-LatestReleasedVersion {
	param([string]$PackageId, [string]$FeedUrl)

	# The flat container addresses packages in lower case.
	$id = $PackageId.ToLowerInvariant()
	$index = Invoke-RestMethod -Uri "$FeedUrl/$id/index.json"

	$released =
		$index.versions |
		ForEach-Object { ConvertTo-SemanticVersion $_ } |
		Where-Object { $null -ne $_ -and -not $_.PreReleaseLabel }

	if (-not $released) {
		return $null
	}

	return ($released | Sort-Object -Descending)[0].ToString()
}

# Every reference to one package in one file. Collecting them individually, rather than
# collapsing to one version per package, is what lets a disagreement be seen at all.
function Get-SdkReference {
	param([string]$Root, [string]$Prefix)

	$references = [System.Collections.Generic.List[object]]::new()

	foreach ($file in Get-ChildItem -Path $Root -Recurse -File -Filter 'global.json') {
		$text = Get-Content -LiteralPath $file.FullName -Raw
		foreach ($match in [regex]::Matches($text, '"(?<name>[^"\s]+)"\s*:\s*"(?<version>[^"]+)"')) {
			$name = $match.Groups['name'].Value
			if (Test-InFamily -Name $name -Prefix $Prefix) {
				$references.Add([pscustomobject]@{ File = $file.FullName; Name = $name; Version = $match.Groups['version'].Value })
			}
		}
	}

	foreach ($file in Get-ChildItem -Path $Root -Recurse -File -Filter '*.csproj') {
		$text = Get-Content -LiteralPath $file.FullName -Raw
		# Anything up to the closing quote, so a prerelease pin is captured whole. The old
		# pattern stopped at digits and dots, which read 2.0.0 out of 2.0.0-pre.1 and then
		# replaced only that part, leaving a version string that had never been published.
		foreach ($match in [regex]::Matches($text, 'Sdk\s*=\s*"(?<name>[^"/]+)/(?<version>[^"]+)"')) {
			$name = $match.Groups['name'].Value
			if (Test-InFamily -Name $name -Prefix $Prefix) {
				$references.Add([pscustomobject]@{ File = $file.FullName; Name = $name; Version = $match.Groups['version'].Value })
			}
		}
	}

	return $references
}

function Set-SdkReference {
	param([string]$FilePath, [string]$Name, [string]$Target)

	$original = Get-Content -LiteralPath $FilePath -Raw
	$quoted = [regex]::Escape($Name)

	$updated = [regex]::Replace($original, "(?<head>`"$quoted`"\s*:\s*`")[^`"]+(?<tail>`")", "`${head}$Target`${tail}")
	$updated = [regex]::Replace($updated, "(?<head>Sdk\s*=\s*`"$quoted/)[^`"]+(?<tail>`")", "`${head}$Target`${tail}")

	if ($updated -eq $original) {
		return $false
	}

	# -NoNewline writes exactly these bytes. The file already ends how it ends; re-serializing
	# it through ConvertTo-Json would reformat every line that this change never touched.
	Set-Content -LiteralPath $FilePath -Value $updated -NoNewline
	return $true
}

$root = (Resolve-Path -LiteralPath $Path).Path
$references = @(Get-SdkReference -Root $root -Prefix $Prefix)

if ($references.Count -eq 0) {
	Write-Host "No $Prefix references found under $root."
	return [pscustomobject]@{ Changed = $false; Files = @(); Updates = @() }
}

Write-Host "Found $($references.Count) $Prefix reference(s):"
foreach ($group in $references | Group-Object Name | Sort-Object Name) {
	$pinned = ($group.Group.Version | Sort-Object -Unique) -join ', '
	Write-Host "  $($group.Name): $pinned"
}

# A package that cannot be resolved is a failure, but it is not a reason to stop looking at the
# rest of them. $ErrorActionPreference is Stop in this scope, which makes a bare Write-Error
# terminating, so the first unresolvable package used to throw straight out of the script and
# the `continue` beneath it was dead code. A maintainer saw one failure per run and had to fix
# and rerun to discover the next. Failures are named on the error stream as they happen, and
# the run fails once, after every package has been looked at.
$failed = [System.Collections.Generic.List[string]]::new()

$targets = @{}
foreach ($group in $references | Group-Object Name | Sort-Object Name) {
	$name = $group.Name

	if ($Version) {
		$targets[$name] = $Version
		continue
	}

	$latest = $null
	try {
		$latest = Get-LatestReleasedVersion -PackageId $name -FeedUrl $FeedUrl
	}
	catch {
		# A lookup failure must not be reported as "up to date". That conflation is what let
		# this run green and do nothing every week: a parse error inside the lookup was caught
		# and turned into a null, and a null read as "no update available".
		Write-Error "Could not resolve the latest version of $name from $FeedUrl : $($_.Exception.Message)" -ErrorAction Continue
		$failed.Add($name)
		continue
	}

	if (-not $latest) {
		Write-Error "$name has no released version on $FeedUrl." -ErrorAction Continue
		$failed.Add($name)
		continue
	}

	# A reference ahead of the newest release is a deliberate prerelease pin. Converging on
	# the release would be a downgrade, so the highest pinned version becomes the target and
	# the rest of the repository is brought up to meet it.
	$highest = ($group.Group.Version | ForEach-Object { ConvertTo-SemanticVersion $_ } | Where-Object { $null -ne $_ } | Sort-Object -Descending | Select-Object -First 1)
	if ($highest -and $highest -gt (ConvertTo-SemanticVersion $latest)) {
		Write-Host "  $name is pinned to $highest, ahead of the latest release $latest; converging on $highest."
		$targets[$name] = $highest.ToString()
		continue
	}

	$targets[$name] = $latest
}

# Failing here rather than earlier is what makes one run report every unresolvable package. It
# is still before anything is written, so a run that could not resolve part of the family does
# not leave the repository half-converged -- which is the very state this script exists to
# repair. The messages above carry the reasons; this carries the verdict.
if ($failed.Count -gt 0) {
	throw "Could not resolve $($failed.Count) of $($targets.Count + $failed.Count) $Prefix package(s): $($failed -join ', ')"
}

$stale = @($references | Where-Object { $targets.ContainsKey($_.Name) -and $_.Version -ne $targets[$_.Name] })

if ($stale.Count -eq 0) {
	Write-Host "Every $Prefix reference is already on its target version."
	return [pscustomobject]@{ Changed = $false; Files = @(); Updates = @() }
}

$updates =
	$stale |
	Group-Object Name |
	Sort-Object Name |
	ForEach-Object {
		[pscustomobject]@{
			Name = $_.Name
			From = ($_.Group.Version | Sort-Object -Unique) -join ', '
			To = $targets[$_.Name]
			References = $_.Count
		}
	}

Write-Host 'Updating:'
foreach ($update in $updates) {
	Write-Host "  $($update.Name): $($update.From) -> $($update.To) ($($update.References) reference(s))"
}

$changedFiles = [System.Collections.Generic.List[string]]::new()
foreach ($group in $stale | Group-Object File) {
	$file = $group.Name
	if (-not $PSCmdlet.ShouldProcess($file, 'Update SDK references')) {
		continue
	}

	$touched = $false
	foreach ($name in ($group.Group.Name | Sort-Object -Unique)) {
		if (Set-SdkReference -FilePath $file -Name $name -Target $targets[$name]) {
			$touched = $true
		}
	}

	if ($touched) {
		$changedFiles.Add([System.IO.Path]::GetRelativePath($root, $file))
	}
}

foreach ($file in $changedFiles) {
	Write-Host "  wrote $file"
}

return [pscustomobject]@{ Changed = $changedFiles.Count -gt 0; Files = $changedFiles.ToArray(); Updates = $updates }
