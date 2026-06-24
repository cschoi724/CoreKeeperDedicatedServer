Set-StrictMode -Version 2.0

$commonModule = Join-Path $PSScriptRoot "CoreKeeper.Common.psm1"
$configModule = Join-Path $PSScriptRoot "CoreKeeper.Config.psm1"
$pathsModule = Join-Path $PSScriptRoot "CoreKeeper.Paths.psm1"
Import-Module $commonModule -Force
Import-Module $configModule -Force
Import-Module $pathsModule -Force

$script:LaunchCandidateNames = @(
    "StartServer.bat",
    "start-server.bat",
    "start_server.bat",
    "run-server.bat",
    "CoreKeeperServer.exe",
    "CoreKeeper Dedicated Server.exe",
    "Core Keeper Dedicated Server.exe"
)

function Get-CKServerLaunchCandidates {
    [CmdletBinding()]
    param(
        [hashtable]$Settings
    )

    if ($null -eq $Settings) {
        $Settings = Get-CKSettings
    }

    $paths = Get-CKPathSet -Settings $Settings
    if (-not (Test-Path -LiteralPath $paths.ServerInstallPath -PathType Container)) {
        return @()
    }

    $files = Get-ChildItem -LiteralPath $paths.ServerInstallPath -Recurse -File -ErrorAction SilentlyContinue
    $candidates = @()

    foreach ($name in $script:LaunchCandidateNames) {
        $matches = $files | Where-Object { $_.Name -ieq $name }
        foreach ($match in $matches) {
            $candidates += $match
        }
    }

    if ($candidates.Count -eq 0) {
        $candidates = $files | Where-Object {
            $_.Extension -in @(".bat", ".cmd", ".exe") -and
            ($_.Name -match "server|corekeeper|core keeper")
        }
    }

    return $candidates
}

function Get-CKServerLaunchTarget {
    [CmdletBinding()]
    param(
        [hashtable]$Settings
    )

    $candidates = @(Get-CKServerLaunchCandidates -Settings $Settings)
    if ($candidates.Count -eq 0) {
        return $null
    }

    return $candidates[0]
}

function Get-CKServerProcesses {
    [CmdletBinding()]
    param(
        [hashtable]$Settings
    )

    if ($null -eq $Settings) {
        $Settings = Get-CKSettings
    }

    $paths = Get-CKPathSet -Settings $Settings
    $processes = @()

    foreach ($process in Get-Process -ErrorAction SilentlyContinue) {
        $processPath = $null
        try {
            $processPath = $process.Path
        }
        catch {
            $processPath = $null
        }

        if ($process.ProcessName -match "CoreKeeper|Core Keeper|Dedicated" -or
            ($null -ne $processPath -and $processPath.StartsWith($paths.ServerInstallPath, [System.StringComparison]::OrdinalIgnoreCase))) {
            $processes += $process
        }
    }

    return $processes
}

function Get-CKGameIdHints {
    [CmdletBinding()]
    param(
        [hashtable]$Settings,
        [int]$MaxFiles = 12
    )

    if ($null -eq $Settings) {
        $Settings = Get-CKSettings
    }

    $paths = Get-CKPathSet -Settings $Settings
    $roots = @($paths.ServerInstallPath, $paths.DedicatedServerDataRoot)
    $logFiles = @()

    foreach ($root in $roots) {
        if (Test-Path -LiteralPath $root -PathType Container) {
            $logFiles += Get-ChildItem -LiteralPath $root -Recurse -File -ErrorAction SilentlyContinue |
                Where-Object { $_.Extension -in @(".log", ".txt") } |
                Sort-Object LastWriteTime -Descending |
                Select-Object -First $MaxFiles
        }
    }

    $hints = @()
    foreach ($file in ($logFiles | Sort-Object FullName -Unique | Select-Object -First $MaxFiles)) {
        try {
            $matches = Select-String -LiteralPath $file.FullName -Pattern "Game ID|GameID|game id|join code|Join Code" -CaseSensitive:$false -ErrorAction Stop
            foreach ($match in $matches) {
                $hints += [pscustomobject]@{
                    Path = $file.FullName
                    LineNumber = $match.LineNumber
                    Text = $match.Line.Trim()
                }
            }
        }
        catch {
        }
    }

    return $hints
}

function Get-CKServerStatus {
    [CmdletBinding()]
    param(
        [hashtable]$Settings
    )

    if ($null -eq $Settings) {
        $Settings = Get-CKSettings
    }

    $paths = Get-CKPathSet -Settings $Settings
    $launchTarget = Get-CKServerLaunchTarget -Settings $Settings
    $processes = @(Get-CKServerProcesses -Settings $Settings)

    return [pscustomobject]@{
        ServerInstallPathExists = Test-Path -LiteralPath $paths.ServerInstallPath -PathType Container
        DedicatedServerDataRootExists = Test-Path -LiteralPath $paths.DedicatedServerDataRoot -PathType Container
        WorldsPathExists = Test-Path -LiteralPath $paths.WorldsPath -PathType Container
        ServerConfigExists = Test-Path -LiteralPath $paths.ServerConfigPath -PathType Leaf
        LaunchTarget = if ($null -eq $launchTarget) { $null } else { $launchTarget.FullName }
        RunningProcessCount = $processes.Count
        RunningProcesses = $processes | Select-Object Id, ProcessName, Path
        GameIdHints = Get-CKGameIdHints -Settings $Settings
    }
}

function Start-CKDedicatedServer {
    [CmdletBinding()]
    param(
        [hashtable]$Settings
    )

    Assert-CKWindows -Operation "Dedicated Server start"

    if ($null -eq $Settings) {
        $Settings = Get-CKSettings
    }

    $target = Get-CKServerLaunchTarget -Settings $Settings
    if ($null -eq $target) {
        $paths = Get-CKPathSet -Settings $Settings
        throw "Could not find a Core Keeper Dedicated Server launch file under $($paths.ServerInstallPath). Run .\scripts\install-server.ps1 first, then verify the latest Windows launch file name."
    }

    $workingDirectory = Split-Path -Parent $target.FullName
    Write-CKInfo "Starting Core Keeper Dedicated Server: $($target.FullName)"
    Write-CKInfo "Working directory: $workingDirectory"
    $process = Start-Process -FilePath $target.FullName -WorkingDirectory $workingDirectory -PassThru
    Write-CKInfo "Started process id: $($process.Id)"
    Write-CKInfo "Check the server console or logs for the Steam SDR Game ID."
    return $process
}

Export-ModuleMember -Function Get-CKServerLaunchCandidates, Get-CKServerLaunchTarget, Get-CKServerProcesses, Get-CKGameIdHints, Get-CKServerStatus, Start-CKDedicatedServer
