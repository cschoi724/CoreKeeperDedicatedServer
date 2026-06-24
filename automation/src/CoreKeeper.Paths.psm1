Set-StrictMode -Version 2.0

$commonModule = Join-Path $PSScriptRoot "CoreKeeper.Common.psm1"
$configModule = Join-Path $PSScriptRoot "CoreKeeper.Config.psm1"
Import-Module $commonModule -Force
Import-Module $configModule -Force

function Get-CKPathSet {
    [CmdletBinding()]
    param(
        [hashtable]$Settings
    )

    if ($null -eq $Settings) {
        $Settings = Get-CKSettings
    }

    return @{
        AutomationRoot = Get-CKAutomationRoot
        ServerInstallPath = [string]$Settings["serverInstallPath"]
        SteamCmdPath = [string]$Settings["steamCmdPath"]
        SteamCmdExe = Join-Path ([string]$Settings["steamCmdPath"]) "steamcmd.exe"
        BackupRoot = [string]$Settings["backupRoot"]
        DedicatedServerDataRoot = Join-Path $env:USERPROFILE "AppData\LocalLow\Pugstorm\Core Keeper\DedicatedServer"
        WorldsPath = Join-Path (Join-Path $env:USERPROFILE "AppData\LocalLow\Pugstorm\Core Keeper\DedicatedServer") "worlds"
        WorldInfosPath = Join-Path (Join-Path $env:USERPROFILE "AppData\LocalLow\Pugstorm\Core Keeper\DedicatedServer") "worldinfos"
        ServerConfigPath = Join-Path (Join-Path $env:USERPROFILE "AppData\LocalLow\Pugstorm\Core Keeper\DedicatedServer") "ServerConfig.json"
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

    $paths = Get-CKPathSet -Settings $Settings
    New-CKDirectory -Path $paths.ServerInstallPath
    New-CKDirectory -Path $paths.SteamCmdPath
    New-CKDirectory -Path $paths.BackupRoot
    return $paths
}

function Test-CKRequiredPaths {
    [CmdletBinding()]
    param(
        [hashtable]$Settings
    )

    if ($null -eq $Settings) {
        $Settings = Get-CKSettings
    }

    $paths = Get-CKPathSet -Settings $Settings
    $result = [ordered]@{
        ServerInstallPath = Test-Path -LiteralPath $paths.ServerInstallPath -PathType Container
        SteamCmdPath = Test-Path -LiteralPath $paths.SteamCmdPath -PathType Container
        SteamCmdExe = Test-Path -LiteralPath $paths.SteamCmdExe -PathType Leaf
        BackupRoot = Test-Path -LiteralPath $paths.BackupRoot -PathType Container
        DedicatedServerDataRoot = Test-Path -LiteralPath $paths.DedicatedServerDataRoot -PathType Container
    }

    return [pscustomobject]$result
}

Export-ModuleMember -Function Get-CKPathSet, Initialize-CKRequiredDirectories, Test-CKRequiredPaths
