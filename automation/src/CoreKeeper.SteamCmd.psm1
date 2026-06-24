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

function New-CKSteamCmdAppUpdateArguments {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Settings
    )

    return @(
        "+force_install_dir",
        [string]$Settings["serverInstallPath"],
        "+login",
        "anonymous",
        "+app_update",
        [string]$Settings["appId"],
        "validate",
        "+quit"
    )
}

function Invoke-CKSteamCmd {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,

        [hashtable]$Settings,

        [string]$OperationName = "steamcmd"
    )

    Assert-CKWindows -Operation "SteamCMD execution"

    if ($null -eq $Settings) {
        $Settings = Get-CKSettings
    }

    $paths = Get-CKPathSet -Settings $Settings
    if (-not (Test-Path -LiteralPath $paths.SteamCmdExe -PathType Leaf)) {
        throw "steamcmd.exe was not found: $($paths.SteamCmdExe). Run .\scripts\install-steamcmd.ps1 first."
    }

    New-CKDirectory -Path $paths.ServerInstallPath | Out-Null
    $logRoot = Join-Path $paths.SteamCmdPath "logs"
    New-CKDirectory -Path $logRoot | Out-Null

    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $outputLog = Join-Path $logRoot "$OperationName-$timestamp.log"
    $commandText = "`"$($paths.SteamCmdExe)`" $($Arguments -join ' ')"

    Write-CKInfo "Running SteamCMD: $commandText"
    Write-CKInfo "SteamCMD output log: $outputLog"

    & $paths.SteamCmdExe @Arguments 2>&1 | Tee-Object -FilePath $outputLog
    $exitCode = $LASTEXITCODE

    if ($exitCode -ne 0) {
        throw "SteamCMD failed with exit code $exitCode. Command: $commandText. Output log: $outputLog. SteamCMD logs: $logRoot"
    }

    return [pscustomobject]@{
        ExitCode = $exitCode
        Command = $commandText
        OutputLog = $outputLog
        SteamCmdLogs = $logRoot
    }
}

function Invoke-CKDedicatedServerAppUpdate {
    [CmdletBinding()]
    param(
        [hashtable]$Settings,
        [string]$OperationName = "corekeeper-app-update"
    )

    if ($null -eq $Settings) {
        $Settings = Get-CKSettings
    }

    Install-CKSteamCmd -Settings $Settings | Out-Null
    $arguments = New-CKSteamCmdAppUpdateArguments -Settings $Settings
    return Invoke-CKSteamCmd -Arguments $arguments -Settings $Settings -OperationName $OperationName
}

function Install-CKDedicatedServer {
    [CmdletBinding()]
    param(
        [hashtable]$Settings
    )

    return Invoke-CKDedicatedServerAppUpdate -Settings $Settings -OperationName "corekeeper-install-server"
}

function Update-CKDedicatedServer {
    [CmdletBinding()]
    param(
        [hashtable]$Settings
    )

    return Invoke-CKDedicatedServerAppUpdate -Settings $Settings -OperationName "corekeeper-update-server"
}

Export-ModuleMember -Function Get-CKSteamCmdDownloadUrl, Test-CKSteamCmdInstalled, Install-CKSteamCmd, New-CKSteamCmdAppUpdateArguments, Invoke-CKSteamCmd, Invoke-CKDedicatedServerAppUpdate, Install-CKDedicatedServer, Update-CKDedicatedServer
