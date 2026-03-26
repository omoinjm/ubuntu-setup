#!/bin/bash

# Global configuration for setup scripts
# XDG Base Directory specification: https://specifications.freedesktop.org/basedir-spec/

# Base directories
export CONFIG_DIR="${HOME}/.config"
export DOTFILES_DIR="${HOME}/.dotfiles"
export LOG_DIR="${HOME}/.logs"
export BIN_DIR="${HOME}/.local/bin"

# Tool-specific configuration directories
# Use environment variables if set, otherwise use defaults
export FISH_DIR="${FISH_DIR:-$CONFIG_DIR/fish}"
export TMUX_DIR="${TMUX_DIR:-$CONFIG_DIR/tmux}"
export NEOVIM_DIR="${NEOVIM_DIR:-$CONFIG_DIR/nvim}"
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

# Dotfiles subdirectories (used when dotfiles repo is cloned)
export DOTFILES_FISH_DIR="$DOTFILES_DIR/src/config/fish"
export DOTFILES_NEOVIM_DIR="$DOTFILES_DIR/src/config/nvim"
export DOTFILES_TMUX_DIR="$DOTFILES_DIR/src/config/tmux"
