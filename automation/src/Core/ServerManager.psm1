Set-StrictMode -Version 2.0

$configManagerModule = Join-Path $PSScriptRoot "ConfigManager.psm1"
$pathManagerModule = Join-Path $PSScriptRoot "PathManager.psm1"
Import-Module $configManagerModule -Force
Import-Module $pathManagerModule -Force

function Write-GSMServerInfo {
    param([Parameter(Mandatory = $true)][string]$Message)
    Write-Host "[INFO] $Message"
}

function Assert-GSMServerWindows {
    param([string]$Operation = "This operation")
    if ($PSVersionTable.PSVersion.Major -ge 6) {
        if (-not $IsWindows) { throw "$Operation requires Windows. macOS is only used for template editing and documentation." }
    }
    elseif ($env:OS -ne "Windows_NT") {
        throw "$Operation requires Windows. macOS is only used for template editing and documentation."
    }
}

function Get-GameServerLaunchCandidates {
    [CmdletBinding()]
    param([string]$Game = "corekeeper", [hashtable]$Settings)

    if ($null -eq $Settings) { $Settings = Get-GameServerSettings -Game $Game }
    $paths = Get-GameServerPathSet -Game $Game -Settings $Settings
    if (-not (Test-Path -LiteralPath $paths.ServerInstallPath -PathType Container)) { return @() }

    $manifest = $Settings["manifest"]
    $names = @($manifest["server"]["launchCandidates"])
    $files = Get-ChildItem -LiteralPath $paths.ServerInstallPath -Recurse -File -ErrorAction SilentlyContinue
    $candidates = @()
    foreach ($name in $names) {
        $matches = $files | Where-Object { $_.Name -ieq $name }
        foreach ($match in $matches) { $candidates += $match }
    }
    return $candidates
}

function Get-GameServerLaunchTarget {
    [CmdletBinding()]
    param([string]$Game = "corekeeper", [hashtable]$Settings)

    $candidates = @(Get-GameServerLaunchCandidates -Game $Game -Settings $Settings)
    if ($candidates.Count -eq 0) { return $null }
    return $candidates[0]
}

function Get-GameServerProcesses {
    [CmdletBinding()]
    param([string]$Game = "corekeeper", [hashtable]$Settings)

    if ($null -eq $Settings) { $Settings = Get-GameServerSettings -Game $Game }
    $paths = Get-GameServerPathSet -Game $Game -Settings $Settings
    $patterns = @($Settings["manifest"]["server"]["processNamePatterns"])
    $processes = @()

    foreach ($process in Get-Process -ErrorAction SilentlyContinue) {
        $processPath = $null
        try { $processPath = $process.Path } catch { $processPath = $null }

        $matched = $false
        foreach ($pattern in $patterns) {
            if (-not [string]::IsNullOrWhiteSpace([string]$pattern) -and $process.ProcessName -match [regex]::Escape([string]$pattern)) {
                $matched = $true
                break
            }
        }

        if ($matched -or ($null -ne $processPath -and $processPath.StartsWith($paths.ServerInstallPath, [System.StringComparison]::OrdinalIgnoreCase))) {
            $processes += $process
        }
    }
    return $processes
}

function Get-GameServerStatusHints {
    [CmdletBinding()]
    param([string]$Game = "corekeeper", [hashtable]$Settings, [int]$MaxFiles = 12)

    if ($null -eq $Settings) { $Settings = Get-GameServerSettings -Game $Game }
    $paths = Get-GameServerPathSet -Game $Game -Settings $Settings
    $manifest = $Settings["manifest"]
    $roots = @($paths.ServerInstallPath, $paths.DedicatedServerDataRoot)
    foreach ($directory in @($manifest["logs"]["directories"])) {
        if (-not [string]::IsNullOrWhiteSpace([string]$directory)) {
            $roots += Join-Path $paths.DedicatedServerDataRoot ([string]$directory)
        }
    }

    $logFiles = @()
    foreach ($root in $roots) {
        if (Test-Path -LiteralPath $root -PathType Container) {
            $logFiles += Get-ChildItem -LiteralPath $root -Recurse -File -ErrorAction SilentlyContinue |
                Where-Object { $_.Extension -in @(".log", ".txt") } |
                Sort-Object LastWriteTime -Descending |
                Select-Object -First $MaxFiles
        }
    }

    $patterns = @($manifest["logs"]["statusPatterns"]) | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) }
    if ($patterns.Count -eq 0) { return @() }

    $hints = @()
    foreach ($file in ($logFiles | Sort-Object FullName -Unique | Select-Object -First $MaxFiles)) {
        try {
            $matches = Select-String -LiteralPath $file.FullName -Pattern $patterns -CaseSensitive:$false -ErrorAction Stop
            foreach ($match in $matches) {
                $hints += [pscustomobject]@{ Path = $file.FullName; LineNumber = $match.LineNumber; Text = $match.Line.Trim() }
            }
        }
        catch {}
    }
    return $hints
}

function Get-GameServerStatus {
    [CmdletBinding()]
    param([string]$Game = "corekeeper", [hashtable]$Settings)

    if ($null -eq $Settings) { $Settings = Get-GameServerSettings -Game $Game }
    $paths = Get-GameServerPathSet -Game $Game -Settings $Settings
    $launchTarget = Get-GameServerLaunchTarget -Game $Game -Settings $Settings
    $processes = @(Get-GameServerProcesses -Game $Game -Settings $Settings)
    return [pscustomobject]@{
        GameId = [string]$Settings["gameId"]
        DisplayName = [string]$Settings["displayName"]
        ServerInstallPathExists = Test-Path -LiteralPath $paths.ServerInstallPath -PathType Container
        DedicatedServerDataRootExists = Test-Path -LiteralPath $paths.DedicatedServerDataRoot -PathType Container
        LaunchTarget = if ($null -eq $launchTarget) { $null } else { $launchTarget.FullName }
        RunningProcessCount = $processes.Count
        RunningProcesses = $processes | Select-Object Id, ProcessName, Path
        StatusHints = Get-GameServerStatusHints -Game $Game -Settings $Settings
    }
}

function Start-GameServerDedicatedServer {
    [CmdletBinding()]
    param([string]$Game = "corekeeper", [hashtable]$Settings)

    Assert-GSMServerWindows -Operation "Dedicated Server start"
    if ($null -eq $Settings) { $Settings = Get-GameServerSettings -Game $Game }
    $target = Get-GameServerLaunchTarget -Game $Game -Settings $Settings
    $displayName = [string]$Settings["displayName"]
    if ($null -eq $target) {
        $paths = Get-GameServerPathSet -Game $Game -Settings $Settings
        throw ("Could not find a {0} Dedicated Server launch file under {1}. Run .\scripts\install-server.ps1 -Game {2} first, then verify the latest Windows launch file name." -f $displayName, $paths.ServerInstallPath, $Game)
    }
    $workingDirectory = Split-Path -Parent $target.FullName
    Write-GSMServerInfo ("Starting {0} Dedicated Server: {1}" -f $displayName, $target.FullName)
    Write-GSMServerInfo "Working directory: $workingDirectory"
    $process = Start-Process -FilePath $target.FullName -WorkingDirectory $workingDirectory -PassThru
    Write-GSMServerInfo "Started process id: $($process.Id)"
    return $process
}

Export-ModuleMember -Function Get-GameServerLaunchCandidates, Get-GameServerLaunchTarget, Get-GameServerProcesses, Get-GameServerStatusHints, Get-GameServerStatus, Start-GameServerDedicatedServer
