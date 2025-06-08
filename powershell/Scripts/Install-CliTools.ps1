#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Checks for and installs required CLI tools for the Ultimate PowerShell Profile.
.DESCRIPTION
    This script checks for and installs required CLI tools using Homebrew if they are not already installed.
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

function Test-Command {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Command
    )
    
    try {
        if ($IsWindows) {
            $null = Get-Command $Command -ErrorAction Stop
        }
        else {
            $null = bash -c "command -v $Command" 2>$null
        }
        return $true
    }
    catch {
        return $false
    }
}

function Install-HomebrewIfMissing {
    if (-not (Test-Command "brew")) {
        Write-ColorOutput "Installing Homebrew..." "Yellow"
        try {
            if ($IsMacOS) {
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                
                # Add Homebrew to PATH based on architecture
                if ((uname -m) -eq "arm64") {
                    # M1/M2 Mac
                    $brewPath = "/opt/homebrew/bin/brew"
                    if (-not (Test-Path $brewPath)) {
                        Write-ColorOutput "❌ Homebrew installation failed" "Red"
                        return $false
                    }
                    
                    # Add to PATH for current session
                    $env:PATH = "/opt/homebrew/bin:$env:PATH"
                }
                else {
                    # Intel Mac
                    $brewPath = "/usr/local/bin/brew"
                    if (-not (Test-Path $brewPath)) {
                        Write-ColorOutput "❌ Homebrew installation failed" "Red"
                        return $false
                    }
                }
                
                Write-ColorOutput "✅ Homebrew installed" "Green"
                return $true
            }
            elseif ($IsLinux) {
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                
                # Add Homebrew to PATH for current session
                $env:PATH = "/home/linuxbrew/.linuxbrew/bin:$env:PATH"
                
                Write-ColorOutput "✅ Homebrew installed" "Green"
                return $true
            }
            else {
                Write-ColorOutput "❌ Unsupported OS for Homebrew installation" "Red"
                return $false
            }
        }
        catch {
            Write-ColorOutput "❌ Failed to install Homebrew: $_" "Red"
            return $false
        }
    }
    else {
        Write-ColorOutput "✅ Homebrew already installed" "Green"
        return $true
    }
}

function Install-BrewPackageIfMissing {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Package,
        
        [Parameter(Mandatory=$false)]
        [string]$Description = "",
        
        [Parameter(Mandatory=$false)]
        [string]$Alias = ""
    )
    
    $desc = if ($Description -ne "") { $Description } else { $Package }
    $aliasInfo = if ($Alias -ne "") { " (alias: $Alias)" } else { "" }
    
    # Check if package is installed
    $isInstalled = $false
    try {
        $brewList = & brew list --formula 2>$null
        $isInstalled = $brewList -contains $Package
    }
    catch {
        $isInstalled = $false
    }
    
    # Install package if not installed or if Force is specified
    if (-not $isInstalled -or $Force) {
        Write-ColorOutput "Installing $desc$aliasInfo..." "Yellow"
        
        try {
            & brew install $Package 2>&1
            
            if ($LASTEXITCODE -eq 0) {
                Write-ColorOutput "✅ Installed: $desc" "Green"
                return $true
            }
            else {
                Write-ColorOutput "❌ Failed to install: $desc" "Red"
                return $false
            }
        }
        catch {
            Write-ColorOutput "❌ Error installing $desc: $_" "Red"
            return $false
        }
    }
    else {
        Write-ColorOutput "✅ Already installed: $desc$aliasInfo" "Green"
        return $true
    }
}

# Main script execution
Write-ColorOutput "Checking for required CLI tools..." "Cyan"

# Ensure Homebrew is installed
if (-not (Install-HomebrewIfMissing)) {
    Write-ColorOutput "❌ Cannot proceed without Homebrew" "Red"
    return
}

# Required CLI tools with descriptions and aliases
$requiredTools = @(
    @{
        Package = "eza"
        Description = "Modern ls replacement"
        Alias = "ez, ll, la, lt"
    },
    @{
        Package = "fzf"
        Description = "Fuzzy finder"
        Alias = "fzf"
    },
    @{
        Package = "ripgrep"
        Description = "Fast grep replacement"
        Alias = "rg"
    },
    @{
        Package = "bat"
        Description = "Cat with syntax highlighting"
        Alias = "cat"
    },
    @{
        Package = "fd"
        Description = "Fast find alternative"
        Alias = "fd"
    },
    @{
        Package = "jq"
        Description = "JSON processor"
        Alias = "jq"
    },
    @{
        Package = "git-delta"
        Description = "Syntax-highlighting pager for git"
        Alias = "gdiff"
    },
    @{
        Package = "age"
        Description = "Simple file encryption tool"
        Alias = "encrypt, decrypt"
    },
    @{
        Package = "tealdeer"
        Description = "Simplified man pages"
        Alias = "help"
    },
    @{
        Package = "asciinema"
        Description = "Terminal session recorder"
        Alias = "rec, play, upload"
    },
    @{
        Package = "ncdu"
        Description = "Disk usage analyzer"
        Alias = "ncdu"
    },
    @{
        Package = "lazygit"
        Description = "Terminal UI for git"
        Alias = "lg"
    },
    @{
        Package = "gping"
        Description = "Ping with graph"
        Alias = "ping"
    },
    @{
        Package = "doggo"
        Description = "DNS client"
        Alias = "dig, dns"
    },
    @{
        Package = "bandwhich"
        Description = "Network utilization tool"
        Alias = "bw"
    },
    @{
        Package = "duf"
        Description = "Disk usage utility"
        Alias = "du, df"
    },
    @{
        Package = "ranger"
        Description = "Terminal file manager"
        Alias = "fm"
    }
)

$allToolsInstalled = $true

foreach ($tool in $requiredTools) {
    $success = Install-BrewPackageIfMissing -Package $tool.Package -Description $tool.Description -Alias $tool.Alias
    if (-not $success) {
        $allToolsInstalled = $false
    }
}

if ($allToolsInstalled) {
    Write-ColorOutput "✅ All required CLI tools are installed!" "Green"
}
else {
    Write-ColorOutput "⚠️ Some CLI tools could not be installed. Check the output for details." "Yellow"
}
