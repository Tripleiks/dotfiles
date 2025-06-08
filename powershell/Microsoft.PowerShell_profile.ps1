#!/usr/bin/env pwsh
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
$THEME_DIR = "$HOME/.config/oh-my-posh/themes"

# Note: Using built-in $IsWindows, $IsMacOS, and $IsLinux automatic variables

# Ensure Homebrew paths are in PATH
# This ensures CLI tools are accessible in all environments (including Warp)
if ($IsMacOS) {
    # Common Homebrew paths on macOS
    $homebrewPaths = @(
        "/opt/homebrew/bin",
        "/opt/homebrew/sbin",
        "/usr/local/bin"
    )
    
    # Add Homebrew paths to PATH if they're not already there
    foreach ($path in $homebrewPaths) {
        if (Test-Path $path) {
            if (-not ($env:PATH -split [IO.Path]::PathSeparator).Contains($path)) {
                $env:PATH = "$path" + [IO.Path]::PathSeparator + $env:PATH
            }
        }
    }
    
    # Define full paths for common CLI tools to ensure they work in all environments
    $cliToolPaths = @{
        "eza" = "/opt/homebrew/bin/eza"
        "bat" = "/opt/homebrew/bin/bat"
        "rg" = "/opt/homebrew/bin/rg"
        "fd" = "/opt/homebrew/bin/fd"
        "jq" = "/usr/bin/jq"
        "delta" = "/opt/homebrew/bin/delta"
        "age" = "/opt/homebrew/bin/age"
        "tldr" = "/opt/homebrew/bin/tldr"
        "asciinema" = "/opt/homebrew/bin/asciinema"
        "lazygit" = "/opt/homebrew/bin/lazygit"
        "gping" = "/opt/homebrew/bin/gping"
        "doggo" = "/opt/homebrew/bin/doggo"
        "bandwhich" = "/opt/homebrew/bin/bandwhich"
        "duf" = "/opt/homebrew/bin/duf"
        "ranger" = "/opt/homebrew/bin/ranger"
        "ncdu" = "/opt/homebrew/bin/ncdu"
        "fzf" = "/opt/homebrew/bin/fzf"
    }
    
    # Function to safely use CLI tools with full paths
    function Use-CliTool {
        param(
            [Parameter(Mandatory=$true)]
            [string]$Tool,
            
            [Parameter(ValueFromRemainingArguments=$true)]
            $Arguments
        )
        
        if ($cliToolPaths.ContainsKey($Tool) -and (Test-Path $cliToolPaths[$Tool])) {
            & $cliToolPaths[$Tool] @Arguments
        } else {
            # Fallback to regular command if full path doesn't exist
            & $Tool @Arguments
        }
    }
    
    Write-ColorMessage "[INFO] CLI tool paths configured for consistent access across all environments" $colors.Info
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
}
#endregion

#region Module Imports and Configuration
# Import required modules if available
$requiredModules = @(
    @{ Name = "PSReadLine"; MinVersion = "2.2.0" },
    @{ Name = "posh-git"; MinVersion = "1.0.0" },
    @{ Name = "oh-my-posh"; MinVersion = "7.0.0" },
    @{ Name = "z"; MinVersion = "1.1.13" },
    @{ Name = "PSFzf"; MinVersion = "2.0.0" }
)

foreach ($module in $requiredModules) {
    $moduleName = $module.Name
    try {
        if (Get-Module -ListAvailable -Name $moduleName) {
            Import-Module $moduleName -DisableNameChecking
        }
    }
    catch {
        Write-ColorMessage "⚠️ Failed to import module: $moduleName" $colors.Warning
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
    
    Write-ColorMessage "[INFO] PSReadLine loaded and configured with custom colors." $colors.Info
}

# Note: We're using eza's built-in icons instead of Terminal-Icons for a more consistent experience
Write-ColorMessage "[INFO] Using eza's built-in icons for file listings." $colors.Info

# Configure oh-my-posh (using the executable instead of the module)
# Use full path to oh-my-posh to ensure it works in all environments (including Warp)
$ohMyPoshPath = "/opt/homebrew/bin/oh-my-posh"

if (Test-Path $ohMyPoshPath) {
    # Set the oh-my-posh theme
    if (Test-Path "$THEME_DIR/my-quick-term.omp.json") {
        & $ohMyPoshPath init pwsh --config "$THEME_DIR/my-quick-term.omp.json" | Invoke-Expression
        Write-ColorMessage "[INFO] Oh My Posh initialized with custom theme: $THEME_DIR/my-quick-term.omp.json" $colors.Info
    } else {
        & $ohMyPoshPath init pwsh --config "$env:POSH_THEMES_PATH/paradox.omp.json" | Invoke-Expression
        Write-ColorMessage "[INFO] Oh My Posh initialized with default theme: paradox" $colors.Info
    }
} elseif (Test-Command "oh-my-posh") {
    # Fallback to PATH if the specific path doesn't exist
    # Set the oh-my-posh theme
    if (Test-Path "$THEME_DIR/my-quick-term.omp.json") {
        oh-my-posh init pwsh --config "$THEME_DIR/my-quick-term.omp.json" | Invoke-Expression
        Write-ColorMessage "[INFO] Oh My Posh initialized with custom theme: $THEME_DIR/my-quick-term.omp.json" $colors.Info
    } else {
        oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/paradox.omp.json" | Invoke-Expression
        Write-ColorMessage "[INFO] Oh My Posh initialized with default theme: paradox" $colors.Info
    }
} else {
    Write-ColorMessage "[WARNING] oh-my-posh executable not found. Install it with: brew install jandedobbeleer/oh-my-posh/oh-my-posh" $colors.Warning
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
function Sync-PowerShellProfile {
    param(
        [switch]$Pull,
        [switch]$Force
    )
    
    if ($Pull) {
        # Pull changes from dotfiles repository
        Push-Location $DOTFILES_DIR
        git pull
        Pop-Location
        
        # Copy from dotfiles to local profile
        Invoke-SyncPowerShellProfile -Force:$Force
        
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

# Set alias for updating modules
Set-Alias -Name updatemodules -Value Update-AllModules

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
# Display welcome message
$greeting = Get-Greeting
Write-Host "`n$greeting $env:USER ⚡`n" -ForegroundColor $colors.Emphasis

# Initialize PowerShell environment (install required modules and CLI tools)
# Comment out the next line if you don't want to check for dependencies on every startup
# Initialize-PowerShellEnvironment -Quiet

# Final message
Write-ColorMessage "[INFO] PowerShell profile loaded successfully." $colors.Info
#endregion
