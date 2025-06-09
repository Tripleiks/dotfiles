#!/bin/bash

# Dotfiles Sync Script
# This script syncs your dotfiles to GitHub

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
DOTFILES_DIR="$HOME/dotfiles"

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

# Check if dotfiles directory exists
if [ ! -d "$DOTFILES_DIR" ]; then
  print_error "Dotfiles directory not found at $DOTFILES_DIR"
  exit 1
fi

# Check if it's a git repository
if [ ! -d "$DOTFILES_DIR/.git" ]; then
  print_error "Not a git repository. Please initialize git in $DOTFILES_DIR"
  exit 1
fi

# Update dotfiles from the current system
update_dotfiles() {
  print_step "Updating dotfiles from system"
  
  # Update ZSH files
  cp -f "$HOME/.zshrc" "$DOTFILES_DIR/zsh/.zshrc" 2>/dev/null || true
  cp -f "$HOME/.zshenv" "$DOTFILES_DIR/zsh/.zshenv" 2>/dev/null || true
  cp -f "$HOME/.p10k.zsh" "$DOTFILES_DIR/zsh/.p10k.zsh" 2>/dev/null || true
  
  # Update Oh My Posh theme
  mkdir -p "$DOTFILES_DIR/oh-my-posh/themes"
  cp -f "$HOME/.config/oh-my-posh/themes/my-quick-term.omp.json" "$DOTFILES_DIR/oh-my-posh/themes/" 2>/dev/null || true
  
  # Update Git configuration
  cp -f "$HOME/.gitconfig" "$DOTFILES_DIR/git/.gitconfig" 2>/dev/null || true
  cp -f "$HOME/.gitignore_global" "$DOTFILES_DIR/git/.gitignore_global" 2>/dev/null || true
  
  # Update PowerShell configuration
  mkdir -p "$DOTFILES_DIR/powershell/Scripts"
  cp -f "$HOME/.config/powershell/Microsoft.PowerShell_profile.ps1" "$DOTFILES_DIR/powershell/Microsoft.PowerShell_profile.ps1" 2>/dev/null || true
  cp -rf "$HOME/.config/powershell/Scripts/" "$DOTFILES_DIR/powershell/" 2>/dev/null || true
  
  # Update Yazi configuration
  mkdir -p "$DOTFILES_DIR/.config/yazi/plugins"
  cp -f "$HOME/.config/yazi/yazi.toml" "$DOTFILES_DIR/.config/yazi/" 2>/dev/null || true
  cp -f "$HOME/.config/yazi/keymap.toml" "$DOTFILES_DIR/.config/yazi/" 2>/dev/null || true
  cp -f "$HOME/.config/yazi/theme.toml" "$DOTFILES_DIR/.config/yazi/" 2>/dev/null || true
  cp -rf "$HOME/.config/yazi/plugins/" "$DOTFILES_DIR/.config/yazi/" 2>/dev/null || true
  
  # Update btop configuration
  mkdir -p "$DOTFILES_DIR/btop"
  cp -f "$HOME/.config/btop/btop.conf" "$DOTFILES_DIR/btop/" 2>/dev/null || true
  
  # Update neofetch configuration
  mkdir -p "$DOTFILES_DIR/neofetch"
  cp -f "$HOME/.config/neofetch/config.conf" "$DOTFILES_DIR/neofetch/" 2>/dev/null || true
  
  # Update thefuck configuration
  mkdir -p "$DOTFILES_DIR/thefuck"
  cp -f "$HOME/.config/thefuck/settings.py" "$DOTFILES_DIR/thefuck/" 2>/dev/null || true
  
  # Update Starship configuration
  mkdir -p "$DOTFILES_DIR/starship"
  cp -f "$HOME/.config/starship.toml" "$DOTFILES_DIR/starship/" 2>/dev/null || true
  
  # Update Brewfile
  if command -v brew >/dev/null 2>&1; then
    print_message "Updating Brewfile..." "$YELLOW"
    brew bundle dump --file="$DOTFILES_DIR/brew/Brewfile" --force
    print_success "Brewfile updated"
  else
    print_warning "Homebrew not installed, skipping Brewfile update"
  fi
  
  print_success "Dotfiles updated from system"
}

# Sync to GitHub
sync_to_github() {
  print_step "Syncing to GitHub"
  
  cd "$DOTFILES_DIR"
  
  # Check for changes
  if git diff --quiet && git diff --staged --quiet; then
    print_message "No changes to commit" "$YELLOW"
    return
  fi
  
  # Add all changes
  git add -A
  
  # Commit changes
  git commit -m "Update dotfiles: $(date +%Y-%m-%d)"
  
  # Push to GitHub
  git push
  
  print_success "Synced to GitHub"
}

# Main function
main() {
  print_message "\n🔄 Starting dotfiles sync...\n" "$GREEN"
  
  # Update dotfiles from system
  update_dotfiles
  
  # Sync to GitHub
  sync_to_github
  
  print_message "\n🎉 Dotfiles sync complete!\n" "$GREEN"
}

# Run the main function
main
