Set-StrictMode -Version 2.0

$configModule = Join-Path $PSScriptRoot "CoreKeeper.Config.psm1"
$backupManagerModule = Join-Path (Join-Path $PSScriptRoot "Core") "BackupManager.psm1"
Import-Module $configModule -Force
Import-Module $backupManagerModule -Force

function New-CKBackupName {
    param([ValidateSet("manual", "before-import", "before-update")][string]$Reason = "manual")
    return New-GameServerBackupName -Reason $Reason
}

function Get-CKBackupTargets {
    param([hashtable]$Settings)
    if ($null -eq $Settings) { $Settings = Get-CKSettings }
    return Get-GameServerBackupTargets -Game "corekeeper" -Settings $Settings
}

function Backup-CKDedicatedServerData {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [ValidateSet("manual", "before-import", "before-update")]
        [string]$Reason = "manual",
        [hashtable]$Settings
    )
    if ($null -eq $Settings) { $Settings = Get-CKSettings }
    return Backup-GameServerData -Game "corekeeper" -Reason $Reason -Settings $Settings -WhatIf:$WhatIfPreference
}

Export-ModuleMember -Function New-CKBackupName, Get-CKBackupTargets, Backup-CKDedicatedServerData
