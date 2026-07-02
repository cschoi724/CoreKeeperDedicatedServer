[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$Game = "corekeeper",
    [ValidateSet("manual", "before-import", "before-update")]
    [string]$Reason = "manual",

    [string]$SettingsPath
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"

$automationRoot = Split-Path -Parent $PSScriptRoot
$commonModule = Join-Path $automationRoot "src\CoreKeeper.Common.psm1"
$configModule = Join-Path $automationRoot "src\Core\ConfigManager.psm1"
$backupModule = Join-Path $automationRoot "src\Core\BackupManager.psm1"

Import-Module $commonModule -Force
Import-Module $configModule -Force
Import-Module $backupModule -Force

if ([string]::IsNullOrWhiteSpace($SettingsPath)) {
    $settings = Get-GameServerSettings -Game $Game
}
else {
    $settings = Get-GameServerSettings -Game $Game -LegacyLocalPath $SettingsPath
}

$result = Backup-GameServerData -Game $Game -Reason $Reason -Settings $settings -WhatIf:$WhatIfPreference
Write-CKInfo "Backup completed: $($result.BackupPath)"
Write-CKInfo "Manifest: $($result.ManifestPath)"
Write-CKInfo "Copied targets: $($result.CopiedCount); missing targets: $($result.MissingCount)"
