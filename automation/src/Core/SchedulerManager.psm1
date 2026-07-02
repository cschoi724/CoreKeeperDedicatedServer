Set-StrictMode -Version 2.0

$configManagerModule = Join-Path $PSScriptRoot "ConfigManager.psm1"
Import-Module $configManagerModule -Force

function Write-GSMSchedulerInfo { param([Parameter(Mandatory = $true)][string]$Message) Write-Host "[INFO] $Message" }
function Write-GSMSchedulerWarn { param([Parameter(Mandatory = $true)][string]$Message) Write-Warning $Message }

function Assert-GSMSchedulerWindows {
    param([string]$Operation = "This operation")
    if ($PSVersionTable.PSVersion.Major -ge 6) {
        if (-not $IsWindows) { throw "$Operation requires Windows. macOS is only used for template editing and documentation." }
    }
    elseif ($env:OS -ne "Windows_NT") {
        throw "$Operation requires Windows. macOS is only used for template editing and documentation."
    }
}

function Test-GameServerAdministrator {
    Assert-GSMSchedulerWindows -Operation "Administrator check"
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-GameServerCurrentUserId {
    Assert-GSMSchedulerWindows -Operation "Current user lookup"
    return [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
}

function Get-GameServerScriptPath {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][string]$ScriptName)
    $root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
    $path = Join-Path (Join-Path $root "scripts") $ScriptName
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Script was not found: $path" }
    return $path
}

