#!/bin/bash

# Personal Package Archive
./src/update-repositories.sh

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

echo "Setup complete."
