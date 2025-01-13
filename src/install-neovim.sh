#!/bin/bash

# Check if neovim is installed
if ! command -v nvim &> /dev/null; then
    printf "neovim not found. Installing...\n"
    sudo apt-get -qq update > /dev/null 2>&1 && sudo apt-get -qq install -y neovim > /dev/null 2>&1
    printf "neovim successfully installed.\n\n"
else
    printf "neovim is already installed.\n\n"
fi

# Set a symbolic link to the repo
ln -s $NEOVIM_DIR ~/.config/nvim
