# PowerShell script to organize and sort the memory.jsonl file
$ErrorActionPreference = "Stop"

# Define file paths
$memoryFilePath = Join-Path $PSScriptRoot "memory.jsonl"
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupFilePath = Join-Path $PSScriptRoot "memory.jsonl.backup-$timestamp"

Write-Host "Reading memory file: $memoryFilePath"

# Check if the file exists
if (-not (Test-Path $memoryFilePath)) {
    Write-Host "Error: Memory file not found at $memoryFilePath"
    exit
}

try {
    # Create a backup of the original file
    Copy-Item -Path $memoryFilePath -Destination $backupFilePath -Force
    Write-Host "Created backup at: $backupFilePath"

    # Read the memory file
    $lines = Get-Content $memoryFilePath -Encoding UTF8
    Write-Host "Found $($lines.Count) lines in the memory file"
    
    # Parse each line as JSON
    $memoryObjects = @()
    for ($i = 0; $i -lt $lines.Count; $i++) {
        try {
            $obj = $lines[$i] | ConvertFrom-Json
            $memoryObjects += $obj
        } catch {
            Write-Host "Error parsing JSON at line $($i+1): $_"
            Write-Host "Problematic line: $($lines[$i])"
        }
    }
    
    Write-Host "Successfully parsed $($memoryObjects.Count) objects"
    
    # Define entity type order
    $entityTypeOrder = @{
        "Developer" = 1
        "Project" = 2
        "Concept" = 3
        "Library" = 4
        "Tool" = 5
        "ToolCategory" = 6
        "Pattern" = 7
        "Class" = 8
        "TechnologyStack" = 9
        "Function" = 10
    }
    
    # Separate entities and relations
    $entities = @()
    $relations = @()
    foreach ($obj in $memoryObjects) {
        if ($obj.type -eq "entity") {
            $entities += $obj
        } elseif ($obj.type -eq "relation") {
            $relations += $obj
        } else {
            # Keep other objects as is (though there shouldn't be any)
            $relations += $obj
        }
    }
    
    Write-Host "Found $($entities.Count) entities and $($relations.Count) relations"
    
    # Sort entities by type and then by name
    $sortedEntities = $entities | Sort-Object -Property @{
        Expression = {
            if ($_.type -ne "entity") { 999 } 
            else { 
                $order = $entityTypeOrder[$_.entityType]
                if ($null -eq $order) { 100 } else { $order }
            }
        }
    }, @{
        Expression = { $_.entityType }
    }, @{
        Expression = { $_.name -as [string] }
    }
    
    # Sort relations by relation type and then by source and target entities
    $sortedRelations = $relations | Sort-Object -Property @{
        Expression = { $_.relationType -as [string] }
    }, @{
        Expression = { $_.from -as [string] }
    }, @{
        Expression = { $_.to -as [string] }
    }

    # Function to order object properties based on object type
    function Order-Properties {
        param (
            [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
            [PSCustomObject]$InputObject
        )

        process {
            $orderedObject = [ordered]@{}
            
            # Define property order based on object type
            if ($InputObject.type -eq "entity") {
                # Entity property order
                $propertyOrder = @("type", "entityType", "name", "observations")
                
                # Add properties in order
                foreach ($prop in $propertyOrder) {
                    if ($InputObject.PSObject.Properties.Name -contains $prop) {
                        $orderedObject[$prop] = $InputObject.$prop
                    }
                }
                
                # Add any remaining properties not in the defined order
                foreach ($prop in $InputObject.PSObject.Properties.Name) {
                    if ($prop -notin $propertyOrder) {
                        $orderedObject[$prop] = $InputObject.$prop
                    }
                }
            } 
            elseif ($InputObject.type -eq "relation") {
                # Relation property order
                $propertyOrder = @("type", "from", "relationType", "to")
                
                # Add properties in order
                foreach ($prop in $propertyOrder) {
                    if ($InputObject.PSObject.Properties.Name -contains $prop) {
                        $orderedObject[$prop] = $InputObject.$prop
                    }
                }
                
                # Add any remaining properties not in the defined order
                foreach ($prop in $InputObject.PSObject.Properties.Name) {
                    if ($prop -notin $propertyOrder) {
                        $orderedObject[$prop] = $InputObject.$prop
                    }
                }
            } 
            else {
                # For any other object type, use all properties as-is
                foreach ($prop in $InputObject.PSObject.Properties.Name) {
                    $orderedObject[$prop] = $InputObject.$prop
                }
            }
            
            # Convert ordered hashtable back to object
            return [PSCustomObject]$orderedObject
        }
    }
    
    # Combine sorted entities and relations
    $sortedObjects = $sortedEntities + $sortedRelations
    
    # Write the organized memory directly to the original file
    $output = @()
    foreach ($obj in $sortedObjects) {
        # Apply property ordering
        $orderedObj = $obj | Order-Properties
        
        # Convert to JSON with ordered properties
        $json = $orderedObj | ConvertTo-Json -Compress -Depth 10
        $output += $json
    }
    $output | Out-File $memoryFilePath -Encoding UTF8
    
    Write-Host "Memory file successfully organized with properties in logical order"
    Write-Host "Original file backed up to: $backupFilePath"
    
} catch {
    Write-Host "An error occurred: $_"
    Write-Host "If needed, you can restore from the backup at: $backupFilePath"
}