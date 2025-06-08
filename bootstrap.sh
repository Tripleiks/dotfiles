#!/bin/sh
#
# bootstrap.sh
#
# This script symlinks dotfiles from this repository to your home directory
# using GNU Stow.

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
# Add the names of the directories (stow packages) you want to manage.
# For example, if you have ~/dotfiles/zsh/.zshrc and ~/dotfiles/vim/.vimrc,
# you would list "zsh" and "vim" here.
PACKAGES="zsh vim git tmux nvim" # Customize this list!

# --- Variables ---
DOTFILES_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
STOW_DIR="$HOME"
STOW_TARGET_DIR="$HOME" # Where stow will create the symlinks (usually $HOME)

# --- Helper Functions ---
msg() {
  printf '\n%s\n' "$1"
}

success() {
  printf '✅ %s\n' "$1"
}

error() {
  printf '❌ %s\n' "$1" >&2
  exit 1
}

# --- Pre-flight Checks ---
# Check if stow is installed
if ! command -v stow >/dev/null 2>&1;
  then
  error "GNU Stow is not installed. Please install it first (e.g., 'brew install stow')."
fi

# Check if we are in the dotfiles directory
if [ "$(pwd)" != "$DOTFILES_DIR" ]; then
  error "Please run this script from the root of your dotfiles directory: $DOTFILES_DIR"
fi

# --- Main Logic ---
msg "Symlinking dotfiles using GNU Stow..."

for pkg in $PACKAGES; do
  if [ -d "$pkg" ]; then
    msg "Stowing package: $pkg"
    stow --dir="$DOTFILES_DIR" --target="$STOW_TARGET_DIR" -R "$pkg"
    success "Package '$pkg' stowed successfully."
  else
    msg "Skipping package '$pkg': directory not found."
  fi
done

success "All specified dotfile packages have been processed."
msg "Remember to commit any changes to your dotfiles repository."
