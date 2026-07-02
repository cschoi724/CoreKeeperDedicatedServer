Set-StrictMode -Version 2.0

$configModule = Join-Path $PSScriptRoot "CoreKeeper.Config.psm1"
$schedulerManagerModule = Join-Path (Join-Path $PSScriptRoot "Core") "SchedulerManager.psm1"
Import-Module $configModule -Force
Import-Module $schedulerManagerModule -Force

function Test-CKAdministrator { return Test-GameServerAdministrator }
function Get-CKCurrentUserId { return Get-GameServerCurrentUserId }
function Get-CKScriptPath { param([Parameter(Mandatory = $true)][string]$ScriptName) return Get-GameServerScriptPath -ScriptName $ScriptName }
function New-CKPowerShellTaskAction { param([Parameter(Mandatory = $true)][string]$ScriptPath) return New-GameServerPowerShellTaskAction -ScriptPath $ScriptPath -Game "corekeeper" }
function Write-CKTaskPermissionHint { Write-GameServerTaskPermissionHint }

function Register-CKServerStartupTask {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param([hashtable]$Settings)
    if ($null -eq $Settings) { $Settings = Get-CKSettings }
    return Register-GameServerStartupTask -Game "corekeeper" -Settings $Settings -WhatIf:$WhatIfPreference
}
function Unregister-CKTaskByName { [CmdletBinding(SupportsShouldProcess = $true)] param([Parameter(Mandatory = $true)][string]$TaskName) return Unregister-GameServerTaskByName -TaskName $TaskName -WhatIf:$WhatIfPreference }
function Enable-CKTaskByName { [CmdletBinding(SupportsShouldProcess = $true)] param([Parameter(Mandatory = $true)][string]$TaskName) return Enable-GameServerTaskByName -TaskName $TaskName -WhatIf:$WhatIfPreference }
function Disable-CKTaskByName { [CmdletBinding(SupportsShouldProcess = $true)] param([Parameter(Mandatory = $true)][string]$TaskName) return Disable-GameServerTaskByName -TaskName $TaskName -WhatIf:$WhatIfPreference }
function Unregister-CKServerStartupTask { [CmdletBinding(SupportsShouldProcess = $true)] param([hashtable]$Settings) if ($null -eq $Settings) { $Settings = Get-CKSettings }; return Unregister-GameServerStartupTask -Game "corekeeper" -Settings $Settings -WhatIf:$WhatIfPreference }
function Enable-CKServerStartupTask { [CmdletBinding(SupportsShouldProcess = $true)] param([hashtable]$Settings) if ($null -eq $Settings) { $Settings = Get-CKSettings }; return Enable-GameServerStartupTask -Game "corekeeper" -Settings $Settings -WhatIf:$WhatIfPreference }
function Disable-CKServerStartupTask { [CmdletBinding(SupportsShouldProcess = $true)] param([hashtable]$Settings) if ($null -eq $Settings) { $Settings = Get-CKSettings }; return Disable-GameServerStartupTask -Game "corekeeper" -Settings $Settings -WhatIf:$WhatIfPreference }
function Assert-CKRestartTime { param([Parameter(Mandatory = $true)][string]$Time) Assert-GameServerRestartTime -Time $Time }

function Register-CKRestartTask {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param([Parameter(Mandatory = $true)][string]$Time, [hashtable]$Settings)
    if ($null -eq $Settings) { $Settings = Get-CKSettings }
    return Register-GameServerRestartTask -Game "corekeeper" -Time $Time -Settings $Settings -WhatIf:$WhatIfPreference
}
function Unregister-CKRestartTask { [CmdletBinding(SupportsShouldProcess = $true)] param([hashtable]$Settings) if ($null -eq $Settings) { $Settings = Get-CKSettings }; return Unregister-GameServerRestartTask -Game "corekeeper" -Settings $Settings -WhatIf:$WhatIfPreference }

Export-ModuleMember -Function Test-CKAdministrator, Get-CKCurrentUserId, Get-CKScriptPath, New-CKPowerShellTaskAction, Write-CKTaskPermissionHint, Register-CKServerStartupTask, Unregister-CKTaskByName, Enable-CKTaskByName, Disable-CKTaskByName, Unregister-CKServerStartupTask, Enable-CKServerStartupTask, Disable-CKServerStartupTask, Assert-CKRestartTime, Register-CKRestartTask, Unregister-CKRestartTask
