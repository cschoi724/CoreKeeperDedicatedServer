Set-StrictMode -Version 2.0

$srcRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$commonModule = Join-Path $srcRoot "CoreKeeper.Common.psm1"
$configModule = Join-Path $srcRoot "CoreKeeper.Config.psm1"
$pathsModule = Join-Path $srcRoot "CoreKeeper.Paths.psm1"
$backupModule = Join-Path $srcRoot "CoreKeeper.Backup.psm1"
$serverModule = Join-Path $srcRoot "CoreKeeper.Server.psm1"
Import-Module $commonModule -Force
Import-Module $configModule -Force
Import-Module $pathsModule -Force
Import-Module $backupModule -Force
Import-Module $serverModule -Force

function Get-GameServerAdapter {
    [CmdletBinding()]
    param()

    return [pscustomobject]@{
        GameId = "corekeeper"
        DisplayName = "Core Keeper"
        SupportsWorldImport = $true
        SupportsConfigPatch = $true
        SupportsGracefulStop = $false
        SupportsHealthCheck = $false
    }
}

function Test-CoreKeeperWorldFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$WorldFile
    )

    if (-not (Test-Path -LiteralPath $WorldFile -PathType Leaf)) {
        throw "World file does not exist: $WorldFile"
    }

    if (-not $WorldFile.EndsWith(".world.gzip", [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Core Keeper world import requires a single .world.gzip file: $WorldFile"
    }

    $item = Get-Item -LiteralPath $WorldFile
    if ($item.Length -le 0) {
        throw "World file is empty: $WorldFile"
    }

    return $item
}

function Assert-CoreKeeperDedicatedServerStopped {
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

function Set-CoreKeeperJsonPropertyIfExists {
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
            $updated += Set-CoreKeeperJsonPropertyIfExists -Object $property.Value -PropertyNames $PropertyNames -Value $Value -Prefix $propertyPath
        }
    }

    return $updated
}

function Update-GameServerConfig {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [string]$Game = "corekeeper",

        [Parameter(Mandatory = $true)]
        [int]$WorldIndex,

        [hashtable]$Settings
    )

    if (-not [string]::Equals($Game, "corekeeper", [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Core Keeper Adapter cannot patch config for game '$Game'."
    }

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
    $updatedProperties = @(Set-CoreKeeperJsonPropertyIfExists -Object $config -PropertyNames $candidateNames -Value $WorldIndex)

    if ($updatedProperties.Count -eq 0) {
        Write-CKWarn "No known world index field was found in ServerConfig.json. Config was left unchanged."
        return [pscustomobject]@{
            ConfigPath = $paths.ServerConfigPath
            Updated = $false
            UpdatedProperties = @()
        }
    }

    if ($PSCmdlet.ShouldProcess($paths.ServerConfigPath, "Update Core Keeper world index field(s): $($updatedProperties -join ', ')")) {
        try {
            $config | ConvertTo-Json -Depth 50 | Set-Content -LiteralPath $paths.ServerConfigPath -Encoding UTF8 -ErrorAction Stop
        }
        catch {
            throw "Failed to write ServerConfig.json '$($paths.ServerConfigPath)': $($_.Exception.Message)"
        }
    }

    Write-CKInfo "Updated ServerConfig.json world index field(s): $($updatedProperties -join ', ')"
    return [pscustomobject]@{
        ConfigPath = $paths.ServerConfigPath
        Updated = $true
        UpdatedProperties = $updatedProperties
    }
}

function Import-GameServerWorld {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [string]$Game = "corekeeper",

        [Parameter(Mandatory = $true)]
        [string]$WorldFile,

        [ValidateRange(0, 999)]
        [int]$WorldIndex = 0,

        [switch]$ConfirmOverwrite,

        [hashtable]$Settings
    )

    if (-not [string]::Equals($Game, "corekeeper", [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Core Keeper Adapter cannot import worlds for game '$Game'."
    }

    Assert-CKWindows -Operation "Core Keeper world import"

    if ($null -eq $Settings) {
        $Settings = Get-CKSettings
    }

    $source = Test-CoreKeeperWorldFile -WorldFile $WorldFile
    $paths = Get-CKPathSet -Settings $Settings

    if (-not (Test-Path -LiteralPath $paths.DedicatedServerDataRoot -PathType Container)) {
        throw "Dedicated Server data root does not exist: $($paths.DedicatedServerDataRoot). Start the server once to create it, then stop the server before importing."
    }

    Assert-CoreKeeperDedicatedServerStopped -Settings $Settings

    $backup = Backup-CKDedicatedServerData -Reason "before-import" -Settings $Settings -WhatIf:$WhatIfPreference

    New-CKDirectory -Path $paths.WorldsPath -WhatIf:$WhatIfPreference | Out-Null
    $destination = Join-Path $paths.WorldsPath "$WorldIndex.world.gzip"

    if ((Test-Path -LiteralPath $destination -PathType Leaf) -and -not $ConfirmOverwrite.IsPresent) {
        throw "Target world already exists: $destination. Re-run with -ConfirmOverwrite after confirming the before-import backup: $($backup.BackupPath)"
    }

    if ($PSCmdlet.ShouldProcess($destination, "Import Core Keeper world file from $($source.FullName)")) {
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
    }

    $configUpdate = Update-GameServerConfig -Game $Game -WorldIndex $WorldIndex -Settings $Settings -WhatIf:$WhatIfPreference

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

Export-ModuleMember -Function Get-GameServerAdapter, Test-CoreKeeperWorldFile, Assert-CoreKeeperDedicatedServerStopped, Update-GameServerConfig, Import-GameServerWorld
