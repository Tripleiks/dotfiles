#Requires -Version 7.0

<#
.SYNOPSIS
    Ultimate PowerShell Profile for macOS
.DESCRIPTION
    A comprehensive PowerShell profile for macOS that integrates with dotfiles,
    automatically checks for required modules and CLI tools, and enhances the
    PowerShell experience with useful aliases and functions.
.NOTES
    Author: Heino
    Date: 2025-06-09
#>

# Initialize profile load counter to prevent duplicate messages
# This is especially important for terminals like Warp that may load the profile multiple times
if (-not (Test-Path variable:global:ProfileLoadCount)) {
    $global:ProfileLoadCount = 0
}
$global:ProfileLoadCount++

#region Variables and Helper Functions
# Colors for output
$colors = @{
    Success = "Green"
    Info = "Cyan"
    Warning = "Yellow"
    Error = "Red"
    Emphasis = "Magenta"
}

# Helper functions that need to be defined early
function Write-ColorMessage {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [string]$ForegroundColor = "White"
    )
    
    Write-Host $Message -ForegroundColor $ForegroundColor
}

function Test-Command {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Command
    )
    
    try {
        if ($IsWindows) {
            $null = Get-Command $Command -ErrorAction Stop
        }
        else {
            $null = bash -c "command -v $Command" 2>$null
        }
        return $true
    }
    catch {
        return $false
    }
}

# Set variables
$DOTFILES_DIR = "$HOME/coding/github/dotfiles"
$SCRIPTS_DIR = "$DOTFILES_DIR/powershell/Scripts"
$MODULES_DIR = "$DOTFILES_DIR/powershell/Modules"
# Starship config path - ensure it's correctly set
$env:STARSHIP_CONFIG = "$HOME/.config/starship.toml"

# Verify the config file exists, if not copy from dotfiles
if (-not (Test-Path $env:STARSHIP_CONFIG)) {
    $starshipConfigDir = Split-Path -Parent $env:STARSHIP_CONFIG
    if (-not (Test-Path $starshipConfigDir)) {
        New-Item -Path $starshipConfigDir -ItemType Directory -Force | Out-Null
    }
    Copy-Item "$DOTFILES_DIR/starship/starship.toml" -Destination $env:STARSHIP_CONFIG -Force
}

# Note: Using built-in $IsWindows, $IsMacOS, and $IsLinux automatic variables

# Set up CLI tool paths for consistent access across all environments
function Set-CliToolPaths {
    # Add Homebrew paths to PATH if they exist
    $homebrewPaths = @(
        "/opt/homebrew/bin",
        "/opt/homebrew/sbin",
        "/usr/local/bin",
        "/usr/local/sbin"
    )

    foreach ($path in $homebrewPaths) {
        if (Test-Path $path) {
            if (-not $env:PATH.Contains($path)) {
                $env:PATH = "$path" + [IO.Path]::PathSeparator + $env:PATH
            }
        }
    }

    # Define CLI tool paths
    $cliToolPaths = @{
        # File and directory tools
        "eza" = "/opt/homebrew/bin/eza"
        "bat" = "/opt/homebrew/bin/bat"
        "rg" = "/opt/homebrew/bin/rg"
        "fd" = "/opt/homebrew/bin/fd"
        "jq" = "/usr/bin/jq"
        "delta" = "/opt/homebrew/bin/delta"
        "ranger" = "/opt/homebrew/bin/ranger"
        "fzf" = "/opt/homebrew/bin/fzf"
        "yazi" = "/opt/homebrew/bin/yazi"
        "zoxide" = "/opt/homebrew/bin/zoxide"
        # System monitoring tools
        "btop" = "/opt/homebrew/bin/btop"
        "gping" = "/opt/homebrew/bin/gping"
        "doggo" = "/opt/homebrew/bin/doggo"
        "bandwhich" = "/opt/homebrew/bin/bandwhich"
        "duf" = "/opt/homebrew/bin/duf"
        "ncdu" = "/opt/homebrew/bin/ncdu"
        "neofetch" = "/opt/homebrew/bin/neofetch"
        "fastfetch" = "/opt/homebrew/bin/fastfetch"
        "cmatrix" = "/opt/homebrew/bin/cmatrix"
        "figlet" = "/opt/homebrew/bin/figlet"
        # Utility tools
        "age" = "/opt/homebrew/bin/age"
        "tldr" = "/opt/homebrew/bin/tldr"
        "asciinema" = "/opt/homebrew/bin/asciinema"
        "lazygit" = "/opt/homebrew/bin/lazygit"
        "thefuck" = "/opt/homebrew/bin/thefuck"
        "atuin" = "/opt/homebrew/bin/atuin"
        "mcfly" = "/opt/homebrew/bin/mcfly"
        "starship" = "/opt/homebrew/bin/starship"
        "go" = "/opt/homebrew/bin/go"
        "node" = "/opt/homebrew/bin/node"
        "npm" = "/opt/homebrew/bin/npm"
        "python3" = "/opt/homebrew/bin/python3"
        "pip3" = "/opt/homebrew/bin/pip3"
    }

    # Add CLI tool paths to PATH if they exist
    foreach ($tool in $cliToolPaths.Keys) {
        $path = $cliToolPaths[$tool]
        if (Test-Path $path) {
            $directory = Split-Path -Parent $path
            if (-not $env:PATH.Contains($directory)) {
                $env:PATH = "$directory" + [IO.Path]::PathSeparator + $env:PATH
                # Try to find the tool in Homebrew paths
                foreach ($path in $homebrewPaths) {
                    $fullPath = Join-Path $path $Tool
                    if (Test-Path $fullPath) {
                        # Update the path in our dictionary for future use
                        $cliToolPaths[$Tool] = $fullPath
                        & $fullPath @Arguments
                        return $true
                    }
                }
            }
        }
        
        # Fallback to regular command if full path doesn't exist
        if (Test-Command $Tool) {
            & $Tool @Arguments
            return $true
        } else {
            Write-ColorMessage "[WARNING] Tool '$Tool' not found in PATH" $colors.Warning
            return $false
        }
    }
    
    if ($global:ProfileLoadCount -eq 1) {
        Write-ColorMessage "[INFO] CLI tool paths configured for consistent access across all environments" $colors.Info
    }
}

# Add custom modules directory to PSModulePath if it exists
if (Test-Path $MODULES_DIR) {
    $env:PSModulePath = "$MODULES_DIR" + [IO.Path]::PathSeparator + $env:PSModulePath
}

