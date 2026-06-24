Set-StrictMode -Version 2.0

$commonModule = Join-Path $PSScriptRoot "CoreKeeper.Common.psm1"
$configModule = Join-Path $PSScriptRoot "CoreKeeper.Config.psm1"
$pathsModule = Join-Path $PSScriptRoot "CoreKeeper.Paths.psm1"
$backupModule = Join-Path $PSScriptRoot "CoreKeeper.Backup.psm1"
$serverModule = Join-Path $PSScriptRoot "CoreKeeper.Server.psm1"
Import-Module $commonModule -Force
Import-Module $configModule -Force
Import-Module $pathsModule -Force
Import-Module $backupModule -Force
Import-Module $serverModule -Force

function Test-CKWorldFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$WorldFile
    )

    if (-not (Test-Path -LiteralPath $WorldFile -PathType Leaf)) {
        throw "World file does not exist: $WorldFile"
    }

    if (-not $WorldFile.EndsWith(".world.gzip", [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "World file must be a single .world.gzip file: $WorldFile"
    }

    $item = Get-Item -LiteralPath $WorldFile
    if ($item.Length -le 0) {
        throw "World file is empty: $WorldFile"
    }

    return $item
}

function Assert-CKDedicatedServerStopped {
    [CmdletBinding()]
    param(
        [hashtable]$Settings
    )

    $processes = @(Get-CKServerProcesses -Settings $Settings)
    if ($processes.Count -gt 0) {
        $summary = ($processes | Select-Object -First 5 | ForEach-Object { "$($_.ProcessName)($($_.Id))" }) -join ", "
        throw "Core Keeper Dedicated Server appears to be running: $summary. Stop it safely before importing a world."
    }
}

function Set-CKJsonPropertyIfExists {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Object,

        [Parameter(Mandatory = $true)]
        [string[]]$PropertyNames,

        [Parameter(Mandatory = $true)]
        [int]$Value,

        [string]$Prefix = ""
    )

    $updated = @()
    if ($null -eq $Object -or $Object -isnot [pscustomobject]) {
        return $updated
    }

    foreach ($property in $Object.PSObject.Properties) {
        $propertyPath = if ([string]::IsNullOrWhiteSpace($Prefix)) { $property.Name } else { "$Prefix.$($property.Name)" }

        if ($PropertyNames -contains $property.Name) {
            $property.Value = $Value
            $updated += $propertyPath
            continue
        }

        if ($property.Value -is [pscustomobject]) {
            $updated += Set-CKJsonPropertyIfExists -Object $property.Value -PropertyNames $PropertyNames -Value $Value -Prefix $propertyPath
        }
    }

    return $updated
}

function Update-CKServerConfigWorldIndex {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [int]$WorldIndex,

        [hashtable]$Settings
    )

    if ($null -eq $Settings) {
        $Settings = Get-CKSettings
    }

    $paths = Get-CKPathSet -Settings $Settings
    if (-not (Test-Path -LiteralPath $paths.ServerConfigPath -PathType Leaf)) {
        Write-CKWarn "ServerConfig.json was not found and was not updated: $($paths.ServerConfigPath)"
        return [pscustomobject]@{
            ConfigPath = $paths.ServerConfigPath
            Updated = $false
            UpdatedProperties = @()
        }
    }

    try {
        $config = Get-Content -LiteralPath $paths.ServerConfigPath -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
    }
    catch {
        throw "Failed to parse ServerConfig.json '$($paths.ServerConfigPath)': $($_.Exception.Message)"
    }

    $candidateNames = @("worldIndex", "worldSlot", "worldSlotIndex", "world", "worldId", "worldID")
    $updatedProperties = @(Set-CKJsonPropertyIfExists -Object $config -PropertyNames $candidateNames -Value $WorldIndex)

    if ($updatedProperties.Count -eq 0) {
        Write-CKWarn "No known world index field was found in ServerConfig.json. Config was left unchanged."
        return [pscustomobject]@{
            ConfigPath = $paths.ServerConfigPath
            Updated = $false
            UpdatedProperties = @()
        }
    }

    try {
        $config | ConvertTo-Json -Depth 50 | Set-Content -LiteralPath $paths.ServerConfigPath -Encoding UTF8 -ErrorAction Stop
    }
    catch {
        throw "Failed to write ServerConfig.json '$($paths.ServerConfigPath)': $($_.Exception.Message)"
    }

    Write-CKInfo "Updated ServerConfig.json world index field(s): $($updatedProperties -join ', ')"
    return [pscustomobject]@{
        ConfigPath = $paths.ServerConfigPath
        Updated = $true
        UpdatedProperties = $updatedProperties
    }
}

function Import-CKWorldFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$WorldFile,

        [ValidateRange(0, 999)]
        [int]$WorldIndex = 0,

        [switch]$ConfirmOverwrite,

        [hashtable]$Settings
    )

    Assert-CKWindows -Operation "World import"

    if ($null -eq $Settings) {
        $Settings = Get-CKSettings
    }

    $source = Test-CKWorldFile -WorldFile $WorldFile
    $paths = Get-CKPathSet -Settings $Settings

    if (-not (Test-Path -LiteralPath $paths.DedicatedServerDataRoot -PathType Container)) {
        throw "Dedicated Server data root does not exist: $($paths.DedicatedServerDataRoot). Start the server once to create it, then stop the server before importing."
    }

    Assert-CKDedicatedServerStopped -Settings $Settings

    $backup = Backup-CKDedicatedServerData -Reason "before-import" -Settings $Settings

    New-CKDirectory -Path $paths.WorldsPath | Out-Null
    $destination = Join-Path $paths.WorldsPath "$WorldIndex.world.gzip"

    if ((Test-Path -LiteralPath $destination -PathType Leaf) -and -not $ConfirmOverwrite.IsPresent) {
        throw "Target world already exists: $destination. Re-run with -ConfirmOverwrite after confirming the before-import backup: $($backup.BackupPath)"
    }

    try {
        Copy-Item -LiteralPath $source.FullName -Destination $destination -Force -ErrorAction Stop
    }
    catch {
        throw "Failed to copy world file '$($source.FullName)' to '$destination': $($_.Exception.Message)"
    }

    $copied = Get-Item -LiteralPath $destination
    if ($copied.Length -le 0) {
        throw "Copied world file is empty: $destination"
    }

    $configUpdate = Update-CKServerConfigWorldIndex -WorldIndex $WorldIndex -Settings $Settings

    Write-CKInfo "Imported world file to $destination"
    Write-CKInfo "Original world file was left unchanged: $($source.FullName)"

    return [pscustomobject]@{
        Source = $source.FullName
        Destination = $destination
        WorldIndex = $WorldIndex
        BackupPath = $backup.BackupPath
        ConfigUpdated = $configUpdate.Updated
        UpdatedConfigProperties = $configUpdate.UpdatedProperties
    }
}

Export-ModuleMember -Function Test-CKWorldFile, Assert-CKDedicatedServerStopped, Update-CKServerConfigWorldIndex, Import-CKWorldFile
