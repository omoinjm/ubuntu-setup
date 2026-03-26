#!/bin/bash

# Script: install-tmux.sh
# Purpose: Install and configure tmux terminal multiplexer
# Exit codes: 0 = success, 1 = failure

set -e

# Load config if available
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [ -f "$ROOT_DIR/library_scripts/config.sh" ]; then
    source "$ROOT_DIR/library_scripts/config.sh"
else
    CONFIG_DIR="${HOME}/.config"
    TMUX_DIR="$CONFIG_DIR/tmux"
fi

echo "Installing tmux..."

# -----------------------------------------------------------------------------
# Function: check_tmux_installed
# Description: Check if tmux command is available
# Returns: 0 if installed, 1 otherwise
# -----------------------------------------------------------------------------
check_tmux_installed() {
    command -v tmux &>/dev/null
}

# -----------------------------------------------------------------------------
# Function: install_tmux_package
# Description: Install tmux via apt
# Returns: 0 on success, 1 on failure
# -----------------------------------------------------------------------------
install_tmux_package() {
    printf "tmux not found. Installing...\n"
    sudo apt-get -qq update > /dev/null 2>&1
    sudo apt-get -qq install -y tmux > /dev/null 2>&1
    printf "tmux successfully installed.\n\n"
}

# -----------------------------------------------------------------------------
# Function: verify_tmux_installation
# Description: Verify tmux is installed and working
# Returns: 0 if verification passes, 1 otherwise
# -----------------------------------------------------------------------------
verify_tmux_installation() {
    tmux -V &>/dev/null
}

# -----------------------------------------------------------------------------
# Function: setup_tmux_config_dir
# Description: Create tmux config directory or symlink to dotfiles
# Returns: 0 on success
# -----------------------------------------------------------------------------
setup_tmux_config_dir() {
    # Create base config directory if needed
    if [ ! -d "$CONFIG_DIR" ]; then
        mkdir -p "$CONFIG_DIR"
    fi

    # Check for dotfiles and create symlink if appropriate
    if [ -d "$DOTFILES_TMUX_DIR" ] && [ ! -e "$TMUX_DIR" ]; then
        ln -s "$DOTFILES_TMUX_DIR" "$TMUX_DIR"
        printf "Symbolic link created: %s -> dotfiles\n" "$TMUX_DIR"
    elif [ ! -d "$TMUX_DIR" ]; then
        mkdir -p "$TMUX_DIR"
        printf "Config directory created: %s\n\n" "$TMUX_DIR"
    fi
}

# -----------------------------------------------------------------------------
# Main execution
# -----------------------------------------------------------------------------

# Install tmux if needed
if check_tmux_installed; then
    tmux_version=$(tmux -V 2>/dev/null || echo "unknown")
    printf "tmux is already installed: %s\n\n" "$tmux_version"
else
    install_tmux_package
fi

# Verify installation
if ! verify_tmux_installation; then
    echo "Error: tmux installation verification failed."
    exit 1
fi

# Setup configuration directory
setup_tmux_config_dir

# Display config file path
TMUX_CONF="$TMUX_DIR/tmux.conf"
printf "tmux config file set to: %s\n\n" "$TMUX_CONF"

echo "✓ tmux installed and configured successfully"
exit 0
