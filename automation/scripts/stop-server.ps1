[CmdletBinding()]
param(
    [string]$Game = "corekeeper",
    [string]$SettingsPath
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"

$automationRoot = Split-Path -Parent $PSScriptRoot
$commonModule = Join-Path $automationRoot "src\CoreKeeper.Common.psm1"
$configModule = Join-Path $automationRoot "src\Core\ConfigManager.psm1"
$serverModule = Join-Path $automationRoot "src\Core\ServerManager.psm1"

Import-Module $commonModule -Force
Import-Module $configModule -Force
Import-Module $serverModule -Force

if ([string]::IsNullOrWhiteSpace($SettingsPath)) {
    $settings = Get-GameServerSettings -Game $Game
}
else {
    $settings = Get-GameServerSettings -Game $Game -LegacyLocalPath $SettingsPath
}

$processes = @(Get-GameServerProcesses -Game $Game -Settings $settings)
if ($processes.Count -eq 0) {
    Write-CKInfo "No likely $($settings['displayName']) Dedicated Server process was found."
    return
}

Write-Host "Likely $($settings['displayName']) Dedicated Server processes:"
$processes | Select-Object Id, ProcessName, Path | Format-Table -AutoSize
Write-CKWarn "Safe shutdown command is not verified yet. This script does not force-stop the server."
Write-Host "Stop the server from its console/window using the official safe shutdown flow, then run .\scripts\status-server.ps1 again."
