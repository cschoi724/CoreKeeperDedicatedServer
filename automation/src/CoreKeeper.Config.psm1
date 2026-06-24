Set-StrictMode -Version 2.0

$commonModule = Join-Path $PSScriptRoot "CoreKeeper.Common.psm1"
Import-Module $commonModule -Force

function ConvertTo-CKHashtable {
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
                $hash[$key] = ConvertTo-CKHashtable $InputObject[$key]
            }
            return $hash
        }

        if ($InputObject -is [pscustomobject]) {
            $hash = @{}
            foreach ($property in $InputObject.PSObject.Properties) {
                $hash[$property.Name] = ConvertTo-CKHashtable $property.Value
            }
            return $hash
        }

        return $InputObject
    }
}

function Read-CKJsonFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Settings file does not exist: $Path"
    }

    try {
        $raw = Get-Content -LiteralPath $Path -Raw -ErrorAction Stop
        return ConvertTo-CKHashtable ($raw | ConvertFrom-Json -ErrorAction Stop)
    }
    catch {
        throw "Failed to read JSON file '$Path': $($_.Exception.Message)"
    }
}

function Merge-CKSettings {
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

    $root = Get-CKAutomationRoot
    if ([string]::IsNullOrWhiteSpace($ExamplePath)) {
        $ExamplePath = Join-Path $root "config\settings.example.json"
    }
    if ([string]::IsNullOrWhiteSpace($LocalPath)) {
        $LocalPath = Join-Path $root "config\settings.local.json"
    }

    $base = Read-CKJsonFile -Path $ExamplePath
    $local = $null

    if (Test-Path -LiteralPath $LocalPath) {
        $local = Read-CKJsonFile -Path $LocalPath
    }

    $settings = Merge-CKSettings -Base $base -Override $local
    Assert-CKSettings -Settings $settings
    return $settings
}

Export-ModuleMember -Function Get-CKSettings, Assert-CKSettings
