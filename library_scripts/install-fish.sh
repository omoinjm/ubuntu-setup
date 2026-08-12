#!/bin/bash

# Script: install-fish.sh
# Purpose: Install and configure Fish shell with oh-my-posh theme
# Exit codes: 0 = success, 1 = failure

set -e

# Load config if available
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [ -f "$ROOT_DIR/library_scripts/config.sh" ]; then
    # shellcheck source=library_scripts/config.sh
    source "$ROOT_DIR/library_scripts/config.sh"
else
    CONFIG_DIR="${HOME}/.config"
    FISH_DIR="$CONFIG_DIR/fish"
fi
# shellcheck source=library_scripts/helpers.sh
source "$ROOT_DIR/library_scripts/helpers.sh"

# oh-my-posh theme configuration
OH_MY_POSH_THEME="tonybaloney"

echo "Installing fish shell..."

# -----------------------------------------------------------------------------
# Function: check_fish_installed
# Description: Check if fish shell is available
# Returns: 0 if installed, 1 otherwise
# -----------------------------------------------------------------------------
check_fish_installed() {
    command -v fish &>/dev/null
}

# -----------------------------------------------------------------------------
# Function: install_fish
# Description: Install fish shell and unzip dependency
# Returns: 0 on success, 1 on failure
# -----------------------------------------------------------------------------
install_fish() {
    printf "fish not found. Installing...\n"
    run_apt "Updating package lists" -qq update
    run_apt "Installing Fish shell" -qq install -y fish unzip
    printf "fish successfully installed.\n\n"
}

# -----------------------------------------------------------------------------
# Function: verify_fish_installation
# Description: Verify fish is installed and working
# Returns: 0 if verification passes, 1 otherwise
# -----------------------------------------------------------------------------
verify_fish_installation() {
    fish --version &>/dev/null
}

# -----------------------------------------------------------------------------
# Function: setup_fish_config_dir
# Description: Create fish config directory or symlink to dotfiles
# Returns: 0 on success
# -----------------------------------------------------------------------------
setup_fish_config_dir() {
    # Create base config directory if needed
    if [ ! -d "$CONFIG_DIR" ]; then
        mkdir -p "$CONFIG_DIR"
    fi

    # Check for dotfiles and create symlink if appropriate (fallback when install/link.sh was not run)
    refresh_dotfiles_paths
    if [ -d "$DOTFILES_FISH_DIR" ] && [ ! -e "$FISH_DIR" ]; then
        ln -s "$DOTFILES_FISH_DIR" "$FISH_DIR"
        printf "Symbolic link created: %s -> dotfiles\n" "$FISH_DIR"
    elif [ ! -d "$FISH_DIR" ]; then
        mkdir -p "$FISH_DIR"
        printf "Config directory created: %s\n\n" "$FISH_DIR"
    fi
}

# -----------------------------------------------------------------------------
# Function: create_fish_config
# Description: Create fish config file if it doesn't exist
# Returns: 0 on success
# -----------------------------------------------------------------------------
create_fish_config() {
    local fish_conf="$FISH_DIR/config.fish"

    # Create config file if it doesn't exist
    if [ ! -f "$fish_conf" ]; then
        touch "$fish_conf"
        printf "Created fish config: %s\n" "$fish_conf"
    fi

    # Backup original config
    cp "$fish_conf" "$fish_conf.backup" 2>/dev/null || true
}

# -----------------------------------------------------------------------------
# Function: setup_oh_my_posh_theme
# Description: Configure oh-my-posh theme in fish config
# Arguments: Theme name
# Returns: 0 on success
# -----------------------------------------------------------------------------
setup_oh_my_posh_theme() {
    local theme="$1"
    local fish_conf="$FISH_DIR/config.fish"
    local theme_url="https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/${theme}.omp.json"
    local theme_init="oh-my-posh init fish --config \"${theme_url}\" | source"

    # Check if theme is already configured
    if grep -q "oh-my-posh" "$fish_conf" 2>/dev/null; then
        printf "oh-my-posh theme already configured in %s\n" "$fish_conf"
        return 0
    fi

    # Add theme configuration
    echo "$theme_init" >> "$fish_conf"
    printf "Added oh-my-posh theme (%s) configuration to %s\n" "$theme" "$fish_conf"
}

# -----------------------------------------------------------------------------
# Function: check_oh_my_posh_installed
# Description: Check if oh-my-posh is available
# Returns: 0 if installed, 1 otherwise
# -----------------------------------------------------------------------------
check_oh_my_posh_installed() {
    command -v oh-my-posh &>/dev/null
}

# -----------------------------------------------------------------------------
# Function: install_oh_my_posh
# Description: Install oh-my-posh prompt theme engine
# Returns: 0 on success (warning on failure is acceptable)
# -----------------------------------------------------------------------------
install_oh_my_posh() {
    printf "Installing oh-my-posh...\n"
    if with_spinner "Installing oh-my-posh" bash -c 'curl -fsSL https://ohmyposh.dev/install.sh | bash'; then
        printf "oh-my-posh successfully installed.\n\n"
        return 0
    else
        printf "Warning: oh-my-posh installation failed. Continuing without it.\n\n"
        return 1
    fi
}

# -----------------------------------------------------------------------------
# Function: check_lsd_installed
# Description: Check if lsd (LSDeluxe) is available
# Returns: 0 if installed, 1 otherwise
# -----------------------------------------------------------------------------
check_lsd_installed() {
    command -v lsd &>/dev/null
}

# -----------------------------------------------------------------------------
# Function: install_lsd
# Description: Install lsd (ls with icons)
# Returns: 0 on success (warning on failure is acceptable)
# -----------------------------------------------------------------------------
install_lsd() {
    printf "Installing LSD (LSDeluxe)...\n"

    if run_apt "Installing LSD" -qq install -y lsd; then
        printf "LSD installed from repository.\n\n"
        return 0
    else
        printf "Warning: LSD package not available from repository.\n"
        printf "To install manually: https://github.com/lsd-rs/lsd#installation\n\n"
        return 1
    fi
}

# -----------------------------------------------------------------------------
# Main execution
# -----------------------------------------------------------------------------

# Install fish shell if needed
if check_fish_installed; then
    fish_version=$(fish --version 2>/dev/null || echo "unknown")
    printf "fish is already installed: %s\n\n" "$fish_version"
else
    install_fish
fi

# Verify installation
if ! verify_fish_installation; then
    echo "Error: fish installation verification failed."
    exit 1
fi

# Setup configuration directory and file
setup_fish_config_dir
create_fish_config

# Install oh-my-posh before writing theme configuration
if ! check_oh_my_posh_installed; then
    install_oh_my_posh || true
else
    posh_version=$(oh-my-posh --version 2>/dev/null || echo "unknown")
    printf "oh-my-posh is already installed: %s\n\n" "$posh_version"
fi

# Configure oh-my-posh theme only when the binary is available
if check_oh_my_posh_installed; then
    setup_oh_my_posh_theme "$OH_MY_POSH_THEME"
else
    printf "Skipping oh-my-posh theme setup because oh-my-posh is not installed.\n\n"
fi

# Install lsd if needed
if ! check_lsd_installed; then
    install_lsd
else
    lsd_version=$(lsd --version 2>/dev/null || echo "unknown")
    printf "LSD is already installed: %s\n\n" "$lsd_version"
fi

echo "✓ fish shell configured successfully"
exit 0
