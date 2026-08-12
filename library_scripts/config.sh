#!/bin/bash

# Global configuration for setup scripts
# XDG Base Directory specification: https://specifications.freedesktop.org/basedir-spec/

# Base directories
export CONFIG_DIR="${CONFIG_DIR:-${HOME}/.config}"
export DOTFILES_DIR="${DOTFILES_DIR:-${HOME}/.dotfiles}"
export LOG_DIR="${LOG_DIR:-${HOME}/.logs}"
export BIN_DIR="${BIN_DIR:-${HOME}/.local/bin}"

# Tool-specific configuration directories
export FISH_DIR="${FISH_DIR:-$CONFIG_DIR/fish}"
export TMUX_DIR="${TMUX_DIR:-$CONFIG_DIR/tmux}"
export NEOVIM_DIR="${NEOVIM_DIR:-$CONFIG_DIR/nvim}"
export LAZYGIT_DIR="${LAZYGIT_DIR:-$CONFIG_DIR/lazygit}"
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
export FZF_DIR="${FZF_DIR:-$HOME/.fzf}"

# Dotfiles repository (override with DOTFILES_REPO env var)
export DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/omoinjm/.dotfiles.git}"
export DOTFILES_REPO_SSH="${DOTFILES_REPO_SSH:-git@github.com:omoinjm/.dotfiles.git}"

# Set to "true" to continue installation when dotfiles cannot be cloned
export DOTFILES_OPTIONAL="${DOTFILES_OPTIONAL:-false}"

# Installation visibility (set to "false" to hide plan or commands)
export SHOW_INSTALL_PLAN="${SHOW_INSTALL_PLAN:-true}"
export SHOW_INSTALL_COMMANDS="${SHOW_INSTALL_COMMANDS:-true}"

# Optional tools (set to "true" to install)
export INSTALL_PV="${INSTALL_PV:-true}"
export INSTALL_TERRAFORM="${INSTALL_TERRAFORM:-false}"
export INSTALL_NEBIUS_CLI="${INSTALL_NEBIUS_CLI:-false}"
export INSTALL_DOTNET="${INSTALL_DOTNET:-false}"

# Dotfiles layout (see dotfiles repo: home/.config/, platform/linux/shell/, install/link.sh)
refresh_dotfiles_paths() {
    local config_base

    if [ -d "$DOTFILES_DIR/home/.config" ]; then
        config_base="$DOTFILES_DIR/home/.config"
    elif [ -d "$DOTFILES_DIR/src/config" ]; then
        config_base="$DOTFILES_DIR/src/config"
    else
        config_base="$DOTFILES_DIR/home/.config"
    fi

    export DOTFILES_CONFIG_DIR="$config_base"
    export DOTFILES_FISH_DIR="$config_base/fish"
    export DOTFILES_NEOVIM_DIR="$config_base/nvim"
    export DOTFILES_TMUX_DIR="$config_base/tmux"
    export DOTFILES_LAZYGIT_DIR="$config_base/lazygit"
    export DOTFILES_LINUX_SHELL_DIR="$DOTFILES_DIR/platform/linux/shell"
    export DOTFILES_LEGACY_LINUX_SHELL_DIR="$DOTFILES_DIR/src/linux/shell"
}

refresh_dotfiles_paths
