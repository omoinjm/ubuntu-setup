#!/bin/bash

# Global configuration for setup scripts

# DevContainer specific paths
if [ -z "${_DEVCONTAINER}" ]; then
  export _DEVCONTAINER=1
  CONFIG_DIR="${HOME}/.config"
  DOTFILES_DIR="${HOME}/.dotfiles"
  LOG_DIR="${HOME}/.logs"
  BIN_DIR="${HOME}/.local/bin"
else
  CONFIG_DIR="${HOME}/.config"
  DOTFILES_DIR="${HOME}/.dotfiles"
  LOG_DIR="${HOME}/.logs"
  BIN_DIR="${HOME}/.local/bin"
fi

# Directory for tmux
TMUX_DIR="$DOTFILES_DIR/src/config/tmux"
# Directory for fish
FISH_DIR="$DOTFILES_DIR/src/config/fish"
# Directory for neovim
NEOVIM_DIR="$DOTFILES_DIR/src/config/nvim"

# Export all variables so child scripts can access them
export CONFIG_DIR DOTFILES_DIR TMUX_DIR FISH_DIR NEOVIM_DIR LOG_DIR BIN_DIR
