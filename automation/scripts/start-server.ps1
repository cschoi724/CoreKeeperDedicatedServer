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
$serverModule = Join-Path $automationRoot "src\CoreKeeper.Server.psm1"

Import-Module $commonModule -Force
Import-Module $configModule -Force
Import-Module $pathsModule -Force
Import-Module $serverModule -Force

if ([string]::IsNullOrWhiteSpace($SettingsPath)) {
    $settings = Get-CKSettings
}
else {
    $settings = Get-CKSettings -LocalPath $SettingsPath
}

Start-CKDedicatedServer -Settings $settings | Out-Null
Write-CKInfo "Run .\scripts\status-server.ps1 to inspect process, data folder, and Game ID hints."
