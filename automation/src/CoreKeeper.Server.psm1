Set-StrictMode -Version 2.0

$configModule = Join-Path $PSScriptRoot "CoreKeeper.Config.psm1"
$pathsModule = Join-Path $PSScriptRoot "CoreKeeper.Paths.psm1"
$serverManagerModule = Join-Path (Join-Path $PSScriptRoot "Core") "ServerManager.psm1"
Import-Module $configModule -Force
Import-Module $pathsModule -Force
Import-Module $serverManagerModule -Force

function Get-CKServerLaunchCandidates { param([hashtable]$Settings) if ($null -eq $Settings) { $Settings = Get-CKSettings }; return Get-GameServerLaunchCandidates -Game "corekeeper" -Settings $Settings }
function Get-CKServerLaunchTarget { param([hashtable]$Settings) if ($null -eq $Settings) { $Settings = Get-CKSettings }; return Get-GameServerLaunchTarget -Game "corekeeper" -Settings $Settings }
function Get-CKServerProcesses { param([hashtable]$Settings) if ($null -eq $Settings) { $Settings = Get-CKSettings }; return Get-GameServerProcesses -Game "corekeeper" -Settings $Settings }
function Get-CKGameIdHints { param([hashtable]$Settings, [int]$MaxFiles = 12) if ($null -eq $Settings) { $Settings = Get-CKSettings }; return Get-GameServerStatusHints -Game "corekeeper" -Settings $Settings -MaxFiles $MaxFiles }

function Get-CKServerStatus {
    param([hashtable]$Settings)
    if ($null -eq $Settings) { $Settings = Get-CKSettings }
    $status = Get-GameServerStatus -Game "corekeeper" -Settings $Settings
    $paths = Get-CKPathSet -Settings $Settings
    return [pscustomobject]@{
        ServerInstallPathExists = $status.ServerInstallPathExists
        DedicatedServerDataRootExists = $status.DedicatedServerDataRootExists
        WorldsPathExists = Test-Path -LiteralPath $paths.WorldsPath -PathType Container
        ServerConfigExists = Test-Path -LiteralPath $paths.ServerConfigPath -PathType Leaf
        LaunchTarget = $status.LaunchTarget
        RunningProcessCount = $status.RunningProcessCount
        RunningProcesses = $status.RunningProcesses
        GameIdHints = $status.StatusHints
    }
}

function Start-CKDedicatedServer { param([hashtable]$Settings) if ($null -eq $Settings) { $Settings = Get-CKSettings }; return Start-GameServerDedicatedServer -Game "corekeeper" -Settings $Settings }

Export-ModuleMember -Function Get-CKServerLaunchCandidates, Get-CKServerLaunchTarget, Get-CKServerProcesses, Get-CKGameIdHints, Get-CKServerStatus, Start-CKDedicatedServer
