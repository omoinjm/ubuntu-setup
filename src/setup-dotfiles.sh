#!/bin/bash

# Load config if available
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [ -f "$ROOT_DIR/config.sh" ]; then
    source "$ROOT_DIR/config.sh"
fi

# --- Ensure CONFIG_DIR exists ---
if [ ! -d "$CONFIG_DIR" ]; then
    printf "Directory %s does not exist. Creating it now...\n" "$CONFIG_DIR"
    mkdir -p "$CONFIG_DIR"
    printf "Directory created successfully.\n"
else
    printf "Directory %s already exists. Skipping creation.\n" "$CONFIG_DIR"
fi

# --- Fix permissions ---
printf "Setting ownership for %s to user %s...\n" "$CONFIG_DIR" "$USER"
sudo chown -R "$USER:$USER" "$CONFIG_DIR"
printf "Ownership updated successfully.\n"

# --- Clone dotfiles repo ---
if [ ! -d "$DOTFILES_DIR" ]; then
    printf "Cloning dotfiles repository into %s...\n" "$DOTFILES_DIR"
    git clone git@github.com:omoinjm/.dotfiles.git "$DOTFILES_DIR"
    printf "Dotfiles repository cloned successfully.\n\n"
else
    printf "Dotfiles repository already exists. Skipping clone.\n\n"
fi

# --- Ensure ~/.config exists ---
if [ ! -d "$HOME/.config" ]; then
    printf "Config directory not found. Creating directory...\n\n"
    mkdir -p "$HOME/.config"
else
    printf "Config directory already exists.\n\n"
fi

printf "Setup completed successfully.\n"