function New-GameServerPowerShellTaskAction {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][string]$ScriptPath, [string]$Game = "corekeeper")
    $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`" -Game $Game"
    return New-ScheduledTaskAction -Execute "powershell.exe" -Argument $arguments
}

function Write-GameServerTaskPermissionHint {
    if (Test-GameServerAdministrator) { Write-GSMSchedulerInfo "Current PowerShell session is running as Administrator." }
    else { Write-GSMSchedulerWarn "Current PowerShell session is not elevated. Current-user scheduled tasks may still work, but registration can fail depending on Windows policy." }
}

function Register-GameServerStartupTask {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param([string]$Game = "corekeeper", [hashtable]$Settings)

    Assert-GSMSchedulerWindows -Operation "Task Scheduler registration"
    if ($null -eq $Settings) { $Settings = Get-GameServerSettings -Game $Game }
    Write-GameServerTaskPermissionHint
    $taskName = [string]$Settings["taskName"]
    $displayName = [string]$Settings["displayName"]
    $userId = Get-GameServerCurrentUserId
    $scriptPath = Get-GameServerScriptPath -ScriptName "start-server.ps1"
    $action = New-GameServerPowerShellTaskAction -ScriptPath $scriptPath -Game $Game
    $trigger = New-ScheduledTaskTrigger -AtLogOn -User $userId
    $principal = New-ScheduledTaskPrincipal -UserId $userId -LogonType Interactive -RunLevel LeastPrivilege
    $settingsSet = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit ([TimeSpan]::Zero)
    $description = "Start $displayName Dedicated Server for game '$Game' from $scriptPath at current user logon."
    if ($PSCmdlet.ShouldProcess($taskName, "Register scheduled startup task")) {
        try {
            Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settingsSet -Description $description -Force -ErrorAction Stop | Out-Null
        }
        catch {
            throw "Failed to register scheduled task '$taskName'. Try running PowerShell as Administrator if Windows policy requires it. Error: $($_.Exception.Message)"
        }
        return Get-ScheduledTask -TaskName $taskName -ErrorAction Stop
    }
}

function Unregister-GameServerTaskByName {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param([Parameter(Mandatory = $true)][string]$TaskName)
    Assert-GSMSchedulerWindows -Operation "Task Scheduler unregistration"
    Write-GameServerTaskPermissionHint
    $task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($null -eq $task) { Write-GSMSchedulerWarn "Scheduled task was not found: $TaskName"; return $false }
    if ($PSCmdlet.ShouldProcess($TaskName, "Unregister scheduled task")) {
        try { Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction Stop }
        catch { throw "Failed to unregister scheduled task '$TaskName'. Try running PowerShell as Administrator if Windows policy requires it. Error: $($_.Exception.Message)" }
    }
    return $true
}

function Enable-GameServerTaskByName {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param([Parameter(Mandatory = $true)][string]$TaskName)
    Assert-GSMSchedulerWindows -Operation "Task Scheduler enable"
    Write-GameServerTaskPermissionHint
    if ($PSCmdlet.ShouldProcess($TaskName, "Enable scheduled task")) { Enable-ScheduledTask -TaskName $TaskName -ErrorAction Stop | Out-Null }
    return Get-ScheduledTask -TaskName $TaskName -ErrorAction Stop
}

function Disable-GameServerTaskByName {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param([Parameter(Mandatory = $true)][string]$TaskName)
    Assert-GSMSchedulerWindows -Operation "Task Scheduler disable"
    Write-GameServerTaskPermissionHint
    if ($PSCmdlet.ShouldProcess($TaskName, "Disable scheduled task")) { Disable-ScheduledTask -TaskName $TaskName -ErrorAction Stop | Out-Null }
    return Get-ScheduledTask -TaskName $TaskName -ErrorAction Stop
}

function Unregister-GameServerStartupTask {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param([string]$Game = "corekeeper", [hashtable]$Settings)
    if ($null -eq $Settings) { $Settings = Get-GameServerSettings -Game $Game }
    return Unregister-GameServerTaskByName -TaskName ([string]$Settings["taskName"]) -WhatIf:$WhatIfPreference
}

function Enable-GameServerStartupTask {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param([string]$Game = "corekeeper", [hashtable]$Settings)
    if ($null -eq $Settings) { $Settings = Get-GameServerSettings -Game $Game }
    return Enable-GameServerTaskByName -TaskName ([string]$Settings["taskName"]) -WhatIf:$WhatIfPreference
}

function Disable-GameServerStartupTask {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param([string]$Game = "corekeeper", [hashtable]$Settings)
    if ($null -eq $Settings) { $Settings = Get-GameServerSettings -Game $Game }
    return Disable-GameServerTaskByName -TaskName ([string]$Settings["taskName"]) -WhatIf:$WhatIfPreference
}

function Assert-GameServerRestartTime {
    param([Parameter(Mandatory = $true)][string]$Time)
    if ($Time -notmatch "^([01][0-9]|2[0-3]):[0-5][0-9]$") { throw "Restart time must use HH:mm 24-hour format, for example 05:00." }
}

function Register-GameServerRestartTask {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param([string]$Game = "corekeeper", [Parameter(Mandatory = $true)][string]$Time, [hashtable]$Settings)
    Assert-GSMSchedulerWindows -Operation "Restart task registration"
    Assert-GameServerRestartTime -Time $Time
    if ($null -eq $Settings) { $Settings = Get-GameServerSettings -Game $Game }
    Write-GameServerTaskPermissionHint
    $displayName = [string]$Settings["displayName"]
    Write-GSMSchedulerWarn "Safe $displayName Dedicated Server shutdown is not verified yet. This task does not force-stop or automatically restart the server."
    $taskName = [string]$Settings["restartTaskName"]
    $userId = Get-GameServerCurrentUserId
    $scriptPath = Get-GameServerScriptPath -ScriptName "stop-server.ps1"
    $action = New-GameServerPowerShellTaskAction -ScriptPath $scriptPath -Game $Game
    $triggerTime = [datetime]::ParseExact($Time, "HH:mm", [System.Globalization.CultureInfo]::InvariantCulture)
    $trigger = New-ScheduledTaskTrigger -Daily -At $triggerTime
    $principal = New-ScheduledTaskPrincipal -UserId $userId -LogonType Interactive -RunLevel LeastPrivilege
    $settingsSet = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit ([TimeSpan]::Zero)
    $description = "Placeholder $displayName restart reminder at $Time for game '$Game'. Safe shutdown is not verified; action runs $scriptPath only."
    if ($PSCmdlet.ShouldProcess($taskName, "Register restart reminder task")) {
        try {
            Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settingsSet -Description $description -Force -ErrorAction Stop | Out-Null
        }
        catch {
            throw "Failed to register restart scheduled task '$taskName'. Try running PowerShell as Administrator if Windows policy requires it. Error: $($_.Exception.Message)"
        }
        return Get-ScheduledTask -TaskName $taskName -ErrorAction Stop
    }
}

function Unregister-GameServerRestartTask {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param([string]$Game = "corekeeper", [hashtable]$Settings)
    if ($null -eq $Settings) { $Settings = Get-GameServerSettings -Game $Game }
    return Unregister-GameServerTaskByName -TaskName ([string]$Settings["restartTaskName"]) -WhatIf:$WhatIfPreference
}

Export-ModuleMember -Function Test-GameServerAdministrator, Get-GameServerCurrentUserId, Get-GameServerScriptPath, New-GameServerPowerShellTaskAction, Write-GameServerTaskPermissionHint, Register-GameServerStartupTask, Unregister-GameServerTaskByName, Enable-GameServerTaskByName, Disable-GameServerTaskByName, Unregister-GameServerStartupTask, Enable-GameServerStartupTask, Disable-GameServerStartupTask, Assert-GameServerRestartTime, Register-GameServerRestartTask, Unregister-GameServerRestartTask
