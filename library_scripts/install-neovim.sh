#!/bin/bash

# Script: install-neovim.sh
# Purpose: Install Neovim and dependencies
# Exit codes: 0 = success, 1 = failure

set -e

# Load config if available
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [ -f "$ROOT_DIR/library_scripts/config.sh" ]; then
    # shellcheck source=library_scripts/config.sh
    source "$ROOT_DIR/library_scripts/config.sh"
else
    CONFIG_DIR="${HOME}/.config"
    NEOVIM_DIR="$CONFIG_DIR/nvim"
    BIN_DIR="${HOME}/.local/bin"
fi
# shellcheck source=library_scripts/helpers.sh
source "$ROOT_DIR/library_scripts/helpers.sh"

# Neovim version to install (pinned for reproducibility). Installed from the
# official GitHub release rather than apt/the neovim-ppa/stable PPA: apt's
# version varies wildly by distro release and architecture (e.g. older
# Ubuntu releases and some arm64 containers fall back to versions < 0.8.0),
# which breaks plugin managers like lazy.nvim that require >= 0.8.0.
NEOVIM_VERSION="v0.12.4"
NEOVIM_INSTALL_DIR="${NEOVIM_INSTALL_DIR:-$HOME/.local/opt/nvim}"

echo "Installing Neovim and dependencies..."

install_package() {
    local package_name="$1"
    local apt_package="$2"
    local check_cmd="${3:-$package_name}"

    if command -v "$check_cmd" &>/dev/null; then
        local version
        version=$(eval "$check_cmd --version 2>/dev/null || $check_cmd version 2>/dev/null || echo 'installed'")
        printf "%s is already installed: %s\n" "$package_name" "$version"
    else
        printf "%s not found. Installing...\n" "$package_name"
        if run_apt "Installing $package_name" -qq install -y "$apt_package"; then
            printf "%s installation completed.\n" "$package_name"
        else
            printf "Warning: Failed to install %s\n" "$package_name"
        fi
    fi
}

run_apt "Updating package lists" -qq update

install_package "lazygit" "lazygit"
install_package "gcc" "gcc"
install_package "ripgrep" "ripgrep" "rg"
install_package "fd-find" "fd-find" "fdfind"

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

# -----------------------------------------------------------------------------
# Function: detect_nvim_arch
# Description: Map `uname -m` to the architecture suffix used in Neovim's
#              GitHub release asset names (nvim-linux-<arch>.tar.gz)
# Returns: 0 on success (prints arch), 1 for unsupported architectures
# -----------------------------------------------------------------------------
detect_nvim_arch() {
    local machine
    machine="$(uname -m)"
    case "$machine" in
        x86_64|amd64) echo "x86_64" ;;
        aarch64|arm64) echo "arm64" ;;
        *)
            echo "Error: Unsupported architecture for Neovim: $machine" >&2
            return 1
            ;;
    esac
}

# -----------------------------------------------------------------------------
# Function: installed_nvim_version
# Description: Print the version of the Neovim binary managed by this script
# Returns: 0 and prints version if present, 1 otherwise
# -----------------------------------------------------------------------------
installed_nvim_version() {
    [ -x "$NEOVIM_INSTALL_DIR/bin/nvim" ] || return 1
    "$NEOVIM_INSTALL_DIR/bin/nvim" --version 2>/dev/null | head -1 | awk '{print $2}'
}

# -----------------------------------------------------------------------------
# Function: download_nvim
# Description: Download and extract the pinned Neovim release, then symlink
#              the binary into $BIN_DIR
# Returns: 0 on success, 1 on failure
# -----------------------------------------------------------------------------
download_nvim() {
    local arch temp_dir archive_name download_url
    temp_dir=$(mktemp -d)
    arch=$(detect_nvim_arch) || { rm -rf "$temp_dir"; return 1; }
    archive_name="nvim-linux-${arch}.tar.gz"
    download_url="https://github.com/neovim/neovim/releases/download/${NEOVIM_VERSION}/${archive_name}"

    if ! run_download "Downloading Neovim ${NEOVIM_VERSION}" "$download_url" "$temp_dir/$archive_name"; then
        echo "Error: Failed to download Neovim from GitHub"
        rm -rf "$temp_dir"
        return 1
    fi

    if ! tar -xzf "$temp_dir/$archive_name" -C "$temp_dir"; then
        echo "Error: Failed to extract Neovim archive"
        rm -rf "$temp_dir"
        return 1
    fi

    rm -rf "$NEOVIM_INSTALL_DIR"
    mkdir -p "$(dirname "$NEOVIM_INSTALL_DIR")"
    mv "$temp_dir/nvim-linux-${arch}" "$NEOVIM_INSTALL_DIR"
    rm -rf "$temp_dir"

    mkdir -p "$BIN_DIR"
    ln -sf "$NEOVIM_INSTALL_DIR/bin/nvim" "$BIN_DIR/nvim"
}

# Install (or replace a stale) Neovim if it doesn't match the pinned version
if [ "$(installed_nvim_version)" = "$NEOVIM_VERSION" ]; then
    printf "neovim is already installed: %s\n\n" "$NEOVIM_VERSION"
else
    printf "Installing Neovim %s...\n" "$NEOVIM_VERSION"
    if ! download_nvim; then
        echo "Error: Neovim installation failed."
        exit 1
    fi
    printf "neovim %s successfully installed to %s\n\n" "$NEOVIM_VERSION" "$NEOVIM_INSTALL_DIR"
fi

# Verify installation
if ! "$BIN_DIR/nvim" --version &>/dev/null; then
    echo "Error: Neovim installation verification failed."
    exit 1
fi

if ! command -v nvim &>/dev/null; then
    printf "Note: %s is not on your PATH yet. Add it, e.g.: export PATH=\"%s:\$PATH\"\n" "$BIN_DIR" "$BIN_DIR"
fi

# Create config directory if it doesn't exist
if [ ! -d "$CONFIG_DIR" ]; then
    mkdir -p "$CONFIG_DIR"
fi

# Set up symbolic link to dotfiles if they exist (fallback when install/link.sh was not run)
refresh_dotfiles_paths
if [ -d "$DOTFILES_NEOVIM_DIR" ] && [ ! -e "$NEOVIM_DIR" ]; then
    ln -s "$DOTFILES_NEOVIM_DIR" "$NEOVIM_DIR"
    printf "Symbolic link created: %s -> dotfiles\n" "$NEOVIM_DIR"
elif [ ! -d "$NEOVIM_DIR" ]; then
    mkdir -p "$NEOVIM_DIR"
    printf "Config directory created: %s\n\n" "$NEOVIM_DIR"
fi

if [ -d "$DOTFILES_LAZYGIT_DIR" ] && [ ! -e "$LAZYGIT_DIR" ]; then
    ln -s "$DOTFILES_LAZYGIT_DIR" "$LAZYGIT_DIR"
    printf "Symbolic link created: %s -> dotfiles\n" "$LAZYGIT_DIR"
fi

printf "\n"
echo "✓ Neovim installed and configured successfully"
exit 0
