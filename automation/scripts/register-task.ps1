[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$Game = "corekeeper",
    [string]$SettingsPath
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"

$automationRoot = Split-Path -Parent $PSScriptRoot
$commonModule = Join-Path $automationRoot "src\CoreKeeper.Common.psm1"
$configModule = Join-Path $automationRoot "src\Core\ConfigManager.psm1"
$tasksModule = Join-Path $automationRoot "src\Core\SchedulerManager.psm1"

Import-Module $commonModule -Force
Import-Module $configModule -Force
Import-Module $tasksModule -Force

if ([string]::IsNullOrWhiteSpace($SettingsPath)) {
    $settings = Get-GameServerSettings -Game $Game
}
else {
    $settings = Get-GameServerSettings -Game $Game -LegacyLocalPath $SettingsPath
}

Register-GameServerStartupTask -Game $Game -Settings $settings -WhatIf:$WhatIfPreference | Out-Null
Write-CKInfo "Automatic startup is now registered. Use .\scripts\disable-task.ps1 to turn it off without removing it."
