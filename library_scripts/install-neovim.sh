#!/bin/bash

# Script: install-neovim.sh
# Purpose: Install Neovim and dependencies
# Exit codes: 0 = success, 1 = failure

set -e

# Load config if available
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [ -f "$ROOT_DIR/library_scripts/config.sh" ]; then
  source "$ROOT_DIR/library_scripts/config.sh"
else
  # Define defaults if config not available
  CONFIG_DIR="${HOME}/.config"
  NEOVIM_DIR="$CONFIG_DIR/nvim"
fi

echo "Installing Neovim and dependencies..."

# Function to check and install packages
install_package() {
  local package_name=$1
  local install_cmd=$2

  if ! command -v "$package_name" &>/dev/null; then
    printf "$package_name not found. Installing...\n"
    eval "$install_cmd" || true
    printf "$package_name installation completed.\n"
  else
    printf "$package_name is already installed.\n"
  fi
}

# Update before installing
sudo apt-get -qq update > /dev/null 2>&1

# Install dependencies
install_package "lazygit" "sudo apt-get -qq install -y lazygit > /dev/null 2>&1"
install_package "gcc" "sudo apt-get -qq install -y gcc > /dev/null 2>&1"
install_package "rg" "sudo apt-get -qq install -y ripgrep > /dev/null 2>&1"
install_package "fdfind" "sudo apt-get -qq install -y fd-find > /dev/null 2>&1"

# Create symlink for fd (Ubuntu/Debian package installs as fdfind)
if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
  sudo ln -sf "$(which fdfind)" /usr/local/bin/fd 2>/dev/null || true
  printf "Created symlink: fd -> fdfind\n"
fi

printf "\n"

# Check if neovim is installed
if ! command -v nvim &>/dev/null; then
  printf "neovim not found. Installing...\n"
  sudo apt-get -qq install -y neovim > /dev/null 2>&1
  printf "neovim successfully installed.\n\n"
else
  printf "neovim is already installed.\n\n"
fi

# Verify installation
if ! nvim --version &>/dev/null; then
  echo "Error: Neovim installation verification failed."
  exit 1
fi

# Create config directory if it doesn't exist
if [ ! -d "$CONFIG_DIR" ]; then
  mkdir -p "$CONFIG_DIR"
fi

# Set a symbolic link to the repo if dotfiles exist and link doesn't
if [ -d "$HOME/.dotfiles/nvim" ] && [ ! -e "$NEOVIM_DIR" ]; then
  ln -s "$HOME/.dotfiles/nvim" "$NEOVIM_DIR"
  printf "Symbolic link created: $CONFIG_DIR/nvim -> dotfiles\n"
elif [ ! -d "$NEOVIM_DIR" ]; then
  mkdir -p "$NEOVIM_DIR"
fi

printf "\n"
echo "✓ Neovim installed and configured successfully"
exit 0
