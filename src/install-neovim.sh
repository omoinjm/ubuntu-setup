#!/bin/bash

# Load config if available
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [ -f "$ROOT_DIR/config.sh" ]; then
  source "$ROOT_DIR/config.sh"
fi

# Function to check and install packages
install_package() {
  local package_name=$1
  local install_cmd=$2

  if ! command -v "$package_name" &>/dev/null; then
    printf "$package_name not found. Installing...\n"
    eval "$install_cmd"
    printf "$package_name successfully installed.\n"
  else
    printf "$package_name is already installed.\n"
  fi
}

printf "Installing Neovim dependencies...\n\n"

# Install lazygit
install_package "lazygit" "sudo apt-get -qq install -y lazygit > /dev/null 2>&1"

# Install C compiler (gcc) for nvim-treesitter
install_package "gcc" "sudo apt-get -qq install -y gcc > /dev/null 2>&1"

# Install ripgrep for live grep
install_package "rg" "sudo apt-get -qq install -y ripgrep > /dev/null 2>&1"

# Install fd-find for finding files
install_package "fdfind" "sudo apt-get -qq install -y fd-find > /dev/null 2>&1"

# Create symlink for fd (Ubuntu/Debian package installs as fdfind)
if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
  sudo ln -s $(which fdfind) /usr/local/bin/fd
  printf "Created symlink: fd -> fdfind\n"
fi

printf "\n"

# Check if neovim is installed
if ! command -v nvim &>/dev/null; then
  printf "neovim not found. Installing...\n"
  sudo apt-get -qq install -y neovim >/dev/null 2>&1
  printf "neovim successfully installed.\n\n"
else
  printf "neovim is already installed.\n\n"
fi

# Set a symbolic link to the repo
ln -s "$NEOVIM_DIR" "$CONFIG_DIR/nvim"

printf "Symbolic link created: $CONFIG_DIR/nvim -> $NEOVIM_DIR\n"
