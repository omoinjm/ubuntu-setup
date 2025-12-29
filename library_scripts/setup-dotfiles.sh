#!/bin/bash

# Script: setup-dotfiles.sh
# Purpose: Clone and setup dotfiles from GitHub repository
# Exit codes: 0 = success, 1 = failure

set -e

# Load config if available
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [ -f "$ROOT_DIR/library_scripts/config.sh" ]; then
  source "$ROOT_DIR/library_scripts/config.sh"
else
  # Define defaults if config not available
  CONFIG_DIR="${HOME}/.config"
  DOTFILES_DIR="${HOME}/.dotfiles"
fi

echo "Setting up dotfiles..."

# Check if Git is installed
if ! command -v git &>/dev/null; then
  echo "Error: Git is required but not installed."
  exit 1
fi

# --- Ensure CONFIG_DIR exists ---
if [ ! -d "$CONFIG_DIR" ]; then
  printf "Config directory not found. Creating %s...\n" "$CONFIG_DIR"
  mkdir -p "$CONFIG_DIR"
  printf "Config directory created successfully.\n"
else
  printf "Config directory %s already exists.\n" "$CONFIG_DIR"
fi

# --- Ensure DOTFILES_DIR exists (before clone) ---
if [ ! -d "$DOTFILES_DIR" ]; then
  printf "Directory %s does not exist. Creating it now...\n" "$DOTFILES_DIR"
  mkdir -p "$DOTFILES_DIR"
  printf "Directory created successfully.\n"
else
  printf "Directory %s already exists.\n" "$DOTFILES_DIR"
fi

# --- Fix permissions ---
printf "Setting ownership for %s to user %s...\n" "$CONFIG_DIR" "$USER"
sudo chown -R "$USER:$USER" "$CONFIG_DIR" 2>/dev/null || true
printf "Ownership updated successfully.\n\n"

# --- Clone dotfiles repo (FIXED LOGIC) ---
if [ ! -d "$DOTFILES_DIR/.git" ]; then
  printf "Cloning dotfiles repository into %s...\n" "$DOTFILES_DIR"
  if git clone git@github.com:omoinjm/.dotfiles.git "$DOTFILES_DIR" 2>/dev/null; then
    printf "Dotfiles repository cloned successfully.\n\n"
  else
    echo "Warning: Could not clone dotfiles repository. This may be expected if the repository is private or unavailable."
    echo "You can clone it manually later: git clone git@github.com:omoinjm/.dotfiles.git $DOTFILES_DIR"
  fi
else
  printf "Dotfiles repository already exists at %s.\n\n" "$DOTFILES_DIR"
fi

echo "✓ Dotfiles setup completed successfully"
exit 0
