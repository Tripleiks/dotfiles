#!/bin/bash

# Initialize Git repository for dotfiles
# This script sets up the Git repository for your dotfiles

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
DOTFILES_DIR="$HOME/dotfiles"
GITHUB_USER="" # You'll be prompted to enter this

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

# Initialize repository
init_repo() {
  print_step "Initializing Git repository"
  
  cd "$DOTFILES_DIR"
  
  # Initialize Git repository if not already initialized
  if [ ! -d ".git" ]; then
    git init
    print_success "Git repository initialized"
  else
    print_warning "Git repository already initialized"
  fi
  
  # Create .gitignore
  cat > .gitignore << EOL
.DS_Store
*.log
*.bak
*.tmp
*.swp
EOL
  print_success "Created .gitignore"
  
  # Make scripts executable
  chmod +x install.sh sync.sh
  print_success "Made scripts executable"
}

# Configure GitHub remote
configure_remote() {
  print_step "Configuring GitHub remote"
  
  # Prompt for GitHub username
  GITHUB_USER="Tripleiks"
  
  if [ -z "$GITHUB_USER" ]; then
    print_error "GitHub username cannot be empty"
    exit 1
  fi
  
  # Update GitHub username in install.sh
  sed -i.bak "s/GITHUB_USER=\"YOUR_USERNAME\"/GITHUB_USER=\"$GITHUB_USER\"/" install.sh
  rm -f install.sh.bak
  
  # Create repository on GitHub if it doesn't exist
  print_warning "Please create a repository named 'dotfiles' on GitHub if you haven't already"
  read -p "Press Enter to continue once you've created the repository..."
  
  # Add remote
  git remote remove origin 2>/dev/null || true
  git remote add origin "https://github.com/$GITHUB_USER/dotfiles.git"
  print_success "Added GitHub remote"
}

# Initial commit and push
initial_commit() {
  print_step "Creating initial commit"
  
  cd "$DOTFILES_DIR"
  
  # Add all files
  git add -A
  
  # Commit
  git commit -m "Initial dotfiles setup"
  
  # Push to GitHub
  print_message "Pushing to GitHub..." "$YELLOW"
  git push -u origin main || git push -u origin master
  
  print_success "Initial commit pushed to GitHub"
}

# Main function
main() {
  print_message "\n🚀 Setting up dotfiles repository...\n" "$GREEN"
  
  # Initialize repository
  init_repo
  
  # Configure GitHub remote
  configure_remote
  
  # Initial commit and push
  initial_commit
  
  print_message "\n🎉 Dotfiles repository setup complete!\n" "$GREEN"
  print_message "Your dotfiles are now ready to be installed on other machines using:" "$BLUE"
  print_message "curl -fsSL https://raw.githubusercontent.com/$GITHUB_USER/dotfiles/main/install.sh | bash\n" "$YELLOW"
}

# Run the main function
main
