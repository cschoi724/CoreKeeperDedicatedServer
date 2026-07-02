Set-StrictMode -Version 2.0

$configManagerModule = Join-Path $PSScriptRoot "ConfigManager.psm1"
$pathManagerModule = Join-Path $PSScriptRoot "PathManager.psm1"
Import-Module $configManagerModule -Force
Import-Module $pathManagerModule -Force

$script:SteamCmdDownloadUrl = "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip"

function Write-GSMInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    Write-Host "[INFO] $Message"
}

function Test-GSMWindows {
    [CmdletBinding()]
    param()

    if ($PSVersionTable.PSVersion.Major -ge 6) {
        return $IsWindows
    }

    return $env:OS -eq "Windows_NT"
}

function Assert-GSMWindows {
    [CmdletBinding()]
    param(
        [string]$Operation = "This operation"
    )

    if (-not (Test-GSMWindows)) {
        throw "$Operation requires Windows. macOS is only used for template editing and documentation."
    }
}

function New-GSMDirectory {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if ([string]::IsNullOrWhiteSpace($Path)) {
        throw "Directory path cannot be empty."
    }

    if (Test-Path -LiteralPath $Path) {
        $item = Get-Item -LiteralPath $Path
        if (-not $item.PSIsContainer) {
            throw "Path exists but is not a directory: $Path"
        }
        return $item
    }

    if ($PSCmdlet.ShouldProcess($Path, "Create directory")) {
        return New-Item -ItemType Directory -Path $Path -Force
    }
}

function Get-GameServerSteamCmdDownloadUrl {
    [CmdletBinding()]
    param()

    return $script:SteamCmdDownloadUrl
}

function Test-GameServerSteamCmdInstalled {
    [CmdletBinding()]
    param(
        [string]$Game = "corekeeper",
        [hashtable]$Settings
    )

    if ($null -eq $Settings) {
        $Settings = Get-GameServerSettings -Game $Game
    }

    $paths = Get-GameServerPathSet -Game $Game -Settings $Settings
    return Test-Path -LiteralPath $paths.SteamCmdExe -PathType Leaf
}

function Install-GameServerSteamCmd {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [string]$Game = "corekeeper",
        [hashtable]$Settings,
        [string]$DownloadUrl = $script:SteamCmdDownloadUrl
    )

    Assert-GSMWindows -Operation "SteamCMD installation"

    if ($null -eq $Settings) {
        $Settings = Get-GameServerSettings -Game $Game
    }

    $paths = Initialize-GameServerRequiredDirectories -Game $Game -Settings $Settings

    if (Test-Path -LiteralPath $paths.SteamCmdExe -PathType Leaf) {
        Write-GSMInfo "SteamCMD already exists: $($paths.SteamCmdExe)"
        return $paths.SteamCmdExe
    }

    $zipPath = Join-Path $env:TEMP "steamcmd.zip"
    if (Test-Path -LiteralPath $zipPath) {
        if ($PSCmdlet.ShouldProcess($zipPath, "Remove previous SteamCMD zip")) {
            Remove-Item -LiteralPath $zipPath -Force
        }
    }

    if ($PSCmdlet.ShouldProcess($DownloadUrl, "Download SteamCMD")) {
        try {
            Write-GSMInfo "Downloading SteamCMD from $DownloadUrl"
            Invoke-WebRequest -Uri $DownloadUrl -OutFile $zipPath -UseBasicParsing -ErrorAction Stop
        }
        catch {
            throw "Failed to download SteamCMD: $($_.Exception.Message)"
        }
    }
    else {
        return $paths.SteamCmdExe
    }

    if (-not (Test-Path -LiteralPath $zipPath -PathType Leaf)) {
        throw "SteamCMD download did not create a zip file: $zipPath"
    }

    if ($PSCmdlet.ShouldProcess($paths.SteamCmdPath, "Extract SteamCMD")) {
        try {
            Write-GSMInfo "Extracting SteamCMD to $($paths.SteamCmdPath)"
            Expand-Archive -Path $zipPath -DestinationPath $paths.SteamCmdPath -Force -ErrorAction Stop
        }
        catch {
            throw "Failed to extract SteamCMD zip '$zipPath': $($_.Exception.Message)"
        }
    }

    if (-not (Test-Path -LiteralPath $paths.SteamCmdExe -PathType Leaf)) {
        throw "SteamCMD extraction completed, but steamcmd.exe was not found: $($paths.SteamCmdExe)"
    }

    Write-GSMInfo "SteamCMD installed: $($paths.SteamCmdExe)"
    return $paths.SteamCmdExe
}

