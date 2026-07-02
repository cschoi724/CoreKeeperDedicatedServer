[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [string]$WorldFile,

    [ValidateRange(0, 999)]
    [int]$WorldIndex = 0,

    [switch]$ConfirmOverwrite,

    [string]$Game = "corekeeper",

    [string]$SettingsPath
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"

$automationRoot = Split-Path -Parent $PSScriptRoot
$commonModule = Join-Path $automationRoot "src\CoreKeeper.Common.psm1"
$configModule = Join-Path $automationRoot "src\CoreKeeper.Config.psm1"
$pathsModule = Join-Path $automationRoot "src\CoreKeeper.Paths.psm1"
$backupModule = Join-Path $automationRoot "src\CoreKeeper.Backup.psm1"
$serverModule = Join-Path $automationRoot "src\CoreKeeper.Server.psm1"
$worldModule = Join-Path $automationRoot "src\CoreKeeper.World.psm1"

Import-Module $commonModule -Force
Import-Module $configModule -Force
Import-Module $pathsModule -Force
Import-Module $backupModule -Force
Import-Module $serverModule -Force
Import-Module $worldModule -Force

if ([string]::IsNullOrWhiteSpace($SettingsPath)) {
    $settings = Get-CKSettings
}
else {
    $settings = Get-CKSettings -LocalPath $SettingsPath
}

$result = Import-CKWorldFile -Game $Game -WorldFile $WorldFile -WorldIndex $WorldIndex -ConfirmOverwrite:$ConfirmOverwrite -Settings $settings -WhatIf:$WhatIfPreference
Write-CKInfo "World import completed: $($result.Destination)"
Write-CKInfo "Backup created before import: $($result.BackupPath)"
