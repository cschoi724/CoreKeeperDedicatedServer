Set-StrictMode -Version 2.0

$commonModule = Join-Path $PSScriptRoot "CoreKeeper.Common.psm1"
$configModule = Join-Path $PSScriptRoot "CoreKeeper.Config.psm1"
$pathsModule = Join-Path $PSScriptRoot "CoreKeeper.Paths.psm1"
$steamCmdManagerModule = Join-Path (Join-Path $PSScriptRoot "Core") "SteamCmdManager.psm1"
Import-Module $commonModule -Force
Import-Module $configModule -Force
Import-Module $pathsModule -Force
Import-Module $steamCmdManagerModule -Force

function Get-CKSteamCmdDownloadUrl {
    [CmdletBinding()]
    param()

    return Get-GameServerSteamCmdDownloadUrl
}

function Test-CKSteamCmdInstalled {
    [CmdletBinding()]
    param(
        [hashtable]$Settings
    )

    if ($null -eq $Settings) {
        $Settings = Get-CKSettings
    }

    return Test-GameServerSteamCmdInstalled -Game "corekeeper" -Settings $Settings
}

function Install-CKSteamCmd {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [hashtable]$Settings,
        [string]$DownloadUrl = (Get-GameServerSteamCmdDownloadUrl)
    )

    if ($null -eq $Settings) {
        $Settings = Get-CKSettings
    }

    return Install-GameServerSteamCmd -Game "corekeeper" -Settings $Settings -DownloadUrl $DownloadUrl -WhatIf:$WhatIfPreference
}

function New-CKSteamCmdAppUpdateArguments {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Settings
    )

    return New-GameServerSteamCmdAppUpdateArguments -Settings $Settings
}

function Invoke-CKSteamCmd {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,

        [hashtable]$Settings,

        [string]$OperationName = "steamcmd"
    )

    if ($null -eq $Settings) {
        $Settings = Get-CKSettings
    }

    return Invoke-GameServerSteamCmd -Arguments $Arguments -Game "corekeeper" -Settings $Settings -OperationName $OperationName -WhatIf:$WhatIfPreference
}

function Invoke-CKDedicatedServerAppUpdate {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [hashtable]$Settings,
        [string]$OperationName = "corekeeper-app-update"
    )

    if ($null -eq $Settings) {
        $Settings = Get-CKSettings
    }

    return Invoke-GameServerAppUpdate -Game "corekeeper" -Settings $Settings -OperationName $OperationName -WhatIf:$WhatIfPreference
}

function Install-CKDedicatedServer {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [hashtable]$Settings
    )

    return Invoke-CKDedicatedServerAppUpdate -Settings $Settings -OperationName "corekeeper-install-server" -WhatIf:$WhatIfPreference
}

function Update-CKDedicatedServer {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [hashtable]$Settings
    )

    return Invoke-CKDedicatedServerAppUpdate -Settings $Settings -OperationName "corekeeper-update-server" -WhatIf:$WhatIfPreference
}

Export-ModuleMember -Function Get-CKSteamCmdDownloadUrl, Test-CKSteamCmdInstalled, Install-CKSteamCmd, New-CKSteamCmdAppUpdateArguments, Invoke-CKSteamCmd, Invoke-CKDedicatedServerAppUpdate, Install-CKDedicatedServer, Update-CKDedicatedServer
