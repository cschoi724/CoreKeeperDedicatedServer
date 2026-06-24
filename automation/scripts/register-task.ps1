[CmdletBinding()]
param(
    [string]$SettingsPath
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"

$automationRoot = Split-Path -Parent $PSScriptRoot
$commonModule = Join-Path $automationRoot "src\CoreKeeper.Common.psm1"
$configModule = Join-Path $automationRoot "src\CoreKeeper.Config.psm1"
$tasksModule = Join-Path $automationRoot "src\CoreKeeper.Tasks.psm1"

Import-Module $commonModule -Force
Import-Module $configModule -Force
Import-Module $tasksModule -Force

if ([string]::IsNullOrWhiteSpace($SettingsPath)) {
    $settings = Get-CKSettings
}
else {
    $settings = Get-CKSettings -LocalPath $SettingsPath
}

Register-CKServerStartupTask -Settings $settings | Out-Null
Write-CKInfo "Automatic startup is now registered. Use .\scripts\disable-task.ps1 to turn it off without removing it."
