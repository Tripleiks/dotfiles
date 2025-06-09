#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Synchronizes the PowerShell Script Repository from GitHub
.DESCRIPTION
    This script clones or updates the PowerShell Script Repository from GitHub
    and ensures it's properly integrated with the dotfiles management system.
.PARAMETER Force
    Force update even if the repository is already up to date
.EXAMPLE
    ./Sync-PowerShellRepository.ps1
    ./Sync-PowerShellRepository.ps1 -Force
#>

param(
    [switch]$Force,
    [switch]$Quiet
)

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

# Define repository information
$repoOwner = "Tripleiks"
$repoName = "PowerShellScripts"  # Adjust this to your actual repository name
$repoUrl = "https://github.com/$repoOwner/$repoName.git"
$localRepoPath = "$HOME/.config/powershell/Repository"

# Ensure the parent directory exists
if (-not (Test-Path (Split-Path -Parent $localRepoPath))) {
    New-Item -ItemType Directory -Path (Split-Path -Parent $localRepoPath) -Force | Out-Null
}

# Function to clone or update the repository
function Sync-Repository {
    if (-not (Test-Path "$localRepoPath/.git")) {
        # Repository doesn't exist locally, clone it
        Write-ColorMessage "🔄 Cloning PowerShell Script Repository from $repoUrl..." $colors.Info
        try {
            git clone $repoUrl $localRepoPath
            if ($LASTEXITCODE -eq 0) {
                Write-ColorMessage "✅ PowerShell Script Repository cloned successfully to $localRepoPath" $colors.Success
                return $true
            } else {
                Write-ColorMessage "❌ Failed to clone PowerShell Script Repository" $colors.Error
                return $false
            }
        } catch {
            Write-ColorMessage "❌ Error cloning repository: $_" $colors.Error
            return $false
        }
    } else {
        # Repository exists, update it
        Write-ColorMessage "🔄 Updating PowerShell Script Repository..." $colors.Info
        try {
            Push-Location $localRepoPath
            git fetch
            
            # Check if there are any changes to pull
            $status = git status -uno
            if ($status -match "Your branch is up to date" -and -not $Force) {
                Write-ColorMessage "✅ PowerShell Script Repository is already up to date" $colors.Success
                Pop-Location
                return $true
            }
            
            # Pull changes
            git pull
            if ($LASTEXITCODE -eq 0) {
                Write-ColorMessage "✅ PowerShell Script Repository updated successfully" $colors.Success
                Pop-Location
                return $true
            } else {
                Write-ColorMessage "❌ Failed to update PowerShell Script Repository" $colors.Error
                Pop-Location
                return $false
            }
        } catch {
            Write-ColorMessage "❌ Error updating repository: $_" $colors.Error
            if (Get-Location -eq $localRepoPath) {
                Pop-Location
            }
            return $false
        }
    }
}

# Function to create symbolic links to the repository in the dotfiles structure
function New-RepositoryLinks {
    # Create a symbolic link from the dotfiles powershell/Scripts directory to the repository
    $dotfilesScriptsDir = "$HOME/coding/github/dotfiles/powershell/Scripts/Repository"
    
    # Remove existing link or directory if it exists
    if (Test-Path $dotfilesScriptsDir) {
        Remove-Item -Path $dotfilesScriptsDir -Force -Recurse
    }
    
    # Create directory for the link
    if (-not (Test-Path (Split-Path -Parent $dotfilesScriptsDir))) {
        New-Item -ItemType Directory -Path (Split-Path -Parent $dotfilesScriptsDir) -Force | Out-Null
    }
    
    # Create a symbolic link
    try {
        if ($IsWindows) {
            cmd /c mklink /D $dotfilesScriptsDir $localRepoPath
        } else {
            ln -sf $localRepoPath $dotfilesScriptsDir
        }
        Write-ColorMessage "✅ Created symbolic link to PowerShell Script Repository in dotfiles" $colors.Success
        return $true
    } catch {
        Write-ColorMessage "❌ Error creating symbolic link: $_" $colors.Error
        return $false
    }
}

# Main execution
Write-ColorMessage "🚀 Synchronizing PowerShell Script Repository..." $colors.Info

# Sync the repository
$syncResult = Sync-Repository

if ($syncResult) {
    # Create symbolic links
    $linkResult = New-RepositoryLinks
    
    if ($linkResult) {
        Write-ColorMessage "✅ PowerShell Script Repository integration complete" $colors.Success
        return $true
    } else {
        Write-ColorMessage "⚠️ PowerShell Script Repository synced but linking failed" $colors.Warning
        return $false
    }
} else {
    Write-ColorMessage "❌ Failed to synchronize PowerShell Script Repository" $colors.Error
    return $false
}
