Set-StrictMode -Version 2.0

$pathManagerModule = Join-Path (Join-Path $PSScriptRoot "Core") "PathManager.psm1"
$configModule = Join-Path $PSScriptRoot "CoreKeeper.Config.psm1"
Import-Module $pathManagerModule -Force
Import-Module $configModule -Force

function Get-CKPathSet {
    [CmdletBinding()]
    param(
        [hashtable]$Settings
    )

    if ($null -eq $Settings) {
        $Settings = Get-CKSettings
    }

    $paths = Get-GameServerPathSet -Game "corekeeper" -Settings $Settings
    $dataRoot = [string]$paths.DedicatedServerDataRoot

    return [pscustomobject][ordered]@{
        AutomationRoot = $paths.AutomationRoot
        GameId = $paths.GameId
        ServerInstallPath = $paths.ServerInstallPath
        SteamCmdPath = $paths.SteamCmdPath
        SteamCmdExe = $paths.SteamCmdExe
        BackupRoot = $paths.BackupRoot
        DedicatedServerDataRoot = $paths.DedicatedServerDataRoot
        WorldsPath = Join-Path $dataRoot "worlds"
        WorldInfosPath = Join-Path $dataRoot "worldinfos"
        ServerConfigPath = Join-Path $dataRoot "ServerConfig.json"
    }
}

function Initialize-CKRequiredDirectories {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [hashtable]$Settings
    )

    if ($null -eq $Settings) {
        $Settings = Get-CKSettings
    }

    Initialize-GameServerRequiredDirectories -Game "corekeeper" -Settings $Settings | Out-Null
    return Get-CKPathSet -Settings $Settings
}

function Test-CKRequiredPaths {
    [CmdletBinding()]
    param(
        [hashtable]$Settings
    )

    if ($null -eq $Settings) {
        $Settings = Get-CKSettings
    }

    return Test-GameServerRequiredPaths -Game "corekeeper" -Settings $Settings
}

Export-ModuleMember -Function Get-CKPathSet, Initialize-CKRequiredDirectories, Test-CKRequiredPaths
