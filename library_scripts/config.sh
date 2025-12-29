#!/bin/bash

# Global configuration for setup scripts
# XDG Base Directory specification: https://specifications.freedesktop.org/basedir-spec/

export CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
export DOTFILES_DIR="${HOME}/.dotfiles"
export LOG_DIR="${HOME}/.logs"
export BIN_DIR="${HOME}/.local/bin"

# Configuration directories (from dotfiles structure)
export FISH_DIR="$CONFIG_DIR/fish"
export TMUX_DIR="$CONFIG_DIR/tmux"
export NEOVIM_DIR="$CONFIG_DIR/nvim"
# Directory for fish
FISH_DIR="$DOTFILES_DIR/src/config/fish"
# Directory for neovim
NEOVIM_DIR="$DOTFILES_DIR/src/config/nvim"

# Export all variables so child scripts can access them
export CONFIG_DIR DOTFILES_DIR TMUX_DIR FISH_DIR NEOVIM_DIR LOG_DIR BIN_DIR
