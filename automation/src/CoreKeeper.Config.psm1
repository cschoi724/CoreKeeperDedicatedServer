Set-StrictMode -Version 2.0

$configManagerModule = Join-Path (Join-Path $PSScriptRoot "Core") "ConfigManager.psm1"
Import-Module $configManagerModule -Force

function Assert-CKSettings {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Settings
    )

    $requiredKeys = @(
        "serverInstallPath",
        "steamCmdPath",
        "backupRoot",
        "appId",
        "taskName",
        "restartTaskName",
        "worldIndex"
    )

    foreach ($key in $requiredKeys) {
        if (-not $Settings.ContainsKey($key)) {
            throw "Missing required setting: $key"
        }
    }

    foreach ($key in @("serverInstallPath", "steamCmdPath", "backupRoot", "appId")) {
        if ([string]::IsNullOrWhiteSpace([string]$Settings[$key])) {
            throw "Setting '$key' cannot be empty."
        }
    }
}

function Get-CKSettings {
    [CmdletBinding()]
    param(
        [string]$ExamplePath,
        [string]$LocalPath
    )

    $settings = Get-GameServerSettings -Game "corekeeper" -LegacyExamplePath $ExamplePath -LegacyLocalPath $LocalPath
    return ConvertTo-GameServerLegacySettings -Settings $settings
}

Export-ModuleMember -Function Get-CKSettings, Assert-CKSettings
