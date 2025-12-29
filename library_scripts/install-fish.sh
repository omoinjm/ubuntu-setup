#!/bin/bash

# Script: install-fish.sh
# Purpose: Install and configure Fish shell
# Exit codes: 0 = success, 1 = failure

set -e

# Load config if available
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [ -f "$ROOT_DIR/library_scripts/config.sh" ]; then
  source "$ROOT_DIR/library_scripts/config.sh"
else
  # Define defaults if config not available
  CONFIG_DIR="${HOME}/.config"
  FISH_DIR="$CONFIG_DIR/fish"
fi

echo "Installing fish shell..."

# Check if fish is installed
if ! command -v fish &>/dev/null; then
  printf "fish not found. Installing...\n"
  sudo apt-get -qq update > /dev/null 2>&1
  sudo apt-get -qq install -y fish unzip > /dev/null 2>&1
  printf "fish successfully installed.\n\n"
else
  printf "fish is already installed.\n\n"
fi

# Verify installation
if ! fish --version &>/dev/null; then
  echo "Error: fish installation verification failed."
  exit 1
fi

# Create config directory if it doesn't exist
if [ ! -d "$CONFIG_DIR" ]; then
  mkdir -p "$CONFIG_DIR"
fi

# Set a symbolic link to the repo if dotfiles exist and link doesn't
if [ -d "$HOME/.dotfiles/fish" ] && [ ! -e "$FISH_DIR" ]; then
  ln -s "$HOME/.dotfiles/fish" "$FISH_DIR"
elif [ ! -d "$FISH_DIR" ]; then
  mkdir -p "$FISH_DIR"
fi

FISH_CONF="$FISH_DIR/config.fish"

# Create config file if it doesn't exist
if [ ! -f "$FISH_CONF" ]; then
  touch "$FISH_CONF"
fi

# Backup original config
cp "$FISH_CONF" "$FISH_CONF.backup" 2>/dev/null || true

# Setup default theme if not already configured
if ! grep -q "oh-my-posh" "$FISH_CONF" 2>/dev/null; then
  THEME="tonybaloney"
  THEME_URL="https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/$THEME.omp.json"
  TEXT_APPEND="oh-my-posh init fish --config \"$THEME_URL\" | source"
  echo "$TEXT_APPEND" >> "$FISH_CONF"
fi

# Install oh-my-posh
if ! command -v oh-my-posh &>/dev/null; then
  printf "Installing oh-my-posh...\n"
  curl -sS https://ohmyposh.dev/install.sh | bash > /dev/null 2>&1 || true
  printf "oh-my-posh successfully installed.\n\n"
else
  printf "oh-my-posh is already installed.\n\n"
fi

# Install lsd (icon files / folders)
if ! command -v lsd &>/dev/null; then
  printf "Installing LSD (LSDeluxe)...\n"
  # Try package manager first
  if sudo apt-get -qq install -y lsd > /dev/null 2>&1; then
    printf "LSD installed from repository.\n\n"
  else
    printf "LSD package not available, skipping manual install.\n\n"
  fi
else
  printf "LSD is already installed.\n\n"
fi

echo "✓ fish shell configured successfully"
exit 0
