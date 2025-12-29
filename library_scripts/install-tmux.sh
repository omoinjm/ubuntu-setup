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
  # Define defaults if config not available
  CONFIG_DIR="${HOME}/.config"
  TMUX_DIR="$CONFIG_DIR/tmux"
fi

echo "Installing tmux..."

# Check if tmux is installed
if ! command -v tmux &>/dev/null; then
  printf "tmux not found. Installing...\n"
  sudo apt-get -qq update > /dev/null 2>&1
  sudo apt-get -qq install -y tmux > /dev/null 2>&1
  printf "tmux successfully installed.\n\n"
else
  printf "tmux is already installed.\n\n"
fi

# Verify installation
if ! tmux -V &>/dev/null; then
  echo "Error: tmux installation verification failed."
  exit 1
fi

# Create config directory if it doesn't exist
if [ ! -d "$CONFIG_DIR" ]; then
  mkdir -p "$CONFIG_DIR"
fi

# Set a symbolic link to the repo if dotfiles exist and link doesn't
if [ -d "$HOME/.dotfiles/tmux" ] && [ ! -e "$TMUX_DIR" ]; then
  ln -s "$HOME/.dotfiles/tmux" "$TMUX_DIR"
elif [ ! -d "$TMUX_DIR" ]; then
  mkdir -p "$TMUX_DIR"
fi

echo "✓ tmux installed and configured successfully"
exit 0

# Set the path to the tmux config file
export TMUX_CONF="$TMUX_DIR/tmux.conf"

# Optionally, verify the path
printf "tmux config file set to: $TMUX_CONF \n\n"
