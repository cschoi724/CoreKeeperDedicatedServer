[CmdletBinding()]
param(
    [string]$SettingsPath
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"

$automationRoot = Split-Path -Parent $PSScriptRoot
$commonModule = Join-Path $automationRoot "src\CoreKeeper.Common.psm1"
$configModule = Join-Path $automationRoot "src\CoreKeeper.Config.psm1"
$pathsModule = Join-Path $automationRoot "src\CoreKeeper.Paths.psm1"
$steamCmdModule = Join-Path $automationRoot "src\CoreKeeper.SteamCmd.psm1"

Import-Module $commonModule -Force
Import-Module $configModule -Force
Import-Module $pathsModule -Force
Import-Module $steamCmdModule -Force

if ([string]::IsNullOrWhiteSpace($SettingsPath)) {
    $settings = Get-CKSettings
}
else {
    $settings = Get-CKSettings -LocalPath $SettingsPath
}

$steamCmdExe = Install-CKSteamCmd -Settings $settings
Write-CKInfo "Ready: $steamCmdExe"
