#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Installs and updates PowerShell modules for Microsoft 365 and Azure
.DESCRIPTION
    This script installs and updates the most important PowerShell modules for working with
    Microsoft 365 and Azure. It's designed to be integrated with dotfiles management.
.NOTES
    Author: Heino
    Date: 2025-06-09
#>

[CmdletBinding()]
param(
    [switch]$Force,
    [switch]$SkipVersionCheck
)

# Define modules to install
$m365AzureModules = @(
    # Microsoft Graph
    @{
        Name = "Microsoft.Graph"
        Description = "Microsoft Graph PowerShell SDK"
        Required = $true
    },
    @{
        Name = "Microsoft.Graph.Authentication"
        Description = "Microsoft Graph Authentication module"
        Required = $true
    },
    
    # Exchange Online
    @{
        Name = "ExchangeOnlineManagement"
        Description = "Exchange Online PowerShell V3 module"
        Required = $true
    },
    
    # Azure
    @{
        Name = "Az"
        Description = "Azure PowerShell module"
        Required = $true
    },
    @{
        Name = "Az.Accounts"
        Description = "Azure Accounts module"
        Required = $true
    },
    @{
        Name = "Az.Resources"
        Description = "Azure Resources module"
        Required = $true
    },
    
    # Microsoft Teams
    @{
        Name = "MicrosoftTeams"
        Description = "Microsoft Teams PowerShell module"
        Required = $false
    },
    
    # SharePoint Online
    @{
        Name = "PnP.PowerShell"
        Description = "SharePoint PnP PowerShell module"
        Required = $false
    },
    
    # Azure AD
    @{
        Name = "AzureAD"
        Description = "Azure Active Directory PowerShell module"
        Required = $false
    },
    
    # MSOnline (Legacy)
    @{
        Name = "MSOnline"
        Description = "Microsoft Online Services module (legacy)"
        Required = $false
    }
)

# Function to write colored output
function Write-ColorMessage {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [string]$ForegroundColor = "White"
    )
    
    Write-Host $Message -ForegroundColor $ForegroundColor
}

# Colors for output
$colors = @{
    Success = "Green"
    Info = "Cyan"
    Warning = "Yellow"
    Error = "Red"
    Emphasis = "Magenta"
}

# Function to install or update a module
function Install-ModuleIfNeeded {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Name,
        
        [Parameter(Mandatory=$false)]
        [string]$Description = "",
        
        [Parameter(Mandatory=$false)]
        [switch]$Required,
        
        [Parameter(Mandatory=$false)]
        [switch]$Force
    )
    
    try {
        # Check if module is installed
        $module = Get-Module -Name $Name -ListAvailable -ErrorAction SilentlyContinue
        
        if ($module) {
            $latestVersion = (Find-Module -Name $Name -ErrorAction SilentlyContinue).Version
            $currentVersion = $module | Sort-Object Version -Descending | Select-Object -First 1 -ExpandProperty Version
            
            if ($latestVersion -gt $currentVersion -or $Force) {
                Write-ColorMessage "Updating $Name from version $currentVersion to $latestVersion..." $colors.Info
                Update-Module -Name $Name -Force:$($Force) -ErrorAction SilentlyContinue
                Write-ColorMessage "✅ $Name updated to version $latestVersion" $colors.Success
            } else {
                Write-ColorMessage "✅ $Name is already up to date (version $currentVersion)" $colors.Success
            }
        } else {
            Write-ColorMessage "Installing $Name..." $colors.Info
            Install-Module -Name $Name -Scope CurrentUser -AllowClobber -Force:$($Force) -ErrorAction Stop
            Write-ColorMessage "✅ $Name installed successfully" $colors.Success
        }
        
        return $true
    } catch {
        if ($Required) {
            Write-ColorMessage "❌ Failed to install/update $Name: $($_.Exception.Message)" $colors.Error
            return $false
        } else {
            Write-ColorMessage "⚠️ Failed to install/update optional module $Name: $($_.Exception.Message)" $colors.Warning
            return $true
        }
    }
}

# Main function to install all modules
function Install-M365AzureModules {
    param(
        [switch]$Force
    )
    
    Write-ColorMessage "Installing/updating Microsoft 365 and Azure PowerShell modules..." $colors.Info
    Write-ColorMessage "This may take some time depending on your internet connection." $colors.Info
    
    # Make sure PSGallery is trusted
    if ((Get-PSRepository -Name "PSGallery").InstallationPolicy -ne "Trusted") {
        Write-ColorMessage "Setting PSGallery as trusted repository..." $colors.Info
        Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
    }
    
    $failedModules = @()
    $installedModules = 0
    $totalModules = $m365AzureModules.Count
    
    foreach ($moduleInfo in $m365AzureModules) {
        Write-ColorMessage "[$($installedModules+1)/$totalModules] Processing $($moduleInfo.Name) - $($moduleInfo.Description)" $colors.Emphasis
        
        $result = Install-ModuleIfNeeded -Name $moduleInfo.Name -Description $moduleInfo.Description -Required:$moduleInfo.Required -Force:$Force
        
        if (-not $result -and $moduleInfo.Required) {
            $failedModules += $moduleInfo.Name
        }
        
        $installedModules++
    }
    
    # Summary
    Write-ColorMessage "`nInstallation Summary:" $colors.Info
    Write-ColorMessage "Total modules processed: $totalModules" $colors.Info
    Write-ColorMessage "Successfully installed/updated: $($totalModules - $failedModules.Count)" $colors.Success
    
    if ($failedModules.Count -gt 0) {
        Write-ColorMessage "Failed to install required modules: $($failedModules -join ', ')" $colors.Error
        return $false
    } else {
        Write-ColorMessage "✅ All required modules installed successfully!" $colors.Success
        return $true
    }
}

# Run the installation
Install-M365AzureModules -Force:$Force
