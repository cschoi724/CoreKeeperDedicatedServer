Set-StrictMode -Version 2.0

function Get-GSMAutomationRoot {
    [CmdletBinding()]
    param()

    return (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
}

function ConvertTo-GSMHashtable {
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
                $hash[$key] = ConvertTo-GSMHashtable $InputObject[$key]
            }
            return $hash
        }

        if ($InputObject -is [pscustomobject]) {
            $hash = @{}
            foreach ($property in $InputObject.PSObject.Properties) {
                $hash[$property.Name] = ConvertTo-GSMHashtable $property.Value
            }
            return $hash
        }

        if ($InputObject -is [System.Array]) {
            $items = @()
            foreach ($item in $InputObject) {
                $items += ConvertTo-GSMHashtable $item
            }
            return $items
        }

        return $InputObject
    }
}

function Read-GSMJsonFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "JSON file does not exist: $Path"
    }

    try {
        $raw = Get-Content -LiteralPath $Path -Raw -ErrorAction Stop
        return ConvertTo-GSMHashtable ($raw | ConvertFrom-Json -ErrorAction Stop)
    }
    catch {
        throw "Failed to read JSON file '$Path': $($_.Exception.Message)"
    }
}

function Assert-GSMAdapterManifest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Manifest,

        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $requiredTopLevel = @("gameId", "displayName", "steam", "paths", "server", "backup", "features")
    foreach ($key in $requiredTopLevel) {
        if (-not $Manifest.ContainsKey($key)) {
            throw "Adapter manifest '$Path' is missing required field: $key"
        }
    }

    foreach ($key in @("gameId", "displayName")) {
        if ([string]::IsNullOrWhiteSpace([string]$Manifest[$key])) {
            throw "Adapter manifest '$Path' field '$key' cannot be empty."
        }
    }

    foreach ($key in @("appId", "login")) {
        if (-not $Manifest["steam"].ContainsKey($key) -or [string]::IsNullOrWhiteSpace([string]$Manifest["steam"][$key])) {
            throw "Adapter manifest '$Path' is missing required field: steam.$key"
        }
    }

    foreach ($key in @("defaultInstallPath", "defaultBackupRoot")) {
        if (-not $Manifest["paths"].ContainsKey($key) -or [string]::IsNullOrWhiteSpace([string]$Manifest["paths"][$key])) {
            throw "Adapter manifest '$Path' is missing required field: paths.$key"
        }
    }

    foreach ($key in @("launchCandidates", "processNamePatterns")) {
        if (-not $Manifest["server"].ContainsKey($key) -or $Manifest["server"][$key].Count -eq 0) {
            throw "Adapter manifest '$Path' is missing required non-empty field: server.$key"
        }
    }

    if (-not $Manifest["backup"].ContainsKey("targets") -or $Manifest["backup"]["targets"].Count -eq 0) {
        throw "Adapter manifest '$Path' is missing required non-empty field: backup.targets"
    }
}

function Resolve-GSMAdapterManifestPath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Game,

        [string]$AutomationRoot
    )

    if ([string]::IsNullOrWhiteSpace($AutomationRoot)) {
        $AutomationRoot = Get-GSMAutomationRoot
    }

    $srcRoot = Join-Path $AutomationRoot "src"
    $gamesRoot = Join-Path $srcRoot "Games"
    if (-not (Test-Path -LiteralPath $gamesRoot -PathType Container)) {
        throw "Games directory does not exist: $gamesRoot"
    }

    $manifestPaths = Get-ChildItem -LiteralPath $gamesRoot -Filter "game.json" -Recurse -File -ErrorAction Stop
    foreach ($manifestPath in $manifestPaths) {
        $manifest = Read-GSMJsonFile -Path $manifestPath.FullName
        if ([string]::Equals([string]$manifest["gameId"], $Game, [System.StringComparison]::OrdinalIgnoreCase)) {
            return $manifestPath.FullName
        }
    }

    $availableGames = @()
    foreach ($manifestPath in $manifestPaths) {
        try {
            $manifest = Read-GSMJsonFile -Path $manifestPath.FullName
            if (-not [string]::IsNullOrWhiteSpace([string]$manifest["gameId"])) {
                $availableGames += [string]$manifest["gameId"]
            }
        }
        catch {
        }
    }

    $availableText = if ($availableGames.Count -gt 0) { $availableGames -join ", " } else { "none" }
    throw "Adapter manifest for game '$Game' was not found. Available games: $availableText"
}

function Get-GameServerAdapter {
    [CmdletBinding()]
    param(
        [string]$Game = "corekeeper",

        [string]$AutomationRoot
    )

    if ([string]::IsNullOrWhiteSpace($Game)) {
        $Game = "corekeeper"
    }

    $manifestPath = Resolve-GSMAdapterManifestPath -Game $Game -AutomationRoot $AutomationRoot
    $manifest = Read-GSMJsonFile -Path $manifestPath
    Assert-GSMAdapterManifest -Manifest $manifest -Path $manifestPath

    return [pscustomobject]@{
        GameId = [string]$manifest["gameId"]
        DisplayName = [string]$manifest["displayName"]
        ManifestPath = $manifestPath
        Manifest = $manifest
    }
}

function Get-GameServerAdapterList {
    [CmdletBinding()]
    param(
        [string]$AutomationRoot
    )

    if ([string]::IsNullOrWhiteSpace($AutomationRoot)) {
        $AutomationRoot = Get-GSMAutomationRoot
    }

    $srcRoot = Join-Path $AutomationRoot "src"
    $gamesRoot = Join-Path $srcRoot "Games"
    if (-not (Test-Path -LiteralPath $gamesRoot -PathType Container)) {
        return @()
    }

    $adapters = @()
    $manifestPaths = Get-ChildItem -LiteralPath $gamesRoot -Filter "game.json" -Recurse -File -ErrorAction Stop
    foreach ($manifestPath in $manifestPaths) {
        $manifest = Read-GSMJsonFile -Path $manifestPath.FullName
        Assert-GSMAdapterManifest -Manifest $manifest -Path $manifestPath.FullName
        $adapters += [pscustomobject]@{
            GameId = [string]$manifest["gameId"]
            DisplayName = [string]$manifest["displayName"]
            ManifestPath = $manifestPath.FullName
        }
    }

    return $adapters
}

Export-ModuleMember -Function Get-GameServerAdapter, Get-GameServerAdapterList