function New-GameServerSteamCmdAppUpdateArguments {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Settings
    )

    $login = [string]$Settings["steamLogin"]
    if ([string]::IsNullOrWhiteSpace($login)) {
        throw "Setting 'steamLogin' cannot be empty. Steam login policy must come from the game Adapter."
    }

    return @(
        "+force_install_dir",
        [string]$Settings["serverInstallPath"],
        "+login",
        $login,
        "+app_update",
        [string]$Settings["appId"],
        "validate",
        "+quit"
    )
}

function Invoke-GameServerSteamCmd {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,

        [string]$Game = "corekeeper",
        [hashtable]$Settings,
        [string]$OperationName = "steamcmd"
    )

    Assert-GSMWindows -Operation "SteamCMD execution"

    if ($null -eq $Settings) {
        $Settings = Get-GameServerSettings -Game $Game
    }

    $paths = Get-GameServerPathSet -Game $Game -Settings $Settings
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $logRoot = Join-Path $paths.SteamCmdPath "logs"
    $outputLog = Join-Path $logRoot "$OperationName-$timestamp.log"
    $commandText = "`"$($paths.SteamCmdExe)`" $($Arguments -join ' ')"

    Write-GSMInfo "Running SteamCMD: $commandText"
    Write-GSMInfo "SteamCMD output log: $outputLog"

    if (-not $PSCmdlet.ShouldProcess($commandText, "Run SteamCMD")) {
        return [pscustomobject]@{
            ExitCode = 0
            Command = $commandText
            OutputLog = $outputLog
            SteamCmdLogs = $logRoot
            WhatIf = $true
        }
    }

    if (-not (Test-Path -LiteralPath $paths.SteamCmdExe -PathType Leaf)) {
        throw "steamcmd.exe was not found: $($paths.SteamCmdExe). Run .\scripts\install-steamcmd.ps1 first."
    }

    New-GSMDirectory -Path $paths.ServerInstallPath | Out-Null
    New-GSMDirectory -Path $logRoot | Out-Null

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
        WhatIf = $false
    }
}

function Invoke-GameServerAppUpdate {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [string]$Game = "corekeeper",
        [hashtable]$Settings,
        [string]$OperationName = "app-update"
    )

    if ($null -eq $Settings) {
        $Settings = Get-GameServerSettings -Game $Game
    }

    Install-GameServerSteamCmd -Game $Game -Settings $Settings -WhatIf:$WhatIfPreference | Out-Null
    $arguments = New-GameServerSteamCmdAppUpdateArguments -Settings $Settings
    return Invoke-GameServerSteamCmd -Arguments $arguments -Game $Game -Settings $Settings -OperationName $OperationName -WhatIf:$WhatIfPreference
}

function Install-GameServerDedicatedServer {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [string]$Game = "corekeeper",
        [hashtable]$Settings
    )

    return Invoke-GameServerAppUpdate -Game $Game -Settings $Settings -OperationName "$Game-install-server" -WhatIf:$WhatIfPreference
}

function Update-GameServerDedicatedServer {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [string]$Game = "corekeeper",
        [hashtable]$Settings
    )

    return Invoke-GameServerAppUpdate -Game $Game -Settings $Settings -OperationName "$Game-update-server" -WhatIf:$WhatIfPreference
}

Export-ModuleMember -Function Get-GameServerSteamCmdDownloadUrl, Test-GameServerSteamCmdInstalled, Install-GameServerSteamCmd, New-GameServerSteamCmdAppUpdateArguments, Invoke-GameServerSteamCmd, Invoke-GameServerAppUpdate, Install-GameServerDedicatedServer, Update-GameServerDedicatedServer
