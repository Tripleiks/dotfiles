# VSCode-specific PowerShell profile
# This file sources the main PowerShell profile to ensure consistent behavior

# Check if we're reloading the profile (to prevent duplicate messages)
$global:ProfileLoadCount = if ($global:ProfileLoadCount) { $global:ProfileLoadCount + 1 } else { 1 }

# Source the main PowerShell profile
$mainProfile = Join-Path -Path $PSScriptRoot -ChildPath "Microsoft.PowerShell_profile.ps1"
if (Test-Path $mainProfile) {
    # Load the main profile
    . $mainProfile
    
    # Only show the VSCode message on first load, not on reload
    if ($global:ProfileLoadCount -eq 1) {
        Write-Host "VSCode PowerShell profile loaded, sourcing main profile from: $mainProfile" -ForegroundColor Cyan
    }
} else {
    Write-Host "Main PowerShell profile not found at: $mainProfile" -ForegroundColor Red
}

# Add any VSCode-specific settings below this line
