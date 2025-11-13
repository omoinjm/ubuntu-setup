#!/bin/bash

# Exit on any error
set -e

# Source the library scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIBRARY_DIR="$SCRIPT_DIR/library_scripts"

# Source configuration
source "$LIBRARY_DIR/config.sh"

# Install options
INSTALL_TERRAFORM="${INSTALLTERRAFORM:-false}"
INSTALL_NEBUIS="${INSTALLNEBUIS:-false}"

echo "Starting custom development environment setup..."

# Update repositories
echo "Updating package repositories..."
bash "$LIBRARY_DIR/update-repositories.sh"

# Setup dotfiles
echo "Setting up dotfiles..."
bash "$LIBRARY_DIR/setup-dotfiles.sh"

# Install tmux
echo "Installing tmux..."
bash "$LIBRARY_DIR/install-tmux.sh"

# Install fish
echo "Installing fish..."
bash "$LIBRARY_DIR/install-fish.sh"

# Install neovim
echo "Installing neovim..."
bash "$LIBRARY_DIR/install-neovim.sh"

# Install nodejs
echo "Installing nodejs..."
bash "$LIBRARY_DIR/install-nodejs.sh"

# Conditional installations
if [ "$INSTALL_TERRAFORM" = "true" ]; then
  echo "Installing terraform..."
  bash "$LIBRARY_DIR/install-terraform.sh"
fi

if [ "$INSTALL_NEBUIS" = "true" ]; then
  echo "Installing nebius CLI..."
  bash "$LIBRARY_DIR/install-nebius-cli.sh"
fi

echo "Custom development environment setup complete!"
