#!/bin/bash

# Personal Package Archive
./src/update-repositories.sh

# Load shared configuration
if [ -f "./config.sh" ]; then
  source ./config.sh
else
  echo "config.sh not found. Please create it before running install.sh"
  exit 1
fi

# Pull dotfiles from GitHub
echo "Pulling repository from GitHub..."
if ! ./src/setup-dotfiles.sh; then
  echo "Failed to pull dotfiles. Exiting."
  exit 1
fi

# Install tmux
echo "Running tmux installation script..."
if ! ./src/install-tmux.sh; then
  echo "Failed to install tmux. Exiting."
  exit 1
fi

# Install fish
echo "Running fish installation script..."
if ! ./src/install-fish.sh; then
  echo "Failed to install fish. Exiting."
  exit 1
fi

# Install neovim
echo "Running neovim installation script..."
if ! ./src/install-neovim.sh; then
  echo "Failed to install neovim. Exiting."
  exit 1
fi

## Install nodejs
echo "Running nodejs installation script..."
if ! ./src/install-nodejs.sh; then
  echo "Failed to install nodejs. Exiting."
  exit 1
fi

## Install terraform
#echo "Running terraform installation script..."
#if ! ./src/install-terraform.sh; then
#    echo "Failed to install terraform. Exiting."
#    exit 1
#fi
#
## Install nebius
#echo "Running nebius installation script..."
#if ! ./src/install-nebius-cli.sh; then
#    echo "Failed to install nebius. Exiting."
#    exit 1
#fi

echo "Setup complete."
