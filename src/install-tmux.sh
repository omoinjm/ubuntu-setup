#!/bin/bash

# Script: install-tmux.sh
# Purpose: Install and configure tmux terminal multiplexer
# Exit codes: 0 = success, 1 = failure

set -e

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
TMUX_DIR="$CONFIG_DIR/tmux"
TMUX_CONF="$TMUX_DIR/tmux.conf"
TOOL_NAME="tmux"

echo "Installing $TOOL_NAME..."

# Install tmux
if ! command -v tmux &> /dev/null; then
    printf "tmux not found. Installing...\n"
    sudo apt-get -qq update > /dev/null 2>&1 && sudo apt-get -qq install -y tmux > /dev/null 2>&1
    printf "tmux successfully installed.\n\n"
else
    printf "tmux is already installed.\n\n"
fi

# Verify installation
if ! tmux -V &> /dev/null; then
    echo "Error: tmux installation verification failed."
    exit 1
fi

# Setup dotfiles symlink if it doesn't exist
if [ -d "$HOME/.dotfiles/tmux" ] && [ ! -e "$TMUX_DIR" ]; then
    printf "Linking tmux config from dotfiles...\n"
    ln -s "$HOME/.dotfiles/tmux" "$TMUX_DIR"
elif [ ! -d "$TMUX_DIR" ]; then
    printf "Creating tmux config directory...\n"
    mkdir -p "$TMUX_DIR"
fi

echo "✓ $TOOL_NAME installed and configured"
exit 0
