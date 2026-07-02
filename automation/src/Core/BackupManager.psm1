Set-StrictMode -Version 2.0

$configManagerModule = Join-Path $PSScriptRoot "ConfigManager.psm1"
$pathManagerModule = Join-Path $PSScriptRoot "PathManager.psm1"
Import-Module $configManagerModule -Force
Import-Module $pathManagerModule -Force

function Write-GSMBackupInfo { param([Parameter(Mandatory = $true)][string]$Message) Write-Host "[INFO] $Message" }
function Write-GSMBackupWarn { param([Parameter(Mandatory = $true)][string]$Message) Write-Warning $Message }

function Assert-GSMBackupWindows {
    param([string]$Operation = "This operation")
    if ($PSVersionTable.PSVersion.Major -ge 6) {
        if (-not $IsWindows) { throw "$Operation requires Windows. macOS is only used for template editing and documentation." }
    }
    elseif ($env:OS -ne "Windows_NT") {
        throw "$Operation requires Windows. macOS is only used for template editing and documentation."
    }
}

function New-GameServerBackupName {
    [CmdletBinding()]
    param([ValidateSet("manual", "before-import", "before-update")][string]$Reason = "manual")
    return "$Reason-$(Get-Date -Format "yyyyMMdd-HHmmss")"
}

function Get-GameServerBackupTargets {
    [CmdletBinding()]
    param([string]$Game = "corekeeper", [hashtable]$Settings)

    if ($null -eq $Settings) { $Settings = Get-GameServerSettings -Game $Game }
    $paths = Get-GameServerPathSet -Game $Game -Settings $Settings
    $targets = @()
    foreach ($target in @($Settings["manifest"]["backup"]["targets"])) {
        $relativePath = [string]$target["path"]
        $name = [string]$target["name"]
        $type = [string]$target["type"]
        $targets += [pscustomobject]@{
            Name = $name
            Source = Join-Path $paths.DedicatedServerDataRoot $relativePath
            DestinationName = $relativePath
            Type = if ($type -ieq "directory") { "Directory" } else { "File" }
        }
    }
    return $targets
}

function Backup-GameServerData {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [string]$Game = "corekeeper",
        [ValidateSet("manual", "before-import", "before-update")]
        [string]$Reason = "manual",
        [hashtable]$Settings
    )

    Assert-GSMBackupWindows -Operation "Dedicated Server backup"
    if ($null -eq $Settings) { $Settings = Get-GameServerSettings -Game $Game }
    $paths = Get-GameServerPathSet -Game $Game -Settings $Settings

    if (-not (Test-Path -LiteralPath $paths.BackupRoot -PathType Container)) {
        if ($PSCmdlet.ShouldProcess($paths.BackupRoot, "Create backup root")) {
            New-Item -ItemType Directory -Path $paths.BackupRoot -Force | Out-Null
        }
    }

    $backupName = New-GameServerBackupName -Reason $Reason
    $backupPath = Join-Path $paths.BackupRoot $backupName
    if ($PSCmdlet.ShouldProcess($backupPath, "Create backup folder")) {
        New-Item -ItemType Directory -Path $backupPath -Force | Out-Null
    }

    $copied = @()
    $missing = @()
    foreach ($target in Get-GameServerBackupTargets -Game $Game -Settings $Settings) {
        $exists = if ($target.Type -eq "Directory") { Test-Path -LiteralPath $target.Source -PathType Container } else { Test-Path -LiteralPath $target.Source -PathType Leaf }
        if (-not $exists) {
            Write-GSMBackupWarn "Backup target is missing and was skipped: $($target.Source)"
            $missing += $target
            continue
        }

        $destination = Join-Path $backupPath $target.DestinationName
        if ($PSCmdlet.ShouldProcess($target.Source, "Back up to $destination")) {
            $destinationParent = Split-Path -Parent $destination
            if (-not [string]::IsNullOrWhiteSpace($destinationParent) -and -not (Test-Path -LiteralPath $destinationParent -PathType Container)) {
                New-Item -ItemType Directory -Path $destinationParent -Force | Out-Null
            }
            try {
                if ($target.Type -eq "Directory") {
                    Copy-Item -LiteralPath $target.Source -Destination $destination -Recurse -Force -ErrorAction Stop
                }
                else {
                    Copy-Item -LiteralPath $target.Source -Destination $destination -Force -ErrorAction Stop
                }
            }
            catch {
                throw "Failed to back up '$($target.Source)' to '$destination': $($_.Exception.Message)"
            }
        }
        Write-GSMBackupInfo "Backed up $($target.Name) to $destination"
        $copied += [pscustomobject]@{ Name = $target.Name; Source = $target.Source; Destination = $destination }
    }

    $manifestPath = Join-Path $backupPath "backup-manifest.json"
    $manifest = [pscustomobject]@{
        Game = $Game
        Reason = $Reason
        CreatedAt = (Get-Date).ToString("o")
        BackupPath = $backupPath
        SourceRoot = $paths.DedicatedServerDataRoot
        Copied = $copied
        Missing = $missing | Select-Object Name, Source, Type
    }
    if ($PSCmdlet.ShouldProcess($manifestPath, "Write backup manifest")) {
        $manifest | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $manifestPath -Encoding UTF8
    }

    return [pscustomobject]@{ BackupPath = $backupPath; ManifestPath = $manifestPath; CopiedCount = $copied.Count; MissingCount = $missing.Count }
}

Export-ModuleMember -Function New-GameServerBackupName, Get-GameServerBackupTargets, Backup-GameServerData
