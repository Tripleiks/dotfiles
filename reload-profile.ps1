# Change to dotfiles directory
Set-Location '/Users/heino/Coding/GitHub/dotfiles'

# Clear any existing PowerShell sessions
Clear-Host

# Reload the profile once
. $PROFILE

# Display a clean message
Write-Host "Profile reloaded successfully." -ForegroundColor Green
