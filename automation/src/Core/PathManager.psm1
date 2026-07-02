Set-StrictMode -Version 2.0

$configManagerModule = Join-Path $PSScriptRoot "ConfigManager.psm1"
Import-Module $configManagerModule -Force

function Expand-GameServerPath {
    [CmdletBinding()]
    param(
        [string]$Path
    )

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $Path
    }

    return [Environment]::ExpandEnvironmentVariables($Path)
}

function Get-GameServerPathSet {
    [CmdletBinding()]
    param(
        [string]$Game = "corekeeper",
        [hashtable]$Settings
    )

    if ($null -eq $Settings) {
        $Settings = Get-GameServerSettings -Game $Game
    }

    $automationRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
    $serverInstallPath = Expand-GameServerPath ([string]$Settings["serverInstallPath"])
    $steamCmdPath = Expand-GameServerPath ([string]$Settings["steamCmdPath"])
    $backupRoot = Expand-GameServerPath ([string]$Settings["backupRoot"])
    $dataRoot = Expand-GameServerPath ([string]$Settings["dataRoot"])

    $paths = [ordered]@{
        AutomationRoot = $automationRoot
        GameId = [string]$Settings["gameId"]
        ServerInstallPath = $serverInstallPath
        SteamCmdPath = $steamCmdPath
        SteamCmdExe = Join-Path $steamCmdPath "steamcmd.exe"
        BackupRoot = $backupRoot
        DedicatedServerDataRoot = $dataRoot
    }

    return [pscustomobject]$paths
}

function Initialize-GameServerRequiredDirectories {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [string]$Game = "corekeeper",
        [hashtable]$Settings
    )

    if ($null -eq $Settings) {
        $Settings = Get-GameServerSettings -Game $Game
    }

    $paths = Get-GameServerPathSet -Game $Game -Settings $Settings
    foreach ($path in @($paths.ServerInstallPath, $paths.SteamCmdPath, $paths.BackupRoot)) {
        if ([string]::IsNullOrWhiteSpace($path)) {
            throw "Required directory path cannot be empty."
        }

        if (Test-Path -LiteralPath $path) {
            $item = Get-Item -LiteralPath $path
            if (-not $item.PSIsContainer) {
                throw "Path exists but is not a directory: $path"
            }
            continue
        }

        if ($PSCmdlet.ShouldProcess($path, "Create directory")) {
            New-Item -ItemType Directory -Path $path -Force | Out-Null
        }
    }

    return $paths
}

function Test-GameServerRequiredPaths {
    [CmdletBinding()]
    param(
        [string]$Game = "corekeeper",
        [hashtable]$Settings
    )

    if ($null -eq $Settings) {
        $Settings = Get-GameServerSettings -Game $Game
    }

    $paths = Get-GameServerPathSet -Game $Game -Settings $Settings
    return [pscustomobject][ordered]@{
        ServerInstallPath = Test-Path -LiteralPath $paths.ServerInstallPath -PathType Container
        SteamCmdPath = Test-Path -LiteralPath $paths.SteamCmdPath -PathType Container
        SteamCmdExe = Test-Path -LiteralPath $paths.SteamCmdExe -PathType Leaf
        BackupRoot = Test-Path -LiteralPath $paths.BackupRoot -PathType Container
        DedicatedServerDataRoot = Test-Path -LiteralPath $paths.DedicatedServerDataRoot -PathType Container
    }
}

Export-ModuleMember -Function Get-GameServerPathSet, Initialize-GameServerRequiredDirectories, Test-GameServerRequiredPaths, Expand-GameServerPath
