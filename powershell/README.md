# Ultimate PowerShell Profile for macOS

A comprehensive PowerShell profile for macOS that integrates with dotfiles, automatically checks for required modules and CLI tools, and enhances the PowerShell experience with useful aliases and functions.

## Features

- **Automatic Module Installation**: Checks for and installs required PowerShell modules
- **CLI Tool Integration**: Detects and configures CLI tools installed via Homebrew
- **Dotfiles Integration**: Seamlessly integrates with the existing dotfiles system
- **Custom Aliases**: Provides aliases for common commands and tools
- **Enhanced UI**: Configures PSReadLine, Terminal-Icons, and Oh My Posh
- **Utility Functions**: Includes helpful functions for Git, navigation, and system management

## Installation

The PowerShell profile is automatically installed when you run the main dotfiles installation script:

```bash
./install.sh
```

This will:

1. Create the necessary directories
2. Symlink the PowerShell profile and scripts to the correct locations
3. Make the scripts executable

## Manual Installation

If you want to install only the PowerShell profile:

```bash
# Create the necessary directories
mkdir -p "$HOME/.config/powershell/Scripts"

# Symlink the PowerShell profile and scripts
ln -sf "$HOME/coding/github/dotfiles/powershell/Microsoft.PowerShell_profile.ps1" "$HOME/.config/powershell/Microsoft.PowerShell_profile.ps1"
ln -sf "$HOME/coding/github/dotfiles/powershell/Scripts/Install-RequiredModules.ps1" "$HOME/.config/powershell/Scripts/Install-RequiredModules.ps1"
ln -sf "$HOME/coding/github/dotfiles/powershell/Scripts/Install-CliTools.ps1" "$HOME/.config/powershell/Scripts/Install-CliTools.ps1"

# Make the scripts executable
chmod +x "$HOME/.config/powershell/Scripts/Install-RequiredModules.ps1" "$HOME/.config/powershell/Scripts/Install-CliTools.ps1"
```

## Usage

### First-Time Setup

When you first launch PowerShell, the profile will automatically load. To explicitly check for and install required modules and CLI tools:

```powershell
# Check and install required PowerShell modules and CLI tools
Initialize-PowerShellEnvironment
```

### Synchronization

To sync your PowerShell profile with the dotfiles repository:

```powershell
# Sync local profile to dotfiles repository and push changes
syncps

# Pull changes from dotfiles repository and sync to local profile
syncps -Pull
```

### Updating

To update PowerShell modules and Homebrew packages:

```powershell
# Update PowerShell modules
updatemodules

# Update Homebrew packages
brewup

# Update both PowerShell modules and Homebrew packages
updateall
```

## Included PowerShell Modules

| Module | Description |
|--------|-------------|
| PSReadLine | Enhanced command line editing |
| Terminal-Icons | File and folder icons |
| posh-git | Git integration |
| oh-my-posh | Prompt theming engine |
| z | Directory jumper |
| PSFzf | Fuzzy finder integration |
| Microsoft.PowerShell.ConsoleGuiTools | Out-GridView for terminal |

## CLI Tool Integrations

The profile includes integrations with the following CLI tools:

| Tool | Aliases | Description |
|------|---------|-------------|
| eza | ez, ll, la, lt, llt, lg, lsg, llg, lss, lsm | Modern ls replacement |
| bat | cat | Cat with syntax highlighting |
| ripgrep | grep, rg | Fast grep replacement |
| fd | fd | Fast find alternative |
| tealdeer | help | Simplified man pages |
| git-delta | gdiff | Syntax-highlighting pager for git |
| age | encrypt, decrypt | Simple file encryption tool |
| asciinema | rec, play, upload | Terminal session recorder |
| lazygit | lg | Terminal UI for git |
| gping | ping | Ping with graph |
| doggo | dig, dns | DNS client |
| bandwhich | bw | Network utilization tool |
| duf | du, df | Disk usage utility |
| ranger | fm | Terminal file manager |
| ncdu | ncdu | Disk usage analyzer |
| carbonyl | browse | Terminal web browser |

## Git Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| gst | git status | Show git status |
| ga | git add | Add files to staging |
| gitc | git commit | Commit changes |
| gitp | git push | Push changes to remote |
| gpl | git pull | Pull changes from remote |
| gitl | git log | Show git log |
| gb | git branch | List branches |
| gco | git checkout | Switch branches |
| gf | git fetch | Fetch changes from remote |
| gitm | git merge | Merge branches |

## Navigation Aliases

| Alias | Description |
|-------|-------------|
| .. | Go up one directory |
| ~ | Go to home directory |
| dotfiles | Go to dotfiles directory |

## System Aliases

| Alias | Description |
|-------|-------------|
| sysinfo | Display system information |
| syncps | Sync PowerShell profile with dotfiles repository |
| updatemodules | Update PowerShell modules |
| brewup | Update Homebrew packages |
| updateall | Update both PowerShell modules and Homebrew packages |

## Customization

You can customize the profile by editing the `Microsoft.PowerShell_profile.ps1` file in the `powershell` directory of your dotfiles repository. After making changes, sync them to your local profile:

```powershell
syncps -Pull
```

## License

This PowerShell profile is part of the dotfiles repository and is licensed under the same terms.
