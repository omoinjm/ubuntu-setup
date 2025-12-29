#!/bin/bash

# Script: setup-dotfiles.sh
# Purpose: Clone and setup dotfiles from GitHub repository
# Exit codes: 0 = success, 1 = failure

set -e

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
DOTFILES_DIR="$HOME/.dotfiles"
DOTFILES_REPO="git@github.com:omoinjm/.dotfiles.git"

echo "Setting up dotfiles..."

# Check if Git is installed
if ! command -v git &> /dev/null; then
    echo "Error: Git is required but not installed."
    exit 1
fi

# Create config directory if it doesn't exist
if [ ! -d "$CONFIG_DIR" ]; then
    printf "Config directory not found. Creating %s...\n" "$CONFIG_DIR"
    mkdir -p "$CONFIG_DIR"
else
    printf "Config directory %s already exists.\n" "$CONFIG_DIR"
fi

# Ensure correct ownership
printf "Setting ownership for %s to user %s...\n" "$CONFIG_DIR" "$USER"
sudo chown -R "$USER:$USER" "$CONFIG_DIR" 2>/dev/null || true

# Clone dotfiles if they don't exist
if [ ! -d "$DOTFILES_DIR" ]; then
    printf "Dotfiles not found. Cloning from %s...\n" "$DOTFILES_REPO"
    if git clone "$DOTFILES_REPO" "$DOTFILES_DIR" 2>/dev/null; then
        printf "Dotfiles repository cloned successfully.\n\n"
    else
        echo "Warning: Could not clone dotfiles repository. This may be expected if the repository is private or unavailable."
        echo "You can clone it manually later: git clone $DOTFILES_REPO $DOTFILES_DIR"
    fi
else
    printf "Dotfiles repository already exists at %s.\n" "$DOTFILES_DIR"
    printf "To update, run: git -C %s pull\n\n" "$DOTFILES_DIR"
fi

echo "✓ Dotfiles setup completed"
exit 0
