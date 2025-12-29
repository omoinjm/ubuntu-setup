#!/bin/bash

# Script: install-fish.sh
# Purpose: Install and configure Fish shell with enhancements
# Exit codes: 0 = success, 1 = failure

set -e

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
FISH_DIR="$CONFIG_DIR/fish"
FISH_CONF="$FISH_DIR/config.fish"
TOOL_NAME="fish"

echo "Installing $TOOL_NAME..."

# Install Fish shell
if ! command -v fish &> /dev/null; then
    printf "fish not found. Installing...\n"
    sudo apt-get -qq update > /dev/null 2>&1 && sudo apt-get -qq install -y fish > /dev/null 2>&1
    printf "fish successfully installed.\n\n"
else
    printf "fish is already installed.\n\n"
fi

# Verify installation
if ! fish --version &> /dev/null; then
    echo "Error: fish installation verification failed."
    exit 1
fi

# Setup dotfiles symlink if it doesn't exist
if [ -d "$HOME/.dotfiles/fish" ] && [ ! -e "$FISH_DIR" ]; then
    printf "Linking fish config from dotfiles...\n"
    ln -s "$HOME/.dotfiles/fish" "$FISH_DIR"
elif [ ! -d "$FISH_DIR" ]; then
    printf "Creating fish config directory...\n"
    mkdir -p "$FISH_DIR"
fi

# Create config file if it doesn't exist
if [ ! -f "$FISH_CONF" ]; then
    touch "$FISH_CONF"
fi

# Backup original config
cp "$FISH_CONF" "$FISH_CONF.backup" 2>/dev/null || true

# Install oh-my-posh
if ! command -v oh-my-posh &> /dev/null; then
    printf "Installing oh-my-posh...\n"
    curl -sS https://ohmyposh.dev/install.sh | bash > /dev/null 2>&1
    printf "oh-my-posh successfully installed.\n\n"
else
    printf "oh-my-posh is already installed.\n\n"
fi

# Setup oh-my-posh theme if not already configured
if ! grep -q "oh-my-posh" "$FISH_CONF" 2>/dev/null; then
    THEME="tonybaloney"
    THEME_URL="https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/$THEME.omp.json"
    echo "oh-my-posh init fish --config \"$THEME_URL\" | source" >> "$FISH_CONF"
fi

# Install lsd (enhanced ls)
if ! command -v lsd &> /dev/null; then
    printf "Installing LSD (LSDeluxe)...\n"
    # Try package manager first
    if sudo apt-get install -y lsd > /dev/null 2>&1; then
        printf "lsd installed from repository.\n\n"
    else
        printf "lsd package not available, skipping.\n\n"
    fi
else
    printf "lsd is already installed.\n\n"
fi

echo "✓ $TOOL_NAME configured successfully"
exit 0
