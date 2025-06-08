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
- File management tools (ripgrep, ranger, duf)
- Network monitoring tools (doggo, bandwhich, gping)

## Enhanced Tools

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

### Terminal Session Management

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
