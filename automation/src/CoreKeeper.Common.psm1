Set-StrictMode -Version 2.0

function Get-CKAutomationRoot {
    [CmdletBinding()]
    param()

    $moduleRoot = Split-Path -Parent $PSScriptRoot
    return $moduleRoot
}

function Write-CKInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    Write-Host "[INFO] $Message"
}

function Write-CKWarn {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    Write-Warning $Message
}

function New-CKDirectory {
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

function Test-CKWindows {
    [CmdletBinding()]
    param()

    if ($PSVersionTable.PSVersion.Major -ge 6) {
        return $IsWindows
    }

    return $env:OS -eq "Windows_NT"
}

function Assert-CKWindows {
    [CmdletBinding()]
    param(
        [string]$Operation = "This operation"
    )

    if (-not (Test-CKWindows)) {
        throw "$Operation requires Windows. macOS is only used for template editing and documentation."
    }
}

Export-ModuleMember -Function Get-CKAutomationRoot, Write-CKInfo, Write-CKWarn, New-CKDirectory, Test-CKWindows, Assert-CKWindows