# Colors for output
$colors = @{
    Success = "Green"
    Info = "Cyan"
    Warning = "Yellow"
    Error = "Red"
    Emphasis = "Magenta"
}
#endregion

#region Additional Helper Functions

function Get-Greeting {
    $hour = (Get-Date).Hour
    
    if ($hour -lt 12) {
        return "Good morning"
    }
    elseif ($hour -lt 18) {
        return "Good afternoon"
    }
    else {
        return "Good evening"
    }
}

function Invoke-SyncPowerShellProfile {
    param(
        [switch]$Force
    )
    
    $sourceProfile = "$DOTFILES_DIR/powershell/Microsoft.PowerShell_profile.ps1"
    $targetProfile = "$HOME/.config/powershell/Microsoft.PowerShell_profile.ps1"
    
    if (-not (Test-Path $sourceProfile)) {
        Write-ColorMessage "❌ Source profile not found: $sourceProfile" $colors.Error
        return
    }
    
    # Create target directory if it doesn't exist
    $targetDir = Split-Path -Parent $targetProfile
    if (-not (Test-Path $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    }
    
    # Backup existing profile if it exists
    if ((Test-Path $targetProfile) -and (-not $Force)) {
        $backupFile = "$targetProfile.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Copy-Item -Path $targetProfile -Destination $backupFile
        Write-ColorMessage "✅ Backed up existing profile to: $backupFile" $colors.Success
    }
    
    # Copy profile
    Copy-Item -Path $sourceProfile -Destination $targetProfile -Force
    Write-ColorMessage "✅ PowerShell profile synced to: $targetProfile" $colors.Success
    
    # Copy scripts
    $targetScriptsDir = "$HOME/.config/powershell/Scripts"
    if (-not (Test-Path $targetScriptsDir)) {
        New-Item -ItemType Directory -Path $targetScriptsDir -Force | Out-Null
    }
    
    Copy-Item -Path "$SCRIPTS_DIR/*" -Destination $targetScriptsDir -Recurse -Force
    Write-ColorMessage "✅ PowerShell scripts synced to: $targetScriptsDir" $colors.Success
}
#endregion
#region Module and CLI Tool Installation
function Initialize-PowerShellEnvironment {
    param(
        [switch]$Force,
        [switch]$Quiet
    )
    
    # Check and install required PowerShell modules
    $modulesScript = "$SCRIPTS_DIR/Install-RequiredModules.ps1"
    if (Test-Path $modulesScript) {
        try {
            & $modulesScript -Force:$Force -Quiet:$Quiet
        }
        catch {
            Write-ColorMessage "❌ Error installing PowerShell modules: $_" $colors.Error
        }
    }
    else {
        Write-ColorMessage "⚠️ Module installation script not found: $modulesScript" $colors.Warning
    }
    
    # Check and install required CLI tools
    $cliToolsScript = "$SCRIPTS_DIR/Install-CliTools.ps1"
    if (Test-Path $cliToolsScript) {
        try {
            & $cliToolsScript -Force:$Force -Quiet:$Quiet
        }
        catch {
            Write-ColorMessage "❌ Error installing CLI tools: $_" $colors.Error
        }
    }
    else {
        Write-ColorMessage "⚠️ CLI tools installation script not found: $cliToolsScript" $colors.Warning
    }
    
    # Check and install M365 and Azure modules
    $m365AzureScript = "$SCRIPTS_DIR/Install-M365AzureModules.ps1"
    if (Test-Path $m365AzureScript) {
        try {
            & $m365AzureScript -Force:$Force -Quiet:$Quiet
        }
        catch {
            Write-ColorMessage "❌ Error installing M365 and Azure modules: $_" $colors.Error
        }
    }
    else {
        Write-ColorMessage "⚠️ M365 and Azure modules installation script not found: $m365AzureScript" $colors.Warning
    }
    
    # Check and install additional modules
    $additionalModulesScript = "$SCRIPTS_DIR/Install-AdditionalModules.ps1"
    if (Test-Path $additionalModulesScript) {
        try {
            & $additionalModulesScript -Force:$Force -Quiet:$Quiet
        }
        catch {
            Write-ColorMessage "❌ Error installing additional modules: $_" $colors.Error
        }
    }
    else {
        Write-ColorMessage "⚠️ Additional modules installation script not found: $additionalModulesScript" $colors.Warning
    }
    
    # Sync PowerShell Script Repository
    $syncRepoScript = "$SCRIPTS_DIR/Sync-PowerShellRepository.ps1"
    if (Test-Path $syncRepoScript) {
        try {
            & $syncRepoScript -Force:$Force -Quiet:$Quiet
        }
        catch {
            Write-ColorMessage "❌ Error syncing PowerShell Repository: $_" $colors.Error
        }
    }
    else {
        Write-ColorMessage "⚠️ PowerShell Repository sync script not found: $syncRepoScript" $colors.Warning
    }
}
#endregion

#region Module Imports and Configuration
# Import required modules if available
$requiredModules = @(
    # PSReadLine is handled separately to avoid version conflicts
    @{ Name = "posh-git"; MinVersion = "1.0.0" },
    @{ Name = "z"; MinVersion = "1.1.13" },
    @{ Name = "PSFzf"; MinVersion = "2.0.0" }
)

# Special handling for PSReadLine to avoid version conflicts
# PSReadLine is usually already loaded by PowerShell itself
if (-not (Get-Module -Name PSReadLine)) {
    try {
        # Only try to import if not already loaded
        Import-Module PSReadLine -DisableNameChecking -ErrorAction Stop
    }
    catch {
        if ($global:ProfileLoadCount -eq 1) {
            Write-ColorMessage "⚠️ PSReadLine not available: $($_.Exception.Message)" $colors.Warning
        }
    }
}

# Special handling for fzf binary path before importing PSFzf
if ($IsMacOS) {
    # Ensure fzf binary path is in the environment
    $fzfPath = "/opt/homebrew/bin/fzf"
    if (Test-Path $fzfPath) {
        # Set FZF_DEFAULT_COMMAND for better file finding
        $env:FZF_DEFAULT_COMMAND = 'fd --type file --follow --hidden --exclude .git'
        # Set environment variable for PSFzf module
        $env:PSFZF_FZF_PATH = $fzfPath
        
        # Add fzf directory to PATH if not already there
        $fzfDir = Split-Path -Parent $fzfPath
        if (-not $env:PATH.Contains($fzfDir)) {
            $env:PATH = "$fzfDir" + [IO.Path]::PathSeparator + $env:PATH
        }
        
        # Create a symlink to fzf in a directory that's definitely in PATH
        # This helps with terminals like Warp that might have PATH issues
        $localBinPath = "$HOME/.local/bin"
        if (-not (Test-Path $localBinPath)) {
            New-Item -ItemType Directory -Path $localBinPath -Force | Out-Null
        }
        
        # Add local bin to PATH if not already there
        if (-not $env:PATH.Contains($localBinPath)) {
            $env:PATH = "$localBinPath" + [IO.Path]::PathSeparator + $env:PATH
        }
    }
}

# Import other modules
foreach ($module in $requiredModules) {
    $moduleName = $module.Name
    
    # Special handling for PSFzf module
    if ($moduleName -eq "PSFzf") {
        # Only try to import PSFzf if fzf is available
        $fzfCommand = Get-Command fzf -ErrorAction SilentlyContinue
        if ($fzfCommand) {
            # fzf is in PATH, try to import PSFzf
            try {
                if (-not (Get-Module -Name PSFzf)) {
                    Import-Module PSFzf -DisableNameChecking -ErrorAction Stop
                    if ($global:ProfileLoadCount -eq 1) {
                        Write-ColorMessage "[INFO] PSFzf loaded with fzf from: $($fzfCommand.Source)" $colors.Success
                    }
                }
            } catch {
                if ($global:ProfileLoadCount -eq 1) {
                    Write-ColorMessage "⚠️ Failed to import PSFzf module: $($_.Exception.Message)" $colors.Warning
                }
            }
        } else {
            # Only show this message once
            if ($global:ProfileLoadCount -eq 1) {
                Write-ColorMessage "⚠️ Skipping PSFzf module: fzf binary not found in PATH" $colors.Warning
                Write-ColorMessage "   Install fzf with: brew install fzf" $colors.Info
            }
        }
        continue  # Skip to next module
    }
    
    # Standard handling for other modules
    try {
        # Check if module is available
        $moduleAvailable = Get-Module -ListAvailable -Name $moduleName -ErrorAction SilentlyContinue
        
        if ($moduleAvailable) {
            # Import module normally
            Import-Module $moduleName -DisableNameChecking -ErrorAction Stop
        }
        else {
            # Module doesn't exist, try to install it if we're not in a restricted environment
            if ($global:ProfileLoadCount -eq 1) {
                Write-ColorMessage "Module $moduleName not found. Attempting to install..." $colors.Warning
                try {
                    Install-Module -Name $moduleName -Force -AllowClobber -Scope CurrentUser -ErrorAction Stop
                    Import-Module $moduleName -DisableNameChecking -ErrorAction Stop
                    Write-ColorMessage "✅ Successfully installed and imported $moduleName" $colors.Success
                }
                catch {
                    Write-ColorMessage "⚠️ Failed to install module: $moduleName. Run Install-RequiredModules.ps1 manually." $colors.Warning
                }
            }
        }
    }
    catch {
        # Only show error messages on first profile load
        if ($global:ProfileLoadCount -eq 1) {
            Write-ColorMessage "⚠️ Failed to import module: $moduleName - $($_.Exception.Message)" $colors.Warning
        }
    }
}

# Configure PSReadLine if available
if (Get-Module -Name PSReadLine) {
    # PSReadLine settings
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -EditMode Emacs
    Set-PSReadLineOption -BellStyle None
    
    # Custom key bindings
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Key Tab -Function Complete
    
    # Custom colors
    Set-PSReadLineOption -Colors @{
        Command = 'Cyan'
        Parameter = 'DarkCyan'
        Operator = 'DarkGreen'
        Variable = 'DarkGreen'
        String = 'DarkYellow'
        Number = 'DarkGreen'
        Type = 'DarkGray'
        Comment = 'DarkGray'
    }
    
    # Only show PSReadLine message on first load
    if ($global:ProfileLoadCount -eq 1) {
        Write-ColorMessage "[INFO] PSReadLine loaded and configured with custom colors." $colors.Info
    }
}

# Note: We're using eza's built-in icons instead of Terminal-Icons for a more consistent experience
# Only show icons message on first load
if ($global:ProfileLoadCount -eq 1) {
    Write-ColorMessage "[INFO] Using eza's built-in icons for file listings." $colors.Info
}

# Configure Starship prompt
$starshipPath = "/opt/homebrew/bin/starship"

# Function to check if a Nerd Font is likely being used
function Test-NerdFont {
    # Test character that should only render properly with a Nerd Font
    $nerdFontTestChar = ""
    Write-Host "Testing if your terminal supports Nerd Font symbols: $nerdFontTestChar" -NoNewline
    
    # Prompt user to confirm if they can see the symbol
    Write-Host " - If you can see a folder icon above, press Enter. If not, type 'no': " -NoNewline -ForegroundColor Yellow
    $response = Read-Host
    
    if ($response -eq "no") {
        return $false
    }
    return $true
}

if (Test-Path $starshipPath) {
    # Use full path to ensure it works in all environments (including Warp)
    & $starshipPath init powershell | Invoke-Expression
    
    # Only show initialization message on first load
    if ($global:ProfileLoadCount -eq 1) {
        Write-ColorMessage "[INFO] Starship prompt initialized with config: $env:STARSHIP_CONFIG" $colors.Info
    }
    
    # Check if Nerd Font is being used (only on first run in a session)
    $markerFile = "$HOME/.config/powershell/.nerd_font_checked"
    if (-not (Test-Path $markerFile)) {
        $nerdFontEnabled = Test-NerdFont
        if (-not $nerdFontEnabled) {
            Write-ColorMessage "[WARNING] Your terminal doesn't appear to be using a Nerd Font. Starship's symbols may not display correctly." $colors.Warning
            Write-ColorMessage "[TIP] Install a Nerd Font from https://www.nerdfonts.com and configure your terminal to use it." $colors.Info
        } else {
            Write-ColorMessage "[INFO] Nerd Font detected. Starship symbols should display correctly." $colors.Success
        }
        # Create marker file so we don't check on every new PowerShell instance
        try {
            New-Item -Path $markerFile -ItemType File -Force -ErrorAction Stop | Out-Null
        } catch {
            Write-ColorMessage "[NOTE] Could not create Nerd Font check marker file: $_" $colors.Warning
        }
    }
} elseif (Test-Command "starship") {
    # Use command if available
    Invoke-Expression (&starship init powershell)
    
    # Only show initialization message on first load
    if ($global:ProfileLoadCount -eq 1) {
        Write-ColorMessage "[INFO] Starship prompt initialized with config: $env:STARSHIP_CONFIG" $colors.Info
    }
} else {
    # Prompt if starship is not installed
    Write-ColorMessage "[WARNING] Starship executable not found. Install it with: brew install starship" $colors.Warning
}

# Configure z (directory jumper) if available
if (Get-Module -Name z) {
    $env:_Z_DATA = "$HOME/.z"
    $env:_Z_OWNER = $env:USER
}

# Configure PSFzf if available
if (Get-Module -Name PSFzf) {
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
}
#endregion
#region CLI Tool Integrations
# Configure Eza integration if available
if (Test-Command "eza") {
    function Get-ChildItemEza {
        param(
            [Parameter(ValueFromRemainingArguments=$true)]
            $Remaining
        )
        
        Use-CliTool "eza" --icons $Remaining
    }
    
    function Get-ChildItemEzaLong {
        param(
            [Parameter(ValueFromRemainingArguments=$true)]
            $Remaining
        )
        
        Use-CliTool "eza" --icons --long --header $Remaining
    }
    
    function Get-ChildItemEzaAll {
        param(
            [Parameter(ValueFromRemainingArguments=$true)]
            $Remaining
        )
        
        Use-CliTool "eza" --icons --long --header --git --all $Remaining
    }
    
    function Get-ChildItemEzaTree {
        param(
            [Parameter(ValueFromRemainingArguments=$true)]
            $Remaining
        )
        
        Use-CliTool "eza" --icons --tree $Remaining
    }
    
    function Get-ChildItemEzaTreeLong {
        param(
            [Parameter(ValueFromRemainingArguments=$true)]
            $Remaining
        )
        
        Use-CliTool "eza" --icons --tree --long --header --git $Remaining
    }
    
    function Get-ChildItemEzaGrid {
        param(
            [Parameter(ValueFromRemainingArguments=$true)]
            $Remaining
        )
        
        Use-CliTool "eza" --icons --grid $Remaining
    }
    
    function Get-ChildItemEzaGit {
        param(
            [Parameter(ValueFromRemainingArguments=$true)]
            $Remaining
        )
        
        Use-CliTool "eza" --icons --git-ignore --git $Remaining
    }
    
    function Get-ChildItemEzaLongGit {
        param(
            [Parameter(ValueFromRemainingArguments=$true)]
            $Remaining
        )
        
        Use-CliTool "eza" --icons --long --header --git-ignore --git $Remaining
    }
    
    function Get-ChildItemEzaSize {
        param(
            [Parameter(ValueFromRemainingArguments=$true)]
            $Remaining
        )
        
        Use-CliTool "eza" --icons --long --header --sort=size $Remaining
    }
    
    function Get-ChildItemEzaModified {
        param(
            [Parameter(ValueFromRemainingArguments=$true)]
            $Remaining
        )
        
        Use-CliTool "eza" --icons --long --header --sort=modified $Remaining
    }
    
    # Create aliases for Eza functions
    Set-Alias -Name ez -Value Get-ChildItemEza
    Set-Alias -Name ll -Value Get-ChildItemEzaLong
    Set-Alias -Name la -Value Get-ChildItemEzaAll
    Set-Alias -Name lt -Value Get-ChildItemEzaTree
    Set-Alias -Name llt -Value Get-ChildItemEzaTreeLong
    Set-Alias -Name lg -Value Get-ChildItemEzaGrid
    Set-Alias -Name lsg -Value Get-ChildItemEzaGit
    Set-Alias -Name llg -Value Get-ChildItemEzaLongGit
    Set-Alias -Name lss -Value Get-ChildItemEzaSize
    Set-Alias -Name lsm -Value Get-ChildItemEzaModified
    
    # Only show Eza configuration message on first load
    if ($global:ProfileLoadCount -eq 1) {
        Write-ColorMessage "[INFO] Eza configured with icons support and common aliases:" $colors.Info
        Write-ColorMessage "  ez    - Basic eza with icons" $colors.Info
        Write-ColorMessage "  ll    - List in long format" $colors.Info
        Write-ColorMessage "  la    - List all files (including hidden)" $colors.Info
        Write-ColorMessage "  lt    - List as tree" $colors.Info
        Write-ColorMessage "  llt   - List as tree in long format" $colors.Info
        Write-ColorMessage "  lg    - List in grid format" $colors.Info
        Write-ColorMessage "  lsg   - List with git status" $colors.Info
        Write-ColorMessage "  llg   - List in long format with git status" $colors.Info
        Write-ColorMessage "  lss   - List sorted by size" $colors.Info
        Write-ColorMessage "  lsm   - List sorted by modified time" $colors.Info
    }
}

# Configure bat integration if available
if (Test-Command "bat") {
    function Get-ContentBat {
        param(
            [Parameter(ValueFromRemainingArguments=$true)]
            $Remaining
        )
        
        Use-CliTool "bat" --theme=ansi --style=numbers,changes,header $Remaining
    }
    
    Set-Alias -Name cat -Value Get-ContentBat
}

# Configure ripgrep integration if available
if (Test-Command "rg") {
    function Invoke-Ripgrep {
        param(
            [Parameter(ValueFromRemainingArguments=$true)]
            $Remaining
        )
        
        Use-CliTool "rg" --smart-case --hidden --follow $Remaining
    }
    
    Set-Alias -Name grep -Value Invoke-Ripgrep
    Set-Alias -Name rg -Value Invoke-Ripgrep
}

# Configure fd integration if available
if (Test-Command "fd") {
    function Invoke-Fd {
        param(
            [Parameter(ValueFromRemainingArguments=$true)]
            $Remaining
        )
        
        Use-CliTool "fd" --hidden --follow $Remaining
    }
    
    Set-Alias -Name find -Value Invoke-Fd
    Set-Alias -Name fd -Value Invoke-Fd
}

# Configure tealdeer integration if available
if (Test-Command "tldr") {
    function Get-TldrHelp {
        param(
            [Parameter(ValueFromRemainingArguments=$true)]
            $Remaining
        )
        
        Use-CliTool "tldr" $Remaining
    }
    
    Set-Alias -Name help -Value Get-TldrHelp
}

# Configure git-delta integration if available
if (Test-Command "delta") {
    function Invoke-GitDiffDelta {
        param(
            [Parameter(ValueFromRemainingArguments=$true)]
            $Remaining
        )
        
        git diff $Remaining | Use-CliTool "delta"
    }
    
    Set-Alias -Name gdiff -Value Invoke-GitDiffDelta
}

# Configure age encryption integration if available
if (Test-Command "age") {
    function Invoke-AgeEncrypt {
        param(
            [Parameter(ValueFromRemainingArguments=$true)]
            $Remaining
        )
        
        if (Test-Command "age-encrypt") {
            Use-CliTool "age" -e $Remaining
        }
        else {
            Write-ColorMessage "❌ age-encrypt script not found. Using direct age command instead." $colors.Warning
            Use-CliTool "age" -e $Remaining
        }
    }
    
    function Invoke-AgeDecrypt {
        param(
            [Parameter(ValueFromRemainingArguments=$true)]
            $Remaining
        )
        
        if (Test-Command "age-decrypt") {
            Use-CliTool "age" -d $Remaining
        }
        else {
            Write-ColorMessage "❌ age-decrypt script not found. Using direct age command instead." $colors.Warning
            Use-CliTool "age" -d $Remaining
        }
    }
    
    Set-Alias -Name encrypt -Value Invoke-AgeEncrypt
    Set-Alias -Name decrypt -Value Invoke-AgeDecrypt
}

# Configure asciinema integration if available
if (Test-Command "asciinema") {
    function Start-AsciinemaRecording {
        param(
            [Parameter(ValueFromRemainingArguments=$true)]
            $Remaining
        )
        
        Use-CliTool "asciinema" rec $Remaining
    }
    
    function Start-AsciinemaPlayback {
        param(
            [Parameter(ValueFromRemainingArguments=$true)]
            $Remaining
        )
        
        Use-CliTool "asciinema" play $Remaining
    }
    
    function Start-AsciinemaUpload {
        param(
            [Parameter(ValueFromRemainingArguments=$true)]
            $Remaining
        )
        
        Use-CliTool "asciinema" upload $Remaining
    }
    
    Set-Alias -Name rec -Value Start-AsciinemaRecording
    Set-Alias -Name play -Value Start-AsciinemaPlayback
    Set-Alias -Name upload -Value Start-AsciinemaUpload
}

# Configure LazyGit integration if available
if (Test-Command "lazygit") {
    function Start-LazyGit {
        param(
            [Parameter(ValueFromRemainingArguments=$true)]
            $Remaining
        )
        
        Use-CliTool "lazygit" $Remaining
    }
    
    Set-Alias -Name lg -Value Start-LazyGit
}

# Configure gping integration if available
if (Test-Command "gping") {
    function Start-GPing {
        param(
            [Parameter(ValueFromRemainingArguments=$true)]
            $Remaining
        )
        
        Use-CliTool "gping" $Remaining
    }
    
    Set-Alias -Name ping -Value Start-GPing
}

# Configure doggo integration if available
if (Test-Command "doggo") {
    function Invoke-Doggo {
        param(
            [Parameter(ValueFromRemainingArguments=$true)]
            $Remaining
        )
        
        Use-CliTool "doggo" $Remaining
    }
    
    Set-Alias -Name dig -Value Invoke-Doggo
    Set-Alias -Name dns -Value Invoke-Doggo
}

# Configure bandwhich integration if available
if (Test-Command "bandwhich") {
    function Start-Bandwhich {
        param(
            [Parameter(ValueFromRemainingArguments=$true)]
            $Remaining
        )
        
        if ($IsWindows) {
            Use-CliTool "bandwhich" $Remaining
        }
        else {
            sudo $(Use-CliTool "bandwhich" $Remaining)
        }
    }
    
    Set-Alias -Name bw -Value Start-Bandwhich
}

# Configure duf integration if available
if (Test-Command "duf") {
    function Invoke-Duf {
        param(
            [Parameter(ValueFromRemainingArguments=$true)]
            $Remaining
        )
        
        Use-CliTool "duf" $Remaining
    }
    
    Set-Alias -Name du -Value Invoke-Duf
    Set-Alias -Name df -Value Invoke-Duf
}

# Configure ranger integration if available
if (Test-Command "ranger") {
    function Start-Ranger {
        param(
            [Parameter(ValueFromRemainingArguments=$true)]
            $Remaining
        )
        
        Use-CliTool "ranger" $Remaining
    }
    
    Set-Alias -Name fm -Value Start-Ranger
}

# Configure ncdu integration if available
if (Test-Command "ncdu") {
    function Start-Ncdu {
        param(
            [Parameter(ValueFromRemainingArguments=$true)]
            $Remaining
        )
        
        Use-CliTool "ncdu" --color dark $Remaining
    }
    
    Set-Alias -Name ncdu -Value Start-Ncdu
}

# Configure carbonyl integration if available
if (Test-Command "carbonyl") {
    function Start-Carbonyl {
        param(
            [Parameter(ValueFromRemainingArguments=$true)]
            $Remaining
        )
        
        Use-CliTool "carbonyl" $Remaining
    }
    
    Set-Alias -Name browse -Value Start-Carbonyl
}
#endregion
#region Utility Functions
# Git shortcuts
function Get-GitStatus { git status $args }
function Invoke-GitAdd { git add $args }
function Invoke-GitCommit { git commit $args }
function Invoke-GitPush { git push $args }
function Invoke-GitPull { git pull $args }
function Get-GitLog { git log --oneline --graph --decorate --all $args }
function Get-GitBranch { git branch $args }
function Invoke-GitCheckout { git checkout $args }
function Invoke-GitFetch { git fetch $args }
function Invoke-GitMerge { git merge $args }

# Set aliases for Git functions
Set-Alias -Name gst -Value Get-GitStatus
Set-Alias -Name ga -Value Invoke-GitAdd
# Rename conflicting aliases (gc, gp, gl, gm are built-in PowerShell commands)
Set-Alias -Name gitc -Value Invoke-GitCommit
Set-Alias -Name gitp -Value Invoke-GitPush
Set-Alias -Name gpl -Value Invoke-GitPull
Set-Alias -Name gitl -Value Get-GitLog
Set-Alias -Name gb -Value Get-GitBranch
Set-Alias -Name gco -Value Invoke-GitCheckout
Set-Alias -Name gf -Value Invoke-GitFetch
Set-Alias -Name gitm -Value Invoke-GitMerge

# Navigation shortcuts
function Set-LocationUp { Set-Location .. }
function Set-LocationHome { Set-Location ~ }
function Set-LocationDotfiles { Set-Location $DOTFILES_DIR }

# Set aliases for navigation
Set-Alias -Name .. -Value Set-LocationUp
Set-Alias -Name ~ -Value Set-LocationHome
Set-Alias -Name dotfiles -Value Set-LocationDotfiles

# System information
function Get-SystemInfo {
    $osInfo = if ($IsMacOS) {
        "macOS $(sw_vers -productVersion) ($(uname -m))"
    }
    elseif ($IsLinux) {
        "Linux $(uname -r) ($(uname -m))"
    }
    elseif ($IsWindows) {
        "Windows $((Get-CimInstance -ClassName Win32_OperatingSystem).Caption) ($(if ([Environment]::Is64BitOperatingSystem) { "64-bit" } else { "32-bit" }))"
    }
    else {
        "Unknown OS"
    }
    
    $psInfo = "$($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor).$($PSVersionTable.PSVersion.Patch)"
    
    Write-Host "System Information:" -ForegroundColor $colors.Emphasis
    Write-Host "  OS:         $osInfo" -ForegroundColor $colors.Info
    Write-Host "  PowerShell: $psInfo" -ForegroundColor $colors.Info
    Write-Host "  User:       $env:USER" -ForegroundColor $colors.Info
    Write-Host "  Hostname:   $(hostname)" -ForegroundColor $colors.Info
    
    if ($IsMacOS) {
        Write-Host "  CPU:        $(sysctl -n machdep.cpu.brand_string)" -ForegroundColor $colors.Info
        Write-Host "  Memory:     $([math]::Round((sysctl -n hw.memsize) / 1GB))GB" -ForegroundColor $colors.Info
    }
}

# Set alias for system information
Set-Alias -Name sysinfo -Value Get-SystemInfo

# Function to sync PowerShell profile with dotfiles repository
function Test-CliToolPaths {
    param(
        [switch]$UpdatePaths
    )
    
    $missingTools = @()
    $updatedPaths = @{}
    
    foreach ($tool in $cliToolPaths.Keys) {
        $path = $cliToolPaths[$tool]
        if (-not (Test-Path $path)) {
            # Try to find the tool in PATH
            try {
                $foundPath = if ($IsWindows) {
                    (Get-Command $tool -ErrorAction Stop).Source
                } else {
                    $(which $tool 2>$null)
                }
                
                if ($foundPath) {
                    $missingTools += "$tool (found at $foundPath)"
                    if ($UpdatePaths) {
                        $updatedPaths[$tool] = $foundPath
                    }
                } else {
                    $missingTools += "$tool (not found in PATH)"
                }
            } catch {
                $missingTools += "$tool (not found in PATH)"
            }
        }
    }
    
    if ($missingTools.Count -gt 0) {
        Write-ColorMessage "⚠️ Some CLI tool paths are incorrect:" $colors.Warning
        foreach ($tool in $missingTools) {
            Write-ColorMessage "   - $tool" $colors.Warning
        }
        
        if ($UpdatePaths -and $updatedPaths.Count -gt 0) {
            Write-ColorMessage "🔄 Updating CLI tool paths..." $colors.Info
            foreach ($tool in $updatedPaths.Keys) {
                $cliToolPaths[$tool] = $updatedPaths[$tool]
                Write-ColorMessage "   - Updated $tool to $($updatedPaths[$tool])" $colors.Success
            }
        }
    } else {
        Write-ColorMessage "✅ All CLI tool paths are valid" $colors.Success
    }
    
    return $missingTools.Count -eq 0
}

function Sync-PowerShellProfile {
    param(
        [switch]$Pull,
        [switch]$Force,
        [switch]$VerifyPaths
    )
    
    if ($VerifyPaths) {
        Test-CliToolPaths -UpdatePaths
        return
    }
    
    if ($Pull) {
        # Pull changes from dotfiles repository
        Push-Location $DOTFILES_DIR
        git pull
        Pop-Location
        
        # Copy from dotfiles to local profile
        Invoke-SyncPowerShellProfile -Force:$Force
        
        # Verify CLI tool paths after sync
        Test-CliToolPaths
        
        Write-ColorMessage "✅ PowerShell profile pulled from dotfiles repository and synced to local profile" $colors.Success
    }
    else {
        # Copy from local profile to dotfiles
        $sourceProfile = "$HOME/.config/powershell/Microsoft.PowerShell_profile.ps1"
        $targetProfile = "$DOTFILES_DIR/powershell/Microsoft.PowerShell_profile.ps1"
        
        if (-not (Test-Path $sourceProfile)) {
            Write-ColorMessage "❌ Source profile not found: $sourceProfile" $colors.Error
            return
        }
        
        # Check if source and target are the same file (due to symlinks)
        $sourceItem = Get-Item $sourceProfile -ErrorAction SilentlyContinue
        $targetItem = Get-Item $targetProfile -ErrorAction SilentlyContinue
        
        if ($sourceItem -and $targetItem -and 
            ($sourceItem.LinkType -eq "SymbolicLink" -or $targetItem.LinkType -eq "SymbolicLink") -and
            ($sourceItem.Target -eq $targetItem.FullName -or $targetItem.Target -eq $sourceItem.FullName)) {
            Write-ColorMessage "⚠️ Source and target are the same file due to symlinks. Skipping copy." $colors.Warning
        }
        else {
            # Create target directory if it doesn't exist
            $targetDir = Split-Path -Parent $targetProfile
            if (-not (Test-Path $targetDir)) {
                New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
            }
            
            # Copy profile
            Copy-Item -Path $sourceProfile -Destination $targetProfile -Force
            Write-ColorMessage "✅ Copied profile to dotfiles repository" $colors.Success
        }
        
        # Copy scripts
        $sourceScriptsDir = "$HOME/.config/powershell/Scripts"
        $targetScriptsDir = "$DOTFILES_DIR/powershell/Scripts"
        
        if (Test-Path $sourceScriptsDir) {
            if (-not (Test-Path $targetScriptsDir)) {
                New-Item -ItemType Directory -Path $targetScriptsDir -Force | Out-Null
            }
            
            # Get all script files
            $scriptFiles = Get-ChildItem -Path $sourceScriptsDir -File
            
            foreach ($file in $scriptFiles) {
                $targetFile = Join-Path $targetScriptsDir $file.Name
                $sourceFile = $file.FullName
                
                # Check if source and target are the same file (due to symlinks)
                $sourceItem = Get-Item $sourceFile -ErrorAction SilentlyContinue
                $targetItem = Get-Item $targetFile -ErrorAction SilentlyContinue
                
                if ($sourceItem -and $targetItem -and 
                    ($sourceItem.LinkType -eq "SymbolicLink" -or $targetItem.LinkType -eq "SymbolicLink") -and
                    ($sourceItem.Target -eq $targetItem.FullName -or $targetItem.Target -eq $sourceItem.FullName)) {
                    Write-ColorMessage "⚠️ Script $($file.Name) source and target are the same file due to symlinks. Skipping copy." $colors.Warning
                }
                else {
                    Copy-Item -Path $sourceFile -Destination $targetFile -Force
                    Write-ColorMessage "✅ Copied script $($file.Name) to dotfiles repository" $colors.Success
                }
            }
        }
        
        # Verify CLI tool paths before committing
        Test-CliToolPaths
        
        # Commit changes to dotfiles repository
        Push-Location $DOTFILES_DIR
        git add powershell
        git commit -m "Update PowerShell profile and scripts"
        git push
        Pop-Location
        
        Write-ColorMessage "✅ PowerShell profile synced to dotfiles repository and pushed to remote" $colors.Success
    }
}

# Set aliases for syncing PowerShell profile
Set-Alias -Name syncps -Value Sync-PowerShellProfile
Set-Alias -Name checkpaths -Value Test-CliToolPaths

# Function to update PowerShell modules
function Update-AllModules {
    Write-ColorMessage "Updating PowerShell modules..." $colors.Info
    
    $modules = Get-InstalledModule
    
    foreach ($module in $modules) {
        $currentVersion = $module.Version
        $latestVersion = (Find-Module -Name $module.Name).Version
        
        if ($currentVersion -ne $latestVersion) {
            Write-ColorMessage "Updating $($module.Name) from $currentVersion to $latestVersion..." $colors.Warning
            
            try {
                Update-Module -Name $module.Name -Force
                Write-ColorMessage "✅ Updated $($module.Name) to $latestVersion" $colors.Success
            }
            catch {
                Write-ColorMessage "❌ Failed to update $($module.Name): $_" $colors.Error
            }
        }
        else {
            Write-ColorMessage "✅ $($module.Name) is already at the latest version ($currentVersion)" $colors.Success
        }
    }
}

# Function to update M365 and Azure modules
function Update-M365AzureModules {
    param(
        [switch]$Force
    )
    
    $m365AzureScript = "$SCRIPTS_DIR/Install-M365AzureModules.ps1"
    if (Test-Path $m365AzureScript) {
        & $m365AzureScript -Force:$Force
    } else {
        Write-ColorMessage "⚠️ M365 and Azure modules installation script not found: $m365AzureScript" $colors.Warning
    }
}

function Update-AdditionalModules {
    param(
        [switch]$Force
    )
    
    $additionalModulesScript = "$SCRIPTS_DIR/Install-AdditionalModules.ps1"
    if (Test-Path $additionalModulesScript) {
        & $additionalModulesScript -Force:$Force
    } else {
        Write-ColorMessage "⚠️ Additional modules installation script not found: $additionalModulesScript" $colors.Warning
    }
}

function Sync-PowerShellRepository {
    param(
        [switch]$Force
    )
    
    $syncRepoScript = "$SCRIPTS_DIR/Sync-PowerShellRepository.ps1"
    if (Test-Path $syncRepoScript) {
        & $syncRepoScript -Force:$Force
    } else {
        Write-ColorMessage "⚠️ PowerShell Repository sync script not found: $syncRepoScript" $colors.Warning
    }
}

# Set alias for updating modules
Set-Alias -Name updatemodules -Value Update-AllModules
Set-Alias -Name updatem365 -Value Update-M365AzureModules
Set-Alias -Name updateaddons -Value Update-AdditionalModules
Set-Alias -Name syncrepo -Value Sync-PowerShellRepository

#region Microsoft 365 and Azure Functions
# Microsoft 365 and Azure connection functions
function Connect-M365 {
    param(
        [Parameter(Mandatory=$false)]
        [string]$TenantId,
        
        [Parameter(Mandatory=$false)]
        [switch]$MFA,
        
        [Parameter(Mandatory=$false)]
        [switch]$Exchange,
        
        [Parameter(Mandatory=$false)]
        [switch]$SharePoint,
        
        [Parameter(Mandatory=$false)]
        [switch]$Teams,
        
        [Parameter(Mandatory=$false)]
        [switch]$Graph
    )
    
    # Check if required modules are installed
    $requiredModules = @()
    
    if ($Exchange -or (-not ($SharePoint -or $Teams -or $Graph))) {
        $requiredModules += "ExchangeOnlineManagement"
    }
    
    if ($SharePoint) {
        $requiredModules += "PnP.PowerShell"
    }
    
    if ($Teams) {
        $requiredModules += "MicrosoftTeams"
    }
    
    if ($Graph -or (-not ($Exchange -or $SharePoint -or $Teams))) {
        $requiredModules += "Microsoft.Graph"
    }
    
    $missingModules = @()
    foreach ($module in $requiredModules) {
        if (-not (Get-Module -Name $module -ListAvailable)) {
            $missingModules += $module
        }
    }
    
    if ($missingModules.Count -gt 0) {
        Write-ColorMessage "❌ Missing required modules: $($missingModules -join ', ')" $colors.Error
        Write-ColorMessage "Run 'Update-M365AzureModules' to install the required modules" $colors.Warning
        return
    }
    
    # Connect to services
    try {
        if ($Exchange -or (-not ($SharePoint -or $Teams -or $Graph))) {
            Write-ColorMessage "Connecting to Exchange Online..." $colors.Info
            if ($TenantId) {
                Connect-ExchangeOnline -ManagedIdentity:$MFA -Organization "$TenantId.onmicrosoft.com" -ShowBanner:$false
            } else {
                Connect-ExchangeOnline -ManagedIdentity:$MFA -ShowBanner:$false
            }
            Write-ColorMessage "✅ Connected to Exchange Online" $colors.Success
        }
        
        if ($SharePoint) {
            Write-ColorMessage "Connecting to SharePoint Online..." $colors.Info
            if ($TenantId) {
                Connect-PnPOnline -Url "https://$TenantId.sharepoint.com" -Interactive
            } else {
                Connect-PnPOnline -Interactive
            }
            Write-ColorMessage "✅ Connected to SharePoint Online" $colors.Success
        }
        
        if ($Teams) {
            Write-ColorMessage "Connecting to Microsoft Teams..." $colors.Info
            Connect-MicrosoftTeams
            Write-ColorMessage "✅ Connected to Microsoft Teams" $colors.Success
        }
        
        if ($Graph -or (-not ($Exchange -or $SharePoint -or $Teams))) {
            Write-ColorMessage "Connecting to Microsoft Graph..." $colors.Info
            Connect-MgGraph -Scopes "User.Read.All", "Group.ReadWrite.All", "Directory.ReadWrite.All"
            Write-ColorMessage "✅ Connected to Microsoft Graph" $colors.Success
        }
        
        Write-ColorMessage "✅ Successfully connected to Microsoft 365 services" $colors.Success
    } catch {
        Write-ColorMessage "❌ Error connecting to Microsoft 365: $($_.Exception.Message)" $colors.Error
    }
}

function Connect-AzureCloud {
    param(
        [Parameter(Mandatory=$false)]
        [string]$SubscriptionId,
        
        [Parameter(Mandatory=$false)]
        [string]$TenantId
    )
    
    # Check if required modules are installed
    if (-not (Get-Module -Name Az.Accounts -ListAvailable)) {
        Write-ColorMessage "❌ Missing required module: Az.Accounts" $colors.Error
        Write-ColorMessage "Run 'Update-M365AzureModules' to install the required modules" $colors.Warning
        return
    }
    
    try {
        # Connect to Azure
        Write-ColorMessage "Connecting to Azure..." $colors.Info
        
        $params = @{}
        if ($TenantId) { $params.TenantId = $TenantId }
        
        Connect-AzAccount @params
        
        # Set subscription if specified
        if ($SubscriptionId) {
            Write-ColorMessage "Setting subscription to $SubscriptionId..." $colors.Info
            Set-AzContext -Subscription $SubscriptionId
        }
        
        # Show current context
        $context = Get-AzContext
        Write-ColorMessage "✅ Connected to Azure" $colors.Success
        Write-ColorMessage "   Tenant: $($context.Tenant.Id)" $colors.Info
        Write-ColorMessage "   Subscription: $($context.Subscription.Name) ($($context.Subscription.Id))" $colors.Info
        Write-ColorMessage "   Account: $($context.Account.Id)" $colors.Info
    } catch {
        Write-ColorMessage "❌ Error connecting to Azure: $($_.Exception.Message)" $colors.Error
    }
}

function Disconnect-M365 {
    try {
        # Disconnect from Exchange Online
        if (Get-Command Disconnect-ExchangeOnline -ErrorAction SilentlyContinue) {
            Disconnect-ExchangeOnline -Confirm:$false
            Write-ColorMessage "✅ Disconnected from Exchange Online" $colors.Success
        }
        
        # Disconnect from SharePoint Online
        if (Get-Command Disconnect-PnPOnline -ErrorAction SilentlyContinue) {
            Disconnect-PnPOnline
            Write-ColorMessage "✅ Disconnected from SharePoint Online" $colors.Success
        }
        
        # Disconnect from Microsoft Teams
        if (Get-Command Disconnect-MicrosoftTeams -ErrorAction SilentlyContinue) {
            Disconnect-MicrosoftTeams
            Write-ColorMessage "✅ Disconnected from Microsoft Teams" $colors.Success
        }
        
        # Disconnect from Microsoft Graph
        if (Get-Command Disconnect-MgGraph -ErrorAction SilentlyContinue) {
            Disconnect-MgGraph
            Write-ColorMessage "✅ Disconnected from Microsoft Graph" $colors.Success
        }
        
        Write-ColorMessage "✅ Successfully disconnected from all Microsoft 365 services" $colors.Success
    } catch {
        Write-ColorMessage "❌ Error disconnecting from Microsoft 365: $($_.Exception.Message)" $colors.Error
    }
}

function Disconnect-AzureCloud {
    try {
        # Disconnect from Azure
        if (Get-Command Disconnect-AzAccount -ErrorAction SilentlyContinue) {
            Disconnect-AzAccount
            Write-ColorMessage "✅ Disconnected from Azure" $colors.Success
        }
    } catch {
        Write-ColorMessage "❌ Error disconnecting from Azure: $($_.Exception.Message)" $colors.Error
    }
}

# Set aliases for M365 and Azure functions
Set-Alias -Name m365 -Value Connect-M365
Set-Alias -Name azure -Value Connect-AzureCloud
Set-Alias -Name m365exit -Value Disconnect-M365
Set-Alias -Name azureexit -Value Disconnect-AzureCloud
#endregion

# Function to update Homebrew packages
function Update-HomebrewPackages {
    if (Test-Command "brew") {
        Write-ColorMessage "Updating Homebrew packages..." $colors.Info
        
        try {
            # Update Homebrew itself
            brew update
            
            # Upgrade all packages
            brew upgrade
            
            # Cleanup old versions
            brew cleanup
            
            Write-ColorMessage "✅ Homebrew packages updated successfully" $colors.Success
        }
        catch {
            Write-ColorMessage "❌ Failed to update Homebrew packages: $_" $colors.Error
        }
    }
    else {
        Write-ColorMessage "❌ Homebrew is not installed" $colors.Error
    }
}

# Set alias for updating Homebrew packages
Set-Alias -Name brewup -Value Update-HomebrewPackages

# Function to update both PowerShell modules and Homebrew packages
function Update-AllPackages {
    Update-AllModules
    Update-HomebrewPackages
}

# Set alias for updating all packages
Set-Alias -Name updateall -Value Update-AllPackages
#endregion

#region Initialization
# Display welcome message - only on first load
if ($global:ProfileLoadCount -eq 1) {
    $greeting = Get-Greeting
    Write-Host "`n$greeting $env:USER ⚡`n" -ForegroundColor $colors.Emphasis
}

# Initialize PowerShell environment (install required modules and CLI tools)
# Comment out the next line if you don't want to check for dependencies on every startup
# Initialize-PowerShellEnvironment -Quiet

# Final message - only show on first load
if ($global:ProfileLoadCount -eq 1) {
    Write-ColorMessage "[INFO] PowerShell profile loaded successfully." $colors.Info
}
#endregion

