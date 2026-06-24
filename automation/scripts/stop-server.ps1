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

$processes = @(Get-CKServerProcesses -Settings $settings)
if ($processes.Count -eq 0) {
    Write-CKInfo "No likely Core Keeper Dedicated Server process was found."
    return
}

Write-Host "Likely Core Keeper Dedicated Server processes:"
$processes | Select-Object Id, ProcessName, Path | Format-Table -AutoSize
Write-CKWarn "Safe shutdown command is not verified yet. This script does not force-stop the server."
Write-Host "Stop the server from its console/window using the official safe shutdown flow, then run .\scripts\status-server.ps1 again."
