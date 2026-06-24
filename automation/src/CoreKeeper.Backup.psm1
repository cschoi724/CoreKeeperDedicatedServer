Set-StrictMode -Version 2.0

$commonModule = Join-Path $PSScriptRoot "CoreKeeper.Common.psm1"
$configModule = Join-Path $PSScriptRoot "CoreKeeper.Config.psm1"
$pathsModule = Join-Path $PSScriptRoot "CoreKeeper.Paths.psm1"
Import-Module $commonModule -Force
Import-Module $configModule -Force
Import-Module $pathsModule -Force

function New-CKBackupName {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("manual", "before-import", "before-update")]
        [string]$Reason
    )

    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    return "$Reason-$timestamp"
}

function Get-CKBackupTargets {
    [CmdletBinding()]
    param(
        [hashtable]$Settings
    )

    if ($null -eq $Settings) {
        $Settings = Get-CKSettings
    }

    $paths = Get-CKPathSet -Settings $Settings
    return @(
        [pscustomobject]@{
            Name = "worlds"
            Source = $paths.WorldsPath
            DestinationName = "worlds"
            Type = "Directory"
        },
        [pscustomobject]@{
            Name = "worldinfos"
            Source = $paths.WorldInfosPath
            DestinationName = "worldinfos"
            Type = "Directory"
        },
        [pscustomobject]@{
            Name = "ServerConfig.json"
            Source = $paths.ServerConfigPath
            DestinationName = "ServerConfig.json"
            Type = "File"
        }
    )
}

function Backup-CKDedicatedServerData {
    [CmdletBinding()]
    param(
        [ValidateSet("manual", "before-import", "before-update")]
        [string]$Reason = "manual",

        [hashtable]$Settings
    )

    Assert-CKWindows -Operation "Dedicated Server backup"

    if ($null -eq $Settings) {
        $Settings = Get-CKSettings
    }

    $paths = Get-CKPathSet -Settings $Settings
    New-CKDirectory -Path $paths.BackupRoot | Out-Null

    $backupName = New-CKBackupName -Reason $Reason
    $backupPath = Join-Path $paths.BackupRoot $backupName
    New-CKDirectory -Path $backupPath | Out-Null

    $copied = @()
    $missing = @()

    foreach ($target in Get-CKBackupTargets -Settings $Settings) {
        $exists = $false
        if ($target.Type -eq "Directory") {
            $exists = Test-Path -LiteralPath $target.Source -PathType Container
        }
        else {
            $exists = Test-Path -LiteralPath $target.Source -PathType Leaf
        }

        if (-not $exists) {
            Write-CKWarn "Backup target is missing and was skipped: $($target.Source)"
            $missing += $target
            continue
        }

        $destination = Join-Path $backupPath $target.DestinationName
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

        Write-CKInfo "Backed up $($target.Name) to $destination"
        $copied += [pscustomobject]@{
            Name = $target.Name
            Source = $target.Source
            Destination = $destination
        }
    }

    $manifest = [pscustomobject]@{
        Reason = $Reason
        CreatedAt = (Get-Date).ToString("o")
        BackupPath = $backupPath
        SourceRoot = $paths.DedicatedServerDataRoot
        Copied = $copied
        Missing = $missing | Select-Object Name, Source, Type
    }

    $manifestPath = Join-Path $backupPath "backup-manifest.json"
    $manifest | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $manifestPath -Encoding UTF8

    if ($copied.Count -eq 0) {
        Write-CKWarn "No Dedicated Server data files were copied. Backup folder and manifest were still created: $backupPath"
    }

    return [pscustomobject]@{
        BackupPath = $backupPath
        ManifestPath = $manifestPath
        CopiedCount = $copied.Count
        MissingCount = $missing.Count
    }
}

Export-ModuleMember -Function New-CKBackupName, Get-CKBackupTargets, Backup-CKDedicatedServerData
