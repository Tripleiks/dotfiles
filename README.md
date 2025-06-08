# Dotfiles

A personal dotfiles management system for zsh and PowerShell configuration, CLI tools, and terminal customization.

## Features

- Centralized management of zsh and PowerShell configuration files
- Automatic installation of CLI tools via Homebrew
- Nerd Fonts installation for proper icon rendering
- Oh My Posh with custom theme for beautiful prompts
- zsh-git-prompt for enhanced Git status information
- Easy setup on new machines with a single command
- Synchronization between machines with a simple `synchzsh` command
- Backup of existing configuration before installation
- Cross-platform compatibility (macOS and Linux)

## Installation

To install these dotfiles on a new machine:

```bash
curl -fsSL https://raw.githubusercontent.com/Tripleiks/dotfiles/main/install.sh | bash
```

Or if you've already cloned the repository:

```bash
cd ~/dotfiles
./install.sh
```

## What's Included

- zsh configuration (.zshrc, .zshenv, etc.)
- Oh My Zsh setup with custom themes and plugins
- Oh My Posh with custom theme (`my-quick-term.omp.json`)
- Nerd Fonts installation (FiraCode, Hack, JetBrainsMono, Meslo)
- Homebrew packages and casks
- Terminal preferences
- Git configuration
- Custom aliases and functions

## Customization

Edit the following files to customize your setup:

- `zsh/.zshrc` - Main zsh configuration
- `brew/Brewfile` - List of Homebrew packages to install
- `git/.gitconfig` - Git configuration

## Syncing Changes

After making changes to your dotfiles, run the convenient alias:

```bash
synchzsh
```

Or manually run the sync script:

```bash
./sync.sh
```

This will commit and push your changes to GitHub.

## Repository History

This dotfiles repository was created by merging two separate repositories on 2025-06-08.
