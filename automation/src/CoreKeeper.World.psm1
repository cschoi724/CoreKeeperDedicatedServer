Set-StrictMode -Version 2.0

$commonModule = Join-Path $PSScriptRoot "CoreKeeper.Common.psm1"
$configModule = Join-Path $PSScriptRoot "CoreKeeper.Config.psm1"
$adapterManagerModule = Join-Path (Join-Path $PSScriptRoot "Core") "AdapterManager.psm1"
Import-Module $commonModule -Force
Import-Module $configModule -Force
Import-Module $adapterManagerModule -Prefix "GSM" -Force

function Import-CKWorldAdapterModule {
    [CmdletBinding()]
    param(
        [string]$Game = "corekeeper"
    )

    if ([string]::IsNullOrWhiteSpace($Game)) {
        $Game = "corekeeper"
    }

    $adapter = Get-GSMGameServerAdapter -Game $Game
    $features = $adapter.Manifest["features"]
    $supportsWorldImport = $false
    if ($null -ne $features -and $features.ContainsKey("worldImport")) {
        $supportsWorldImport = [bool]$features["worldImport"]
    }

    if (-not $supportsWorldImport) {
        throw "Game '$Game' does not support world import. Adapter features.worldImport is false."
    }

    $adapterDirectory = Split-Path -Parent $adapter.ManifestPath
    $adapterDirectoryName = Split-Path -Leaf $adapterDirectory
    $adapterModule = Join-Path $adapterDirectory "$adapterDirectoryName.Adapter.psm1"
    if (-not (Test-Path -LiteralPath $adapterModule -PathType Leaf)) {
        throw "Game '$Game' declares world import support but Adapter module was not found: $adapterModule"
    }

    Import-Module $adapterModule -Force
    if ($null -eq (Get-Command -Name "Import-GameServerWorld" -ErrorAction SilentlyContinue)) {
        throw "Game '$Game' Adapter does not export Import-GameServerWorld."
    }

    return $adapter
}

function Test-CKWorldFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$WorldFile
    )

    Import-CKWorldAdapterModule -Game "corekeeper" | Out-Null
    if ($null -eq (Get-Command -Name "Test-CoreKeeperWorldFile" -ErrorAction SilentlyContinue)) {
        throw "Core Keeper Adapter does not export Test-CoreKeeperWorldFile."
    }
    return Test-CoreKeeperWorldFile -WorldFile $WorldFile
}

function Update-CKServerConfigWorldIndex {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [int]$WorldIndex,

        [hashtable]$Settings
    )

    if ($null -eq $Settings) {
        $Settings = Get-CKSettings
    }

    Import-CKWorldAdapterModule -Game "corekeeper" | Out-Null
    if ($null -eq (Get-Command -Name "Update-GameServerConfig" -ErrorAction SilentlyContinue)) {
        throw "Core Keeper Adapter does not export Update-GameServerConfig."
    }
    return Update-GameServerConfig -Game "corekeeper" -WorldIndex $WorldIndex -Settings $Settings -WhatIf:$WhatIfPreference
}

function Import-CKWorldFile {
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

    if ([string]::IsNullOrWhiteSpace($Game)) {
        $Game = "corekeeper"
    }

    Import-CKWorldAdapterModule -Game $Game | Out-Null
    return Import-GameServerWorld -Game $Game -WorldFile $WorldFile -WorldIndex $WorldIndex -ConfirmOverwrite:$ConfirmOverwrite -Settings $Settings -WhatIf:$WhatIfPreference
}

Export-ModuleMember -Function Test-CKWorldFile, Update-CKServerConfigWorldIndex, Import-CKWorldFile
