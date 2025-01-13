#!/bin/bash

# Check if tmux is installed
if ! command -v tmux &> /dev/null; then
    echo "tmux not found. Installing..."
    sudo apt-get -qq update > /dev/null 2>&1 && sudo apt-get -qq install -y tmux > /dev/null 2>&1
    echo "tmux successfully installed!"
else
    echo "tmux is already installed!"
fi

# Set a symbolic link to the repo
ln -s $TMUX_DIR ~/.config/tmux

# Set the path to the tmux config file
export TMUX_CONF="$HOME/.config/tmux/tmux.conf"

# Optionally, verify the path
printf "tmux config file set to: $TMUX_CONF \n\n"
