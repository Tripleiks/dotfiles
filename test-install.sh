#!/bin/bash

# Test script to validate the installation process
# This script simulates the key parts of the installation process without making actual changes

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
DOTFILES_DIR="$HOME/Coding/GitHub/dotfiles"
TEST_DIR="/tmp/dotfiles-test"

# Print with color
print_message() {
  echo -e "${2}${1}${NC}"
}

# Print step information
print_step() {
  print_message "\n=== $1 ===" "$BLUE"
}

# Print success message
print_success() {
  print_message "✅ $1" "$GREEN"
}

# Print warning message
print_warning() {
  print_message "⚠️  $1" "$YELLOW"
}

# Print error message
print_error() {
  print_message "❌ $1" "$RED"
}

# Check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Test PowerShell configuration
test_powershell_config() {
  print_step "Testing PowerShell configuration"
  
  # Check if PowerShell is installed
  if command_exists "pwsh"; then
    print_success "PowerShell is installed"
    
    # Check PowerShell version
    PWSH_VERSION=$(pwsh -c '$PSVersionTable.PSVersion.ToString()')
    print_message "PowerShell version: $PWSH_VERSION" "$GREEN"
    
    # Check if PowerShell profile exists
    if [ -f "$HOME/.config/powershell/Microsoft.PowerShell_profile.ps1" ]; then
      print_success "PowerShell profile exists"
    else
      print_warning "PowerShell profile does not exist"
    fi
    
    # Check if VSCode PowerShell profile exists
    if [ -f "$HOME/.config/powershell/Microsoft.VSCode_profile.ps1" ]; then
      print_success "VSCode PowerShell profile exists"
    else
      print_warning "VSCode PowerShell profile does not exist"
    fi
    
    # Check if reload-profile.ps1 exists
    if [ -f "$HOME/.config/powershell/reload-profile.ps1" ]; then
      print_success "PowerShell reload script exists"
    else
      print_warning "PowerShell reload script does not exist"
    fi
    
    # Check if Starship is installed
    if command_exists "starship"; then
      print_success "Starship is installed"
      
      # Check Starship version
      STARSHIP_VERSION=$(starship --version | cut -d ' ' -f 2)
      print_message "Starship version: $STARSHIP_VERSION" "$GREEN"
      
      # Check if Starship config exists
      if [ -f "$HOME/.config/starship.toml" ]; then
        print_success "Starship config exists"
      else
        print_warning "Starship config does not exist"
      fi
    else
      print_warning "Starship is not installed"
    fi
  else
    print_warning "PowerShell is not installed"
  fi
}

# Test symbolic links
test_symlinks() {
  print_step "Testing symbolic links"
  
  # Create test directory
  mkdir -p "$TEST_DIR"
  
  # Test PowerShell profile symlink
  if [ -L "$HOME/.config/powershell/Microsoft.PowerShell_profile.ps1" ]; then
    TARGET=$(readlink "$HOME/.config/powershell/Microsoft.PowerShell_profile.ps1")
    if [[ "$TARGET" == *"dotfiles"* ]]; then
      print_success "PowerShell profile is correctly linked to dotfiles"
    else
      print_warning "PowerShell profile is linked but not to dotfiles: $TARGET"
    fi
  else
    print_warning "PowerShell profile is not a symlink"
  fi
  
  # Test VSCode PowerShell profile symlink
  if [ -L "$HOME/.config/powershell/Microsoft.VSCode_profile.ps1" ]; then
    TARGET=$(readlink "$HOME/.config/powershell/Microsoft.VSCode_profile.ps1")
    if [[ "$TARGET" == *"dotfiles"* ]]; then
      print_success "VSCode PowerShell profile is correctly linked to dotfiles"
    else
      print_warning "VSCode PowerShell profile is linked but not to dotfiles: $TARGET"
    fi
  else
    print_warning "VSCode PowerShell profile is not a symlink"
  fi
  
  # Test Starship config symlink
  if [ -L "$HOME/.config/starship.toml" ]; then
    TARGET=$(readlink "$HOME/.config/starship.toml")
    if [[ "$TARGET" == *"dotfiles"* ]]; then
      print_success "Starship config is correctly linked to dotfiles"
    else
      print_warning "Starship config is linked but not to dotfiles: $TARGET"
    fi
  else
    print_warning "Starship config is not a symlink"
  fi
}

# Test PowerShell profile loading
test_powershell_profile_loading() {
  print_step "Testing PowerShell profile loading"
  
  if command_exists "pwsh"; then
    # Test if PowerShell profile loads without errors
    print_message "Testing if PowerShell profile loads without errors..." "$YELLOW"
    pwsh -NoProfile -Command "try { . '$HOME/.config/powershell/Microsoft.PowerShell_profile.ps1'; Write-Host 'Profile loaded successfully' -ForegroundColor Green } catch { Write-Host 'Error loading profile: ' -ForegroundColor Red -NoNewline; Write-Host \$_.Exception.Message -ForegroundColor Red; exit 1 }"
    
    if [ $? -eq 0 ]; then
      print_success "PowerShell profile loads without errors"
    else
      print_error "PowerShell profile has errors"
    fi
    
    # Test if reload-profile.ps1 works
    print_message "Testing if reload-profile.ps1 works..." "$YELLOW"
    pwsh -NoProfile -Command "try { . '$HOME/.config/powershell/reload-profile.ps1'; Write-Host 'Reload script works' -ForegroundColor Green } catch { Write-Host 'Error in reload script: ' -ForegroundColor Red -NoNewline; Write-Host \$_.Exception.Message -ForegroundColor Red; exit 1 }"
    
    if [ $? -eq 0 ]; then
      print_success "PowerShell reload script works"
    else
      print_error "PowerShell reload script has errors"
    fi
  else
    print_warning "PowerShell is not installed, skipping profile loading tests"
  fi
}

# Main test process
main() {
  print_message "\n🧪 Starting dotfiles installation test...\n" "$GREEN"
  
  # Test PowerShell configuration
  test_powershell_config
  
  # Test symbolic links
  test_symlinks
  
  # Test PowerShell profile loading
  test_powershell_profile_loading
  
  # Clean up
  rm -rf "$TEST_DIR"
  
  print_message "\n🎉 Test completed!\n" "$GREEN"
}

# Run the main function
main
