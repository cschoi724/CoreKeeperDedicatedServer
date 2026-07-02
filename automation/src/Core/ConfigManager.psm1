Set-StrictMode -Version 2.0

$adapterManagerModule = Join-Path $PSScriptRoot "AdapterManager.psm1"
Import-Module $adapterManagerModule -Force

function Get-GSMConfigAutomationRoot {
    [CmdletBinding()]
    param()

    return (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
}

function ConvertTo-GSMConfigHashtable {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        $InputObject
    )

    process {
        if ($null -eq $InputObject) {
            return $null
        }

        if ($InputObject -is [System.Collections.IDictionary]) {
            $hash = @{}
            foreach ($key in $InputObject.Keys) {
                $hash[$key] = ConvertTo-GSMConfigHashtable $InputObject[$key]
            }
            return $hash
        }

        if ($InputObject -is [pscustomobject]) {
            $hash = @{}
            foreach ($property in $InputObject.PSObject.Properties) {
                $hash[$property.Name] = ConvertTo-GSMConfigHashtable $property.Value
            }
            return $hash
        }

        if ($InputObject -is [System.Array]) {
            $items = @()
            foreach ($item in $InputObject) {
                $items += ConvertTo-GSMConfigHashtable $item
            }
            return $items
        }

        return $InputObject
    }
}

function Read-GSMConfigJsonFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Settings file does not exist: $Path"
    }

    try {
        $raw = Get-Content -LiteralPath $Path -Raw -ErrorAction Stop
        return ConvertTo-GSMConfigHashtable ($raw | ConvertFrom-Json -ErrorAction Stop)
    }
    catch {
        throw "Failed to read JSON file '$Path': $($_.Exception.Message)"
    }
}

function Merge-GSMConfig {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Base,

        [hashtable]$Override
    )

    $merged = @{}
    foreach ($key in $Base.Keys) {
        $merged[$key] = $Base[$key]
    }

    if ($null -ne $Override) {
        foreach ($key in $Override.Keys) {
            $merged[$key] = $Override[$key]
        }
    }

    return $merged
}

function Read-GSMOptionalJsonFile {
    [CmdletBinding()]
    param(
        [string]$Path
    )

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $null
    }

    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        return Read-GSMConfigJsonFile -Path $Path
    }

    return $null
}

function Get-GameServerManagerSettings {
    [CmdletBinding()]
    param(
        [string]$AutomationRoot,
        [string]$ExamplePath,
        [string]$LocalPath
    )

    if ([string]::IsNullOrWhiteSpace($AutomationRoot)) {
        $AutomationRoot = Get-GSMConfigAutomationRoot
    }

    if ([string]::IsNullOrWhiteSpace($ExamplePath)) {
        $ExamplePath = Join-Path (Join-Path $AutomationRoot "config") "manager.example.json"
    }
    if ([string]::IsNullOrWhiteSpace($LocalPath)) {
        $LocalPath = Join-Path (Join-Path $AutomationRoot "config") "manager.local.json"
    }

    $settings = Read-GSMConfigJsonFile -Path $ExamplePath
    $local = Read-GSMOptionalJsonFile -Path $LocalPath
    return Merge-GSMConfig -Base $settings -Override $local
}

function Get-GameServerGameSettings {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Game,

        [string]$AutomationRoot,
        [string]$ExamplePath,
        [string]$LocalPath
    )

    if ([string]::IsNullOrWhiteSpace($AutomationRoot)) {
        $AutomationRoot = Get-GSMConfigAutomationRoot
    }

    if ([string]::IsNullOrWhiteSpace($ExamplePath)) {
        $ExamplePath = Join-Path (Join-Path (Join-Path $AutomationRoot "config") "games") "$Game.example.json"
    }
    if ([string]::IsNullOrWhiteSpace($LocalPath)) {
        $LocalPath = Join-Path (Join-Path (Join-Path $AutomationRoot "config") "games") "$Game.local.json"
    }

    $settings = Read-GSMConfigJsonFile -Path $ExamplePath
    $local = Read-GSMOptionalJsonFile -Path $LocalPath
    return Merge-GSMConfig -Base $settings -Override $local
}

function ConvertTo-GameServerLegacySettings {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Settings
    )

    return @{
        serverInstallPath = [string]$Settings["serverInstallPath"]
        steamCmdPath = [string]$Settings["steamCmdPath"]
        backupRoot = [string]$Settings["backupRoot"]
        appId = [string]$Settings["appId"]
        steamLogin = [string]$Settings["steamLogin"]
        taskName = [string]$Settings["taskName"]
        restartTaskName = [string]$Settings["restartTaskName"]
        worldIndex = $Settings["worldIndex"]
        restartTime = $Settings["restartTime"]
        gameId = [string]$Settings["gameId"]
        displayName = [string]$Settings["displayName"]
        dataRoot = [string]$Settings["dataRoot"]
    }
}

