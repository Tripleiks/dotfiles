# Dotfiles

A personal dotfiles management system for zsh and PowerShell configuration, CLI tools, and terminal customization.

## Features

- Centralized management of zsh and PowerShell configuration files
- Automatic installation of CLI tools via Homebrew
- Nerd Fonts installation for proper icon rendering
- Starship prompt with custom theme for beautiful cross-shell prompts
- zsh-git-prompt for enhanced Git status information
- Ultimate PowerShell Profile for macOS with automatic dependency management
- Easy setup on new machines with a single command
- Synchronization between machines with simple `synchzsh` and `syncps` commands
- Backup of existing configuration before installation
- Cross-platform compatibility (macOS and Linux)

## Installation

### Prerequisites

- macOS or Linux
- Git (will be installed if not present)
- Homebrew (will be installed if not present on macOS)
- Internet connection for downloading dependencies

### Quick Install

To install these dotfiles on a new machine with a single command:

```bash
curl -fsSL https://raw.githubusercontent.com/Tripleiks/dotfiles/main/install.sh | bash
```

### Manual Install

If you prefer to review the code first or have already cloned the repository:

```bash
git clone https://github.com/Tripleiks/dotfiles.git ~/Coding/GitHub/dotfiles
cd ~/Coding/GitHub/dotfiles
./install.sh
```

### What Happens During Installation

The installation script will:

1. Back up any existing configuration files before replacing them
2. Install Homebrew (on macOS) if not already installed
3. Install Nerd Fonts for proper symbol rendering
4. Install Oh My Zsh and custom plugins
5. Install Starship prompt for both shells
6. Install required CLI tools via Homebrew
7. Set up PowerShell environment with modules and configurations
8. Create symbolic links for all configuration files
9. Configure Git with global settings

### Verification

After installation, you can verify everything is set up correctly by running:

```bash
./test-install.sh
```

## What's Included

- zsh configuration (.zshrc, .zshenv, etc.)
- PowerShell configuration with automatic module and CLI tool installation
- Oh My Zsh setup with custom plugins
- Starship prompt with custom theme (`starship.toml`) for both PowerShell and zsh
- Nerd Fonts installation (FiraCode, Hack, JetBrainsMono, Meslo)
- Homebrew packages and casks
- Terminal preferences
- Git configuration
- Custom aliases and functions
- File management tools (ripgrep, ranger, duf)
- Network monitoring tools (doggo, bandwhich, gping)
- Security tools (age encryption)

## Enhanced Tools

### PowerShell Profile

- **Ultimate PowerShell Profile** - Comprehensive PowerShell configuration for macOS
  - Automatically checks for and installs required PowerShell modules and CLI tools
  - Integrates with existing dotfiles synchronization system
  - Configures PSReadLine with syntax highlighting and command prediction
  - Uses Starship prompt with custom theme for beautiful cross-shell experience
  - Detects and warns if Nerd Fonts are not installed for proper symbol display
  - Provides aliases for all CLI tools consistent with zsh aliases
  - Includes utility functions for Git, navigation, and system management
  - Synchronization command `syncps` for keeping profile in sync with dotfiles repo
  - Profile reload functionality with duplicate message prevention

### Terminal Session Management

- **tmux** - Terminal multiplexer for managing multiple terminal sessions
  - Configured with custom `.tmux.conf` for improved keybindings and visuals
  - Prefix key changed from `Ctrl+B` to `Ctrl+A` for easier access
  - Aliases: `tmx` → `tmux`, `tn` → `tmux new -s`, `ta` → `tmux attach -t`, `tl` → `tmux list-sessions`, `tk` → `tmux kill-session -t`
  - Mouse mode enabled for easy pane/window selection
  - Vi mode for navigation and copy/paste

### Command History Tools

- **atuin** - Shell history tool with search, sync, and statistics
  - Configured to use up arrow key for history search
  - Stores history in a SQLite database with context
  - Fuzzy search enabled for better matching

- **mcfly** - Intelligent Ctrl+R replacement with context-aware suggestions
  - Configured with vim keybindings and TOP interface view
  - Learns from your command usage patterns
  - Shows 20 results with context-aware suggestions

### File Management Tools

- **ripgrep** (`rg`) - Lightning-fast search tool, better than grep
  - Configured with `.ripgreprc` for smart case, colored output, and web file type
  - Aliases: `grep` → `rg`, `rg` → `rg`

- **ranger** - Terminal file manager with vim-like keybindings
  - Configured with custom `rc.conf` for better visuals and functionality
  - Alias: `fm` → `ranger`

- **duf** - User-friendly disk usage utility with colored output
  - Aliases: `du` → `duf`, `df` → `duf`

