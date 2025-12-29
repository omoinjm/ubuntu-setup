#!/bin/bash

# Script: install-neovim.sh
# Purpose: Install and configure Neovim text editor
# Exit codes: 0 = success, 1 = failure

set -e

TOOL_NAME="neovim"

echo "Installing $TOOL_NAME..."

# Check if neovim is installed
if ! command -v nvim &> /dev/null; then
    printf "neovim not found. Installing...\n"
    sudo apt-get -qq update > /dev/null 2>&1 && sudo apt-get -qq install -y neovim > /dev/null 2>&1
    printf "neovim successfully installed.\n\n"
else
    printf "neovim is already installed.\n\n"
fi

# Verify installation
if ! nvim --version &> /dev/null; then
    echo "Error: neovim installation verification failed."
    exit 1
fi

echo "✓ $TOOL_NAME verified"
exit 0
