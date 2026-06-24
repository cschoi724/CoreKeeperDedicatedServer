[CmdletBinding()]
param(
    [ValidateSet("manual", "before-import", "before-update")]
    [string]$Reason = "manual",

    [string]$SettingsPath
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"

$automationRoot = Split-Path -Parent $PSScriptRoot
$commonModule = Join-Path $automationRoot "src\CoreKeeper.Common.psm1"
$configModule = Join-Path $automationRoot "src\CoreKeeper.Config.psm1"
$pathsModule = Join-Path $automationRoot "src\CoreKeeper.Paths.psm1"
$backupModule = Join-Path $automationRoot "src\CoreKeeper.Backup.psm1"

Import-Module $commonModule -Force
Import-Module $configModule -Force
Import-Module $pathsModule -Force
Import-Module $backupModule -Force

if ([string]::IsNullOrWhiteSpace($SettingsPath)) {
    $settings = Get-CKSettings
}
else {
    $settings = Get-CKSettings -LocalPath $SettingsPath
}

$result = Backup-CKDedicatedServerData -Reason $Reason -Settings $settings
Write-CKInfo "Backup completed: $($result.BackupPath)"
Write-CKInfo "Manifest: $($result.ManifestPath)"
Write-CKInfo "Copied targets: $($result.CopiedCount); missing targets: $($result.MissingCount)"
