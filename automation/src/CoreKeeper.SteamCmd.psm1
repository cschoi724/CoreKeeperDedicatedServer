Set-StrictMode -Version 2.0

$commonModule = Join-Path $PSScriptRoot "CoreKeeper.Common.psm1"
$configModule = Join-Path $PSScriptRoot "CoreKeeper.Config.psm1"
$pathsModule = Join-Path $PSScriptRoot "CoreKeeper.Paths.psm1"
Import-Module $commonModule -Force
Import-Module $configModule -Force
Import-Module $pathsModule -Force

$script:SteamCmdDownloadUrl = "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip"

function Get-CKSteamCmdDownloadUrl {
    [CmdletBinding()]
    param()

    return $script:SteamCmdDownloadUrl
}

function Test-CKSteamCmdInstalled {
    [CmdletBinding()]
    param(
        [hashtable]$Settings
    )

    if ($null -eq $Settings) {
        $Settings = Get-CKSettings
    }

    $paths = Get-CKPathSet -Settings $Settings
    return Test-Path -LiteralPath $paths.SteamCmdExe -PathType Leaf
}

function Install-CKSteamCmd {
    [CmdletBinding()]
    param(
        [hashtable]$Settings,
        [string]$DownloadUrl = $script:SteamCmdDownloadUrl
    )

    Assert-CKWindows -Operation "SteamCMD installation"

    if ($null -eq $Settings) {
        $Settings = Get-CKSettings
    }

    $paths = Initialize-CKRequiredDirectories -Settings $Settings

    if (Test-Path -LiteralPath $paths.SteamCmdExe -PathType Leaf) {
        Write-CKInfo "SteamCMD already exists: $($paths.SteamCmdExe)"
        return $paths.SteamCmdExe
    }

    $zipPath = Join-Path $env:TEMP "steamcmd.zip"
    if (Test-Path -LiteralPath $zipPath) {
        Remove-Item -LiteralPath $zipPath -Force
    }

    try {
        Write-CKInfo "Downloading SteamCMD from $DownloadUrl"
        Invoke-WebRequest -Uri $DownloadUrl -OutFile $zipPath -UseBasicParsing -ErrorAction Stop
    }
    catch {
        throw "Failed to download SteamCMD: $($_.Exception.Message)"
    }

    if (-not (Test-Path -LiteralPath $zipPath -PathType Leaf)) {
        throw "SteamCMD download did not create a zip file: $zipPath"
    }

    try {
        Write-CKInfo "Extracting SteamCMD to $($paths.SteamCmdPath)"
        Expand-Archive -Path $zipPath -DestinationPath $paths.SteamCmdPath -Force -ErrorAction Stop
    }
    catch {
        throw "Failed to extract SteamCMD zip '$zipPath': $($_.Exception.Message)"
    }

    if (-not (Test-Path -LiteralPath $paths.SteamCmdExe -PathType Leaf)) {
        throw "SteamCMD extraction completed, but steamcmd.exe was not found: $($paths.SteamCmdExe)"
    }

    Write-CKInfo "SteamCMD installed: $($paths.SteamCmdExe)"
    return $paths.SteamCmdExe
}

Export-ModuleMember -Function Get-CKSteamCmdDownloadUrl, Test-CKSteamCmdInstalled, Install-CKSteamCmd
