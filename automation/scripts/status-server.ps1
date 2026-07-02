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
$pathsModule = Join-Path $automationRoot "src\Core\PathManager.psm1"
$serverModule = Join-Path $automationRoot "src\Core\ServerManager.psm1"

Import-Module $commonModule -Force
Import-Module $configModule -Force
Import-Module $pathsModule -Force
Import-Module $serverModule -Force

if ([string]::IsNullOrWhiteSpace($SettingsPath)) {
    $settings = Get-GameServerSettings -Game $Game
}
else {
    $settings = Get-GameServerSettings -Game $Game -LegacyLocalPath $SettingsPath
}

$paths = Get-GameServerPathSet -Game $Game -Settings $settings
$status = Get-GameServerStatus -Game $Game -Settings $settings
$runningProcesses = @($status.RunningProcesses)
$statusHints = @($status.StatusHints)

Write-Host "Server install path: $($paths.ServerInstallPath)"
Write-Host "Dedicated Server data root: $($paths.DedicatedServerDataRoot)"
Write-Host "Server install path exists: $($status.ServerInstallPathExists)"
Write-Host "Dedicated Server data root exists: $($status.DedicatedServerDataRootExists)"
Write-Host "Launch target: $($status.LaunchTarget)"
Write-Host "Running process count: $($status.RunningProcessCount)"

if ($status.RunningProcessCount -gt 0) {
    $runningProcesses | Format-Table -AutoSize
}

if ($statusHints.Count -gt 0) {
    Write-Host "Status hints from recent logs:"
    $statusHints | Format-Table -AutoSize
}
else {
    Write-Host "Status hints: none found. Check the server console after startup."
}