- **ncdu** - NCurses Disk Usage analyzer with interactive interface
  - Alias: `ncdu` → `ncdu --color dark`
  - Navigate with arrow keys, delete with `d`, quit with `q`

### Network Monitoring Tools

- **doggo** - Modern DNS client for querying DNS records
  - Aliases: `dig` → `doggo`, `dns` → `doggo`

- **bandwhich** - Terminal bandwidth utilization tool
  - Alias: `bw` → `sudo bandwhich`

- **gping** - Ping with a graph
  - Alias: `ping` → `gping`

- **carbonyl** - Terminal web browser based on Chromium
  - Alias: `browse` → `carbonyl`
  - Full HTML5, CSS3, and JavaScript support in the terminal

- **tealdeer** - Simplified and community-driven man pages with practical examples
  - Alias: `help` → `tldr`

- **asciinema** - Terminal session recorder
  - Aliases: `rec` → `asciinema rec`, `play` → `asciinema play`, `upload` → `asciinema upload`
  - Record, replay, and share terminal sessions

- **age** - Simple, modern file encryption tool
  - Aliases: `encrypt` → `age-encrypt`, `decrypt` → `age-decrypt`
  - Secure file encryption with public/private keys or passphrases

- **delta** - Syntax-highlighting pager for git and diff output
  - Alias: `gdiff` → `git diff | delta`
  - Side-by-side diffs with syntax highlighting and improved readability

## CLI Tools Quick Reference

A quick reference guide for the most commonly used commands and aliases:

### File Management

| Alias | Command | Description |
|-------|---------|-------------|
| `grep` | `rg --smart-case` | Search text with ripgrep |
| `rg` | `rg --smart-case` | Search text with ripgrep |
| `fm` | `ranger` | Open ranger file manager |
| `du` | `duf` | Display disk usage |
| `df` | `duf` | Display filesystem information |
| `ncdu` | `ncdu --color dark` | Interactive disk usage analyzer |

### Network Tools

| Alias | Command | Description |
|-------|---------|-------------|
| `dig` | `doggo` | Query DNS records |
| `dns` | `doggo` | Query DNS records |
| `bw` | `sudo bandwhich` | Monitor bandwidth usage |
| `ping` | `gping` | Ping with graphical output |
| `browse` | `carbonyl` | Browse the web in terminal |

### Terminal Management

| Alias | Command | Description |
|-------|---------|-------------|
| `tmx` | `tmux` | Start tmux session |
| `tn` | `tmux new -s` | Create new named session |
| `ta` | `tmux attach -t` | Attach to existing session |
| `tl` | `tmux list-sessions` | List all sessions |
| `tk` | `tmux kill-session -t` | Kill a specific session |

### Command History

| Key | Tool | Description |
|-----|------|-------------|
| `↑` (Up Arrow) | atuin | Search command history with context |
| `Ctrl+R` | mcfly | Fuzzy search command history |

### Git Tools

| Alias | Command | Description |
|-------|---------|-------------|
| `lg` | `lazygit` | Open LazyGit terminal UI |
| `gdiff` | `git diff \| delta` | Enhanced git diff with syntax highlighting |

### File Navigation

| Command | Description |
|---------|-------------|
| `z` | Jump to frequently used directory (zoxide) |
| `cd -` | Go to previous directory |

### Documentation Tools

| Alias | Command | Description |
|-------|---------|-------------|
| `help` | `tldr` | Show simplified command examples |

### Recording Tools

| Alias | Command | Description |
|-------|---------|-------------|
| `rec` | `asciinema rec` | Record terminal session |
| `play` | `asciinema play` | Play recorded terminal session |
| `upload` | `asciinema upload` | Upload recording to asciinema.org |

### Security Tools

| Alias | Command | Description |
|-------|---------|-------------|
| `encrypt` | `age-encrypt` | Encrypt files using age |
| `decrypt` | `age-decrypt` | Decrypt files using age |

### PowerShell Tools

| Alias | Command | Description |
|-------|---------|-------------|
| `syncps` | `Sync-PowerShellProfile` | Sync PowerShell profile with dotfiles repo |
| `updatemodules` | `Update-AllModules` | Update PowerShell modules |
| `brewup` | `Update-HomebrewPackages` | Update Homebrew packages |
| `updateall` | `Update-AllPackages` | Update both modules and Homebrew packages |
| `sysinfo` | `Get-SystemInfo` | Display system information |

## Configuration Files

Edit the following files to customize your setup:

- `zsh/.zshrc` - Main zsh configuration
- `brew/Brewfile` - List of Homebrew packages to install
- `git/.gitconfig` - Git configuration
- `ripgrep/.ripgreprc` - ripgrep configuration
- `ranger/.config/ranger/rc.conf` - ranger configuration

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
