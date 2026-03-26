#!/bin/bash

# Script: install-neovim.sh
# Purpose: Install Neovim and dependencies
# Exit codes: 0 = success, 1 = failure

set -e

# Load config if available
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [ -f "$ROOT_DIR/library_scripts/config.sh" ]; then
    source "$ROOT_DIR/library_scripts/config.sh"
else
    CONFIG_DIR="${HOME}/.config"
    NEOVIM_DIR="$CONFIG_DIR/nvim"
fi

echo "Installing Neovim and dependencies..."

# Function to check and install packages
install_package() {
    local package_name="$1"
    local install_cmd="$2"
    local check_cmd="${3:-$package_name}"

    if command -v "$check_cmd" &>/dev/null; then
        local version
        version=$(eval "$check_cmd --version 2>/dev/null || $check_cmd version 2>/dev/null || echo 'installed'")
        printf "%s is already installed: %s\n" "$package_name" "$version"
    else
        printf "%s not found. Installing...\n" "$package_name"
        if eval "$install_cmd"; then
            printf "%s installation completed.\n" "$package_name"
        else
            printf "Warning: Failed to install %s\n" "$package_name"
        fi
    fi
}

# Update before installing
sudo apt-get -qq update > /dev/null 2>&1

# Install dependencies
install_package "lazygit" "sudo apt-get -qq install -y lazygit > /dev/null 2>&1"
install_package "gcc" "sudo apt-get -qq install -y gcc > /dev/null 2>&1"
install_package "ripgrep" "sudo apt-get -qq install -y ripgrep > /dev/null 2>&1" "rg"
install_package "fd-find" "sudo apt-get -qq install -y fd-find > /dev/null 2>&1" "fdfind"

# Create symlink for fd (Ubuntu/Debian package installs as fdfind)
if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
    # Try to create symlink in user's local bin directory first (no sudo required)
    mkdir -p "$HOME/.local/bin"
    if ln -sf "$(which fdfind)" "$HOME/.local/bin/fd" 2>/dev/null; then
        printf "Created symlink: fd -> fdfind in ~/.local/bin\n"
        printf "Note: Ensure ~/.local/bin is in your PATH\n"
    else
        # Fall back to system-wide symlink if user bin fails
        if sudo ln -sf "$(which fdfind)" /usr/local/bin/fd 2>/dev/null; then
            printf "Created symlink: fd -> fdfind in /usr/local/bin\n"
        else
            printf "Warning: Could not create fd symlink\n"
        fi
    fi
fi

printf "\n"

# Check if neovim is installed
if ! command -v nvim &>/dev/null; then
    printf "neovim not found. Installing...\n"
    sudo apt-get -qq install -y neovim > /dev/null 2>&1
    printf "neovim successfully installed.\n\n"
else
    nvim_version=$(nvim --version 2>/dev/null | head -1 || echo "unknown")
    printf "neovim is already installed: %s\n\n" "$nvim_version"
fi

# Verify installation
if ! nvim --version &>/dev/null; then
    echo "Error: Neovim installation verification failed."
    exit 1
fi

# Create config directory if it doesn't exist
if [ ! -d "$CONFIG_DIR" ]; then
    mkdir -p "$CONFIG_DIR"
fi

# Set up symbolic link to dotfiles if they exist
if [ -d "$DOTFILES_NEOVIM_DIR" ] && [ ! -e "$NEOVIM_DIR" ]; then
    ln -s "$DOTFILES_NEOVIM_DIR" "$NEOVIM_DIR"
    printf "Symbolic link created: %s -> dotfiles\n" "$NEOVIM_DIR"
elif [ ! -d "$NEOVIM_DIR" ]; then
    mkdir -p "$NEOVIM_DIR"
    printf "Config directory created: %s\n\n" "$NEOVIM_DIR"
fi

printf "\n"
echo "✓ Neovim installed and configured successfully"
exit 0
