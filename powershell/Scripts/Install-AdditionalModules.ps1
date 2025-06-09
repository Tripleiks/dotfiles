#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Installs additional useful PowerShell modules
.DESCRIPTION
    This script installs a curated set of PowerShell modules that enhance
    productivity, security, and automation capabilities.
.EXAMPLE
    ./Install-AdditionalModules.ps1
#>

# Define color scheme for output messages
$colors = @{
    Success = "Green"
    Info    = "Cyan"
    Warning = "Yellow"
    Error   = "Red"
}

function Write-ColorMessage {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [string]$Color = $colors.Info
    )
    
    Write-Host $Message -ForegroundColor $Color
}

# Define modules to install
$modules = @(
    # Security modules
    @{Name = "PSScriptAnalyzer"; Required = $true; Description = "Static code analysis tool for PowerShell scripts" },
    @{Name = "Microsoft.PowerShell.SecretManagement"; Required = $false; Description = "Secure credential and secret management" },
    @{Name = "Microsoft.PowerShell.SecretStore"; Required = $false; Description = "Backend store for SecretManagement" },
    
    # Enhanced Azure & M365 Management
    @{Name = "AzureADPreview"; Required = $false; Description = "Advanced Azure AD management capabilities" },
    @{Name = "MSIdentityTools"; Required = $false; Description = "Additional identity management tools" },
    @{Name = "MSAL.PS"; Required = $false; Description = "Microsoft Authentication Library for PowerShell" },
    
    # DevOps & Automation
    @{Name = "Pester"; Required = $true; Description = "Testing framework for PowerShell" },
    @{Name = "PSDepend"; Required = $false; Description = "Dependency handler for PowerShell modules" },
    @{Name = "InvokeBuild"; Required = $false; Description = "Build automation tool similar to Make/Rake" },
    
    # Enhanced Productivity
    @{Name = "ImportExcel"; Required = $false; Description = "Excel manipulation without Excel installed" },
    @{Name = "PSWriteHTML"; Required = $false; Description = "Create beautiful HTML reports" },
    @{Name = "PSWritePDF"; Required = $false; Description = "Create and manipulate PDF files" }
)

function Install-Module-Safe {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,
        
        [Parameter(Mandatory = $false)]
        [bool]$Required = $false,
        
        [Parameter(Mandatory = $false)]
        [string]$Description = ""
    )
    
    try {
        # Check if module is already installed
        $module = Get-Module -Name $Name -ListAvailable -ErrorAction SilentlyContinue
        
        if ($module) {
            # Module exists, check for updates
            $latestModule = Find-Module -Name $Name -ErrorAction SilentlyContinue
            
            if ($latestModule -and ($latestModule.Version -gt $module.Version)) {
                Write-ColorMessage "⬆️ Updating $Name ($Description) from $($module.Version) to $($latestModule.Version)..." $colors.Info
                Update-Module -Name $Name -Force -ErrorAction Stop
                Write-ColorMessage "✅ $Name updated successfully" $colors.Success
            } else {
                Write-ColorMessage "✅ $Name is already up to date (version $($module.Version))" $colors.Success
            }
        } else {
            # Module doesn't exist, install it
            Write-ColorMessage "📦 Installing $Name ($Description)..." $colors.Info
            Install-Module -Name $Name -Force -AllowClobber -SkipPublisherCheck -ErrorAction Stop
            Write-ColorMessage "✅ $Name installed successfully" $colors.Success
        }
        
        return $true
    } catch {
        if ($Required) {
            Write-ColorMessage "❌ Failed to install/update $Name" $colors.Error
            return $false
        } else {
            Write-ColorMessage "⚠️ Failed to install/update optional module $Name" $colors.Warning
            return $true
        }
    }
}

# Main script execution
Write-ColorMessage "🚀 Installing additional PowerShell modules..." $colors.Info

# Ensure PSGallery is trusted
if ((Get-PSRepository -Name "PSGallery").InstallationPolicy -ne "Trusted") {
    Write-ColorMessage "🔒 Setting PSGallery as a trusted repository..." $colors.Info
    Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
}

# Install modules
$successCount = 0
$totalCount = $modules.Count

foreach ($module in $modules) {
    Write-ColorMessage "[$($successCount + 1)/$totalCount] Processing $($module.Name) - $($module.Description)" $colors.Info
    $result = Install-Module-Safe -Name $module.Name -Required $module.Required -Description $module.Description
    if ($result) {
        $successCount++
    }
}

# Summary
Write-ColorMessage "Installation Summary:" $colors.Info
Write-ColorMessage "Total modules processed: $totalCount" $colors.Info
Write-ColorMessage "Successfully installed/updated: $successCount" $colors.Info

if ($successCount -eq $totalCount) {
    Write-ColorMessage "✅ All modules installed successfully!" $colors.Success
    return $true
} else {
    Write-ColorMessage "⚠️ Some modules failed to install. Check the log above for details." $colors.Warning
    return $false
}
