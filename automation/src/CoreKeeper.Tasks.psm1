Set-StrictMode -Version 2.0

$commonModule = Join-Path $PSScriptRoot "CoreKeeper.Common.psm1"
$configModule = Join-Path $PSScriptRoot "CoreKeeper.Config.psm1"
Import-Module $commonModule -Force
Import-Module $configModule -Force

function Test-CKAdministrator {
    [CmdletBinding()]
    param()

    Assert-CKWindows -Operation "Administrator check"

    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-CKCurrentUserId {
    [CmdletBinding()]
    param()

    Assert-CKWindows -Operation "Current user lookup"
    return [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
}

function Get-CKScriptPath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ScriptName
    )

    $path = Join-Path (Join-Path (Get-CKAutomationRoot) "scripts") $ScriptName
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Script was not found: $path"
    }

    return $path
}

function New-CKPowerShellTaskAction {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ScriptPath
    )

    $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`""
    return New-ScheduledTaskAction -Execute "powershell.exe" -Argument $arguments
}

function Write-CKTaskPermissionHint {
    [CmdletBinding()]
    param()

    $isAdmin = Test-CKAdministrator
    if ($isAdmin) {
        Write-CKInfo "Current PowerShell session is running as Administrator."
    }
    else {
        Write-CKWarn "Current PowerShell session is not elevated. Current-user scheduled tasks may still work, but registration can fail depending on Windows policy."
    }
}

function Register-CKServerStartupTask {
    [CmdletBinding()]
    param(
        [hashtable]$Settings
    )

    Assert-CKWindows -Operation "Task Scheduler registration"

    if ($null -eq $Settings) {
        $Settings = Get-CKSettings
    }

    Write-CKTaskPermissionHint

    $taskName = [string]$Settings["taskName"]
    $userId = Get-CKCurrentUserId
    $scriptPath = Get-CKScriptPath -ScriptName "start-server.ps1"
    $action = New-CKPowerShellTaskAction -ScriptPath $scriptPath
    $trigger = New-ScheduledTaskTrigger -AtLogOn -User $userId
    $principal = New-ScheduledTaskPrincipal -UserId $userId -LogonType Interactive -RunLevel LeastPrivilege
    $settingsSet = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit ([TimeSpan]::Zero)
    $description = "Start Core Keeper Dedicated Server from $scriptPath at current user logon."

    try {
        Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settingsSet -Description $description -Force -ErrorAction Stop | Out-Null
    }
    catch {
        throw "Failed to register scheduled task '$taskName'. Try running PowerShell as Administrator if Windows policy requires it. Error: $($_.Exception.Message)"
    }

    Write-CKInfo "Registered scheduled task '$taskName' for user '$userId'."
    Write-CKInfo "Task action: powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
    return Get-ScheduledTask -TaskName $taskName -ErrorAction Stop
}

function Unregister-CKTaskByName {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$TaskName
    )

    Assert-CKWindows -Operation "Task Scheduler unregistration"
    Write-CKTaskPermissionHint

    $task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($null -eq $task) {
        Write-CKWarn "Scheduled task was not found: $TaskName"
        return $false
    }

    try {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction Stop
    }
    catch {
        throw "Failed to unregister scheduled task '$TaskName'. Try running PowerShell as Administrator if Windows policy requires it. Error: $($_.Exception.Message)"
    }

    Write-CKInfo "Unregistered scheduled task '$TaskName'."
    return $true
}

function Enable-CKTaskByName {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$TaskName
    )

    Assert-CKWindows -Operation "Task Scheduler enable"
    Write-CKTaskPermissionHint

    try {
        Enable-ScheduledTask -TaskName $TaskName -ErrorAction Stop | Out-Null
    }
    catch {
        throw "Failed to enable scheduled task '$TaskName'. Register it first, or try running PowerShell as Administrator if Windows policy requires it. Error: $($_.Exception.Message)"
    }

    Write-CKInfo "Enabled scheduled task '$TaskName'."
    return Get-ScheduledTask -TaskName $TaskName -ErrorAction Stop
}

function Disable-CKTaskByName {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$TaskName
    )

    Assert-CKWindows -Operation "Task Scheduler disable"
    Write-CKTaskPermissionHint

    try {
        Disable-ScheduledTask -TaskName $TaskName -ErrorAction Stop | Out-Null
    }
    catch {
        throw "Failed to disable scheduled task '$TaskName'. Register it first, or try running PowerShell as Administrator if Windows policy requires it. Error: $($_.Exception.Message)"
    }

    Write-CKInfo "Disabled scheduled task '$TaskName'."
    return Get-ScheduledTask -TaskName $TaskName -ErrorAction Stop
}

function Unregister-CKServerStartupTask {
    [CmdletBinding()]
    param(
        [hashtable]$Settings
    )

    if ($null -eq $Settings) {
        $Settings = Get-CKSettings
    }

    return Unregister-CKTaskByName -TaskName ([string]$Settings["taskName"])
}

function Enable-CKServerStartupTask {
    [CmdletBinding()]
    param(
        [hashtable]$Settings
    )

    if ($null -eq $Settings) {
        $Settings = Get-CKSettings
    }

    return Enable-CKTaskByName -TaskName ([string]$Settings["taskName"])
}

function Disable-CKServerStartupTask {
    [CmdletBinding()]
    param(
        [hashtable]$Settings
    )

    if ($null -eq $Settings) {
        $Settings = Get-CKSettings
    }

    return Disable-CKTaskByName -TaskName ([string]$Settings["taskName"])
}

Export-ModuleMember -Function Test-CKAdministrator, Get-CKCurrentUserId, Get-CKScriptPath, New-CKPowerShellTaskAction, Write-CKTaskPermissionHint, Register-CKServerStartupTask, Unregister-CKTaskByName, Enable-CKTaskByName, Disable-CKTaskByName, Unregister-CKServerStartupTask, Enable-CKServerStartupTask, Disable-CKServerStartupTask
