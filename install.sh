#!/bin/bash

# Dotfiles Installation Script
# This script installs the dotfiles and sets up a new machine

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
DOTFILES_DIR="$HOME/dotfiles"
BACKUP_DIR="$DOTFILES_DIR/backup/$(date +%Y%m%d_%H%M%S)"
GITHUB_USER="Tripleiks" # Change this to your GitHub username
GITHUB_REPO="dotfiles"

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

# Backup existing file
backup_file() {
  if [ -e "$1" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "${1#$HOME/}")"
    cp -R "$1" "$BACKUP_DIR/${1#$HOME/}"
    print_success "Backed up $1"
  fi
}

# Create symbolic link
create_symlink() {
  local source="$1"
  local target="$2"
  
  # Backup existing file
  if [ -e "$target" ]; then
    backup_file "$target"
    rm -rf "$target"
  fi
  
  # Create parent directory if it doesn't exist
  mkdir -p "$(dirname "$target")"
  
  # Create symlink
  ln -sf "$source" "$target"
  print_success "Linked $source to $target"
}

# Clone or update repository
clone_or_update_repo() {
  if [ ! -d "$DOTFILES_DIR" ]; then
    print_step "Cloning dotfiles repository"
    git clone "https://github.com/$GITHUB_USER/$GITHUB_REPO.git" "$DOTFILES_DIR"
    print_success "Cloned dotfiles repository"
  elif [ -d "$DOTFILES_DIR/.git" ]; then
    print_step "Updating dotfiles repository"
    cd "$DOTFILES_DIR"
    git pull
    print_success "Updated dotfiles repository"
  else
    print_error "Directory $DOTFILES_DIR exists but is not a git repository"
    exit 1
  fi
}

# Install Homebrew if not already installed
install_homebrew() {
  print_step "Checking for Homebrew"
  if ! command_exists brew; then
    print_message "Installing Homebrew..." "$YELLOW"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH based on platform
    if [[ "$OSTYPE" == "darwin"* ]]; then
      # macOS
      if [[ $(uname -m) == "arm64" ]]; then
        # M1/M2 Mac
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
        eval "$(/opt/homebrew/bin/brew shellenv)"
      else
        # Intel Mac
        echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "$HOME/.zprofile"
        eval "$(/usr/local/bin/brew shellenv)"
      fi
    else
      # Linux
      echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
      eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
    
    print_success "Homebrew installed"
  else
    print_success "Homebrew already installed"
  fi
}

# Install packages from Brewfile
install_packages() {
  print_step "Installing packages from Brewfile"
  
  if ! command_exists brew; then
    print_error "Homebrew is not installed"
    exit 1
  fi
  
  # Install Homebrew Bundle
  brew tap Homebrew/bundle
  
  # Install from Brewfile
  cd "$DOTFILES_DIR/brew"
  brew bundle
  
  print_success "Packages installed"
}

# Install Nerd Fonts
install_nerd_fonts() {
  print_step "Installing Nerd Fonts"
  
  # List of Nerd Fonts to install
  NERD_FONTS=("FiraCode" "Hack" "JetBrainsMono" "Meslo")
  
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS - use Homebrew
    if ! command_exists brew; then
      print_error "Homebrew is not installed, cannot install fonts"
      return 1
    fi
    
    # Tap the fonts cask
    brew tap homebrew/cask-fonts
    
    # Check and install each font
    for font in "${NERD_FONTS[@]}"; do
      font_package="font-${font,,}-nerd-font"
      
      # Check if font is installed
      if brew list --cask "$font_package" &>/dev/null; then
        print_success "$font Nerd Font already installed"
      else
        print_message "Installing $font Nerd Font..." "$YELLOW"
        brew install --cask "$font_package"
        print_success "$font Nerd Font installed"
      fi
    done
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux - download and install manually
    FONT_DIR="$HOME/.local/share/fonts"
    mkdir -p "$FONT_DIR"
    
    for font in "${NERD_FONTS[@]}"; do
      # Check if font directory exists
      if [ -d "$FONT_DIR/$font" ]; then
        print_success "$font Nerd Font already installed"
      else
        print_message "Installing $font Nerd Font..." "$YELLOW"
        
        # Create temporary directory
        TMP_DIR=$(mktemp -d)
        
        # Download and extract font
        curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$font.zip" -o "$TMP_DIR/$font.zip"
        mkdir -p "$FONT_DIR/$font"
        unzip -q "$TMP_DIR/$font.zip" -d "$FONT_DIR/$font"
        
        # Clean up
        rm -rf "$TMP_DIR"
        
        print_success "$font Nerd Font installed"
      fi
    done
    
    # Update font cache
    if command_exists fc-cache; then
      fc-cache -f -v
    fi
  else
    print_warning "Unsupported OS for automatic font installation"
    print_message "Please install Nerd Fonts manually from: https://www.nerdfonts.com/" "$YELLOW"
  fi
  
  print_message "\nNerd Fonts installed. Make sure to configure your terminal to use one of these fonts." "$GREEN"
  print_message "Recommended font: FiraCode Nerd Font" "$YELLOW"
}

