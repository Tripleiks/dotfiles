# My Dotfiles

This repository contains my personal dotfiles, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Prerequisites

- **Git**: To clone this repository.
- **GNU Stow**: To symlink the dotfiles.
  - On macOS: `brew install stow`
  - On Debian/Ubuntu: `sudo apt-get install stow`
  - On Fedora: `sudo dnf install stow`

## Installation / Setup

1.  **Clone the repository** to your home directory (or any preferred location, but `~/dotfiles` is common):
    ```bash
    git clone <your-repo-url> ~/dotfiles
    # Example: git clone git@github.com:yourusername/dotfiles.git ~/dotfiles
    ```
    *(Replace `<your-repo-url>` with the actual URL of your dotfiles repository.)*

2.  **Navigate into the repository**:
    ```bash
    cd ~/dotfiles
    ```

3.  **Customize `bootstrap.sh` (if needed)**:
    Open the `bootstrap.sh` script and ensure the `PACKAGES` variable lists all the subdirectories (stow packages like `zsh`, `vim`, `git`, `nvim`, `tmux`) you want to manage.
    ```sh
    PACKAGES="zsh vim git tmux nvim" # Edit this line in bootstrap.sh
    ```

4.  **Make the bootstrap script executable**:
    ```bash
    chmod +x bootstrap.sh
    ```

5.  **Run the bootstrap script**:
    This will use `stow` to create symlinks from this repository to your home directory for each package defined in `bootstrap.sh`.
    ```bash
    ./bootstrap.sh
    ```

## How it Works

- Each subdirectory in this repository (e.g., `zsh/`, `vim/`, `git/`) is a "stow package".
- Inside each package directory, dotfiles are stored with their original names (e.g., `zsh/.zshrc`, `vim/.vimrc`).
- If a dotfile normally resides in a subdirectory of your home directory (e.g., `~/.config/nvim/init.lua`), you should replicate that directory structure within the stow package (e.g., `nvim/.config/nvim/init.lua` inside this repository).
- `stow` then creates symlinks in your home directory (`~`) pointing to the files within these package directories. For example, `~/.zshrc` will be a symlink to `~/dotfiles/zsh/.zshrc`.

## Managing Dotfiles

- **Adding new dotfiles**:
  1.  Create the appropriate subdirectory in this repository if it doesn't exist (e.g., `alacritty/`).
  2.  Move your dotfile into that subdirectory (e.g., `mv ~/.alacritty.yml ~/dotfiles/alacritty/.alacritty.yml`).
  3.  Add the new package name (e.g., `alacritty`) to the `PACKAGES` list in `bootstrap.sh`.
  4.  Run `./bootstrap.sh`.
  5.  Commit and push the changes.

- **Removing dotfiles**:
  1.  To "unstow" a package (remove its symlinks): `stow -D <package_name>` (e.g., `stow -D vim`).
  2.  Remove the package name from `PACKAGES` in `bootstrap.sh`.
  3.  Delete the package directory from this repository if desired.
  4.  Commit and push the changes.

- **Updating dotfiles**:
  1.  Edit the files directly within this repository (e.g., `vim ~/dotfiles/vim/.vimrc`).
  2.  The symlinks mean your system will use the updated versions immediately.
  3.  Commit and push the changes to back them up.

## Troubleshooting

- **Stow conflicts**: If `stow` reports conflicts, it means a file or directory already exists where it's trying to create a symlink. You might need to back up and remove the existing file/directory from your home directory before stowing.
  Example: If `~/.zshrc` already exists and is not a symlink, `stow zsh` will complain. You would:
    1.  `mv ~/.zshrc ~/.zshrc.backup`
    2.  Then run `stow zsh` (or `./bootstrap.sh`).
