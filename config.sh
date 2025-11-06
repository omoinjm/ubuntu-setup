#!/bin/bash

# Global configuration for setup scripts

# Directory where configuration files will be stored
CONFIG_DIR="$HOME/.config"

# Directory for user dotfiles
DOTFILES_DIR="/home/.dotfiles"
# Directory for tmux
TMUX_DIR="$DOTFILES_DIR/src/config/tmux"
# Directory for fish
FISH_DIR="$DOTFILES_DIR/src/config/fish"
# Directory for neovim
NEOVIM_DIR="$DOTFILES_DIR/src/config/nvim"

# Log directory
LOG_DIR="$HOME/.logs"

# Path to custom binaries (optional)
BIN_DIR="$HOME/.local/bin"

# Export all variables so child scripts can access them
export CONFIG_DIR DOTFILES_DIR TMUX_DIR FISH_DIR NEOVIM_DIR