# Install Oh My Zsh and Oh My Posh
install_oh_my_zsh_and_posh() {
  print_step "Installing Oh My Zsh"
  
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    print_message "Installing Oh My Zsh..." "$YELLOW"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    print_success "Oh My Zsh installed"
  else
    print_success "Oh My Zsh already installed"
  fi
  
  # Install custom plugins
  ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
  
  # zsh-syntax-highlighting
  if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    print_success "Installed zsh-syntax-highlighting"
  fi
  
  # zsh-autosuggestions
  if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    print_success "Installed zsh-autosuggestions"
  fi
  
  # powerlevel10k theme
  if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
    print_success "Installed powerlevel10k theme"
  fi
  
  # Install Oh My Posh
  print_step "Installing Oh My Posh"
  if ! command_exists oh-my-posh; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
      # macOS
      brew install jandedobbeleer/oh-my-posh/oh-my-posh
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
      # Linux
      curl -s https://ohmyposh.dev/install.sh | bash -s
    fi
    print_success "Oh My Posh installed"
  else
    print_success "Oh My Posh already installed"
  fi
  
  # Set up Oh My Posh custom theme
  mkdir -p "$HOME/.config/oh-my-posh/themes"
  cp -f "$DOTFILES_DIR/oh-my-posh/themes/my-quick-term.omp.json" "$HOME/.config/oh-my-posh/themes/"
  print_success "Oh My Posh custom theme installed"
}

# Link dotfiles
link_dotfiles() {
  print_step "Linking dotfiles"
  
  # ZSH files
  create_symlink "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
  create_symlink "$DOTFILES_DIR/zsh/.zshenv" "$HOME/.zshenv"
  create_symlink "$DOTFILES_DIR/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
  
  # Git configuration
  create_symlink "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
  create_symlink "$DOTFILES_DIR/git/.gitignore_global" "$HOME/.gitignore_global"
  
  # Ripgrep configuration
  create_symlink "$DOTFILES_DIR/ripgrep/.ripgreprc" "$HOME/.ripgreprc"
  
  # Ranger configuration
  mkdir -p "$HOME/.config/ranger"
  create_symlink "$DOTFILES_DIR/ranger/.config/ranger/rc.conf" "$HOME/.config/ranger/rc.conf"
  
  # Tmux configuration
  create_symlink "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
  
  # Atuin configuration
  mkdir -p "$HOME/.config/atuin"
  create_symlink "$DOTFILES_DIR/atuin/.config/atuin/config.toml" "$HOME/.config/atuin/config.toml"
  
  # McFly configuration
  mkdir -p "$HOME/.config"
  create_symlink "$DOTFILES_DIR/mcfly/.mcfly.toml" "$HOME/.mcfly.toml"
  
  # Asciinema configuration
  mkdir -p "$HOME/.config/asciinema"
  create_symlink "$DOTFILES_DIR/asciinema/config" "$HOME/.config/asciinema/config"
  
  # Git Delta configuration
  create_symlink "$DOTFILES_DIR/git/.gitconfig-delta" "$HOME/.gitconfig-delta"
  
  # Age encryption helper scripts
  mkdir -p "$HOME/.local/bin"
  create_symlink "$DOTFILES_DIR/age/encrypt.sh" "$HOME/.local/bin/age-encrypt"
  create_symlink "$DOTFILES_DIR/age/decrypt.sh" "$HOME/.local/bin/age-decrypt"
  chmod +x "$HOME/.local/bin/age-encrypt" "$HOME/.local/bin/age-decrypt"
  
  print_success "Dotfiles linked"
}

# Run custom scripts
run_custom_scripts() {
  print_step "Running custom scripts"
  
  # Run all scripts in the scripts directory
  for script in "$DOTFILES_DIR/scripts"/*.sh; do
    if [ -f "$script" ]; then
      print_message "Running $(basename "$script")..." "$YELLOW"
      bash "$script"
      print_success "Completed $(basename "$script")"
    fi
  done
}

# Main installation process
main() {
  print_message "\n🚀 Starting dotfiles installation...\n" "$GREEN"
  
  # Create backup directory
  mkdir -p "$BACKUP_DIR"
  
  # If script is run via curl, clone the repository first
  if [ "$DOTFILES_DIR" != "$PWD" ] && [ ! -d "$DOTFILES_DIR" ]; then
    clone_or_update_repo
  fi
  
  # Install Homebrew
  install_homebrew
  
  # Install Nerd Fonts (required for Oh My Posh and terminal icons)
  install_nerd_fonts
  
  # Install Oh My Zsh and Oh My Posh
  install_oh_my_zsh_and_posh
  
  # Install packages
  install_packages
  
  # Link dotfiles
  link_dotfiles
  
  # Run custom scripts
  run_custom_scripts
  
  print_message "\n🎉 Dotfiles installation complete! Please restart your terminal.\n" "$GREEN"
}

# Run the main function
main
