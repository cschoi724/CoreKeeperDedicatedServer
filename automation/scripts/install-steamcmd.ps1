[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$Game = "corekeeper",
    [string]$SettingsPath
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"

$automationRoot = Split-Path -Parent $PSScriptRoot
$commonModule = Join-Path $automationRoot "src\CoreKeeper.Common.psm1"
$configManagerModule = Join-Path $automationRoot "src\Core\ConfigManager.psm1"
$steamCmdManagerModule = Join-Path $automationRoot "src\Core\SteamCmdManager.psm1"

Import-Module $commonModule -Force
Import-Module $configManagerModule -Force
Import-Module $steamCmdManagerModule -Force

if ([string]::IsNullOrWhiteSpace($SettingsPath)) {
    $settings = Get-GameServerSettings -Game $Game
}
else {
    $settings = Get-GameServerSettings -Game $Game -LegacyLocalPath $SettingsPath
}

$steamCmdExe = Install-GameServerSteamCmd -Game $Game -Settings $settings -WhatIf:$WhatIfPreference
Write-CKInfo "Ready: $steamCmdExe"
