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

Start-GameServerDedicatedServer -Game $Game -Settings $settings | Out-Null
Write-CKInfo "Run .\scripts\status-server.ps1 to inspect process, data folder, and Game ID hints."
