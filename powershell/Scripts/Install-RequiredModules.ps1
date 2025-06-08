#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Installs required PowerShell modules for the Ultimate PowerShell Profile.
.DESCRIPTION
    This script checks for and installs required PowerShell modules if they are not already installed.
    It's designed to be run automatically when the profile loads or manually as needed.
.NOTES
    Author: Heino
    Date: 2025-06-09
#>

[CmdletBinding()]
param(
    [switch]$Force,
    [switch]$Quiet
)

function Write-ColorOutput {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [string]$ForegroundColor = "White"
    )
    
    if (-not $Quiet) {
        Write-Host $Message -ForegroundColor $ForegroundColor
    }
}

function Test-IsAdmin {
    if ($IsWindows) {
        $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
        return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    }
    elseif ($IsLinux -or $IsMacOS) {
        return (id -u) -eq 0
    }
    return $false
}

function Install-ModuleIfMissing {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Name,
        
        [Parameter(Mandatory=$false)]
        [string]$MinimumVersion = "",
        
        [Parameter(Mandatory=$false)]
        [string]$Description = "",
        
        [Parameter(Mandatory=$false)]
        [switch]$AllowPrerelease = $false
    )
    
    $moduleInstalled = $false
    
    # Check if module is installed
    if ($MinimumVersion -ne "") {
        $moduleInstalled = Get-Module -ListAvailable -Name $Name | Where-Object { $_.Version -ge $MinimumVersion }
    }
    else {
        $moduleInstalled = Get-Module -ListAvailable -Name $Name
    }
    
    # Install module if not installed or if Force is specified
    if (-not $moduleInstalled -or $Force) {
        $desc = if ($Description -ne "") { $Description } else { $Name }
        Write-ColorOutput "Installing module: $desc..." "Yellow"
        
        $installParams = @{
            Name = $Name
            Force = $true
            SkipPublisherCheck = $true
            Scope = "CurrentUser"
        }
        
        if ($MinimumVersion -ne "") {
            $installParams.MinimumVersion = $MinimumVersion
        }
        
        if ($AllowPrerelease) {
            $installParams.AllowPrerelease = $true
        }
        
        try {
            Install-Module @installParams
            Write-ColorOutput "✅ Module installed: $Name" "Green"
        }
        catch {
            Write-ColorOutput "❌ Failed to install module: $Name - $_" "Red"
            return $false
        }
    }
    else {
        Write-ColorOutput "✅ Module already installed: $Name" "Green"
    }
    
    return $true
}

# Main script execution
Write-ColorOutput "Checking for required PowerShell modules..." "Cyan"

# Ensure PSGallery is trusted
if ((Get-PSRepository -Name "PSGallery").InstallationPolicy -ne "Trusted") {
    Write-ColorOutput "Setting PSGallery as a trusted repository..." "Yellow"
    Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
}

# Required modules with minimum versions
$requiredModules = @(
    @{
        Name = "PSReadLine"
        MinimumVersion = "2.2.0"
        Description = "PSReadLine (enhanced command line editing)"
    },
    @{
        Name = "Terminal-Icons"
        MinimumVersion = "0.10.0"
        Description = "Terminal-Icons (file and folder icons)"
    },
    @{
        Name = "posh-git"
        MinimumVersion = "1.0.0"
        Description = "posh-git (Git integration)"
    },
    @{
        Name = "oh-my-posh"
        MinimumVersion = "7.0.0"
        Description = "oh-my-posh (prompt theming engine)"
    },
    @{
        Name = "z"
        MinimumVersion = "1.1.13"
        Description = "z (directory jumper)"
    },
    @{
        Name = "PSFzf"
        MinimumVersion = "2.0.0"
        Description = "PSFzf (fuzzy finder integration)"
        AllowPrerelease = $true
    },
    @{
        Name = "Microsoft.PowerShell.ConsoleGuiTools"
        MinimumVersion = "0.7.5"
        Description = "ConsoleGuiTools (Out-GridView for terminal)"
    }
)

$allModulesInstalled = $true

foreach ($module in $requiredModules) {
    $installParams = @{
        Name = $module.Name
        Description = $module.Description
    }
    
    if ($module.MinimumVersion) {
        $installParams.MinimumVersion = $module.MinimumVersion
    }
    
    if ($module.AllowPrerelease) {
        $installParams.AllowPrerelease = $true
    }
    
    $success = Install-ModuleIfMissing @installParams
    if (-not $success) {
        $allModulesInstalled = $false
    }
}

if ($allModulesInstalled) {
    Write-ColorOutput "✅ All required PowerShell modules are installed!" "Green"
}
else {
    Write-ColorOutput "⚠️ Some modules could not be installed. You may need to run PowerShell as administrator or check your internet connection." "Yellow"
}