function Assert-GameServerSettings {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Settings
    )

    $requiredKeys = @(
        "gameId",
        "serverInstallPath",
        "steamCmdPath",
        "backupRoot",
        "appId",
        "steamLogin",
        "taskName",
        "restartTaskName",
        "worldIndex",
        "dataRoot"
    )

    foreach ($key in $requiredKeys) {
        if (-not $Settings.ContainsKey($key)) {
            throw "Missing required setting: $key"
        }
    }

    foreach ($key in @("gameId", "serverInstallPath", "steamCmdPath", "backupRoot", "appId", "steamLogin", "dataRoot")) {
        if ([string]::IsNullOrWhiteSpace([string]$Settings[$key])) {
            throw "Setting '$key' cannot be empty."
        }
    }
}

function Get-GameServerSettings {
    [CmdletBinding()]
    param(
        [string]$Game = "corekeeper",
        [string]$AutomationRoot,
        [string]$LegacyLocalPath,
        [string]$LegacyExamplePath
    )

    if ([string]::IsNullOrWhiteSpace($AutomationRoot)) {
        $AutomationRoot = Get-GSMConfigAutomationRoot
    }

    if ([string]::IsNullOrWhiteSpace($Game)) {
        $managerDefaults = Get-GameServerManagerSettings -AutomationRoot $AutomationRoot
        $Game = [string]$managerDefaults["defaultGame"]
    }
    if ([string]::IsNullOrWhiteSpace($Game)) {
        $Game = "corekeeper"
    }

    $adapter = Get-GameServerAdapter -Game $Game -AutomationRoot $AutomationRoot
    $manifest = $adapter.Manifest
    $manager = Get-GameServerManagerSettings -AutomationRoot $AutomationRoot
    $gameSettings = Get-GameServerGameSettings -Game $Game -AutomationRoot $AutomationRoot

    $settings = @{
        gameId = [string]$manifest["gameId"]
        displayName = [string]$manifest["displayName"]
        appId = [string]$manifest["steam"]["appId"]
        steamLogin = [string]$manifest["steam"]["login"]
        steamCmdPath = [string]$manager["steamCmdPath"]
        serverRoot = [string]$manager["serverRoot"]
        backupRoot = [string]$manifest["paths"]["defaultBackupRoot"]
        serverInstallPath = [string]$manifest["paths"]["defaultInstallPath"]
        dataRoot = [string]$manifest["paths"]["dataRoot"]
        worldIndex = 0
        taskName = ("GameServer-{0}" -f [string]$manifest["gameId"])
        restartTaskName = ("GameServer-{0}-Restart" -f [string]$manifest["gameId"])
        restartTime = $null
        adapter = $adapter
        manifest = $manifest
        manager = $manager
        game = $gameSettings
    }

    if (-not [string]::IsNullOrWhiteSpace([string]$manager["backupRoot"])) {
        $settings["managerBackupRoot"] = [string]$manager["backupRoot"]
    }

    if ($gameSettings.ContainsKey("serverInstallPath")) {
        $settings["serverInstallPath"] = [string]$gameSettings["serverInstallPath"]
    }
    if ($gameSettings.ContainsKey("backupRoot")) {
        $settings["backupRoot"] = [string]$gameSettings["backupRoot"]
    }
    foreach ($key in @("worldIndex", "taskName", "restartTaskName", "restartTime")) {
        if ($gameSettings.ContainsKey($key)) {
            $settings[$key] = $gameSettings[$key]
        }
    }

    if ([string]::IsNullOrWhiteSpace($LegacyLocalPath)) {
        $LegacyLocalPath = Join-Path (Join-Path $AutomationRoot "config") "settings.local.json"
    }
    if ([string]::IsNullOrWhiteSpace($LegacyExamplePath)) {
        $LegacyExamplePath = Join-Path (Join-Path $AutomationRoot "config") "settings.example.json"
    }

    $hasNewLocal = (Test-Path -LiteralPath (Join-Path (Join-Path $AutomationRoot "config") "manager.local.json") -PathType Leaf) -or
        (Test-Path -LiteralPath (Join-Path (Join-Path (Join-Path $AutomationRoot "config") "games") "$Game.local.json") -PathType Leaf)

    if (-not $hasNewLocal) {
        $legacyLocal = Read-GSMOptionalJsonFile -Path $LegacyLocalPath
        if ($null -ne $legacyLocal) {
            foreach ($key in @("serverInstallPath", "steamCmdPath", "backupRoot", "appId", "taskName", "restartTaskName", "worldIndex", "restartTime")) {
                if ($legacyLocal.ContainsKey($key)) {
                    $settings[$key] = $legacyLocal[$key]
                }
            }
            $settings["legacySettingsPath"] = $LegacyLocalPath
        }
    }
    elseif (-not [string]::IsNullOrWhiteSpace($LegacyLocalPath) -and (Test-Path -LiteralPath $LegacyLocalPath -PathType Leaf)) {
        $settings["legacySettingsPath"] = $LegacyLocalPath
    }

    if (-not (Test-Path -LiteralPath $LegacyExamplePath -PathType Leaf)) {
        $settings["legacyExampleMissing"] = $true
    }

    Assert-GameServerSettings -Settings $settings
    return $settings
}

Export-ModuleMember -Function Get-GameServerSettings, Get-GameServerManagerSettings, Get-GameServerGameSettings, ConvertTo-GameServerLegacySettings, Assert-GameServerSettings
