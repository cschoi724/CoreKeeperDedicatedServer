[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$Game = "corekeeper",
    [Parameter(Mandatory = $true)]
    [string]$Time,

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

Register-GameServerRestartTask -Game $Game -Time $Time -Settings $settings -WhatIf:$WhatIfPreference | Out-Null
Write-CKInfo "Restart reminder task is registered. It does not force-stop or automatically restart the server yet."
