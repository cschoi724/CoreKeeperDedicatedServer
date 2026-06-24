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

$paths = Get-CKPathSet -Settings $settings
$status = Get-CKServerStatus -Settings $settings
$runningProcesses = @($status.RunningProcesses)
$gameIdHints = @($status.GameIdHints)

Write-Host "Server install path: $($paths.ServerInstallPath)"
Write-Host "Dedicated Server data root: $($paths.DedicatedServerDataRoot)"
Write-Host "Server install path exists: $($status.ServerInstallPathExists)"
Write-Host "Dedicated Server data root exists: $($status.DedicatedServerDataRootExists)"
Write-Host "Worlds path exists: $($status.WorldsPathExists)"
Write-Host "ServerConfig.json exists: $($status.ServerConfigExists)"
Write-Host "Launch target: $($status.LaunchTarget)"
Write-Host "Running process count: $($status.RunningProcessCount)"

if ($status.RunningProcessCount -gt 0) {
    $runningProcesses | Format-Table -AutoSize
}

if ($gameIdHints.Count -gt 0) {
    Write-Host "Game ID hints from recent logs:"
    $gameIdHints | Format-Table -AutoSize
}
else {
    Write-Host "Game ID hints: none found. Check the server console after startup."
}
