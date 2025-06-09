#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Helper script to run Microsoft 365 and Azure commands
.DESCRIPTION
    This script provides a way to run Microsoft 365 and Azure commands
    from any shell, including zsh. It loads the PowerShell profile
    and executes the specified command.
.PARAMETER Command
    The command to run (updatem365, m365, azure, etc.)
.EXAMPLE
    ./Run-M365Commands.ps1 updatem365
    ./Run-M365Commands.ps1 m365
    ./Run-M365Commands.ps1 azure
#>

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Command,
    
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$Arguments
)

# Load the PowerShell profile
$profilePath = "$HOME/.config/powershell/Microsoft.PowerShell_profile.ps1"
if (Test-Path $profilePath) {
    try {
        # Source the profile
        . $profilePath
        
        # Execute the command
        if ($Arguments) {
            & $Command @Arguments
        } else {
            & $Command
        }
    }
    catch {
        Write-Host "Error executing command: $_" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "PowerShell profile not found at: $profilePath" -ForegroundColor Red
    exit 1
}
