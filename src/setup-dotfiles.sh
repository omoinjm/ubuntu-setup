#!/bin/bash

# Check if the directory exists
if [ ! -d "$CONFIG_DIR" ]; then
    printf "Directory %s does not exist. Creating it now...\n" "$CONFIG_DIR"
    mkdir -p "$CONFIG_DIR"
    printf "Directory created successfully.\n"
else
    printf "Directory %s already exists. Skipping creation.\n" "$CONFIG_DIR"
fi

# Change ownership of the directory to the current user
printf "Setting ownership for %s to user %s...\n" "$CONFIG_DIR" "$USER"
sudo chown -R "$USER:$USER" "$CONFIG_DIR"
printf "Ownership updated successfully.\n"

if [ ! -d "$DOTFILES_DIR" ]; then
    git clone git@github.com:omoinjm/.dotfiles.git "$DOTFILES_DIR"
    printf "Dotfiles repository cloned successfully.\n\n"
else
    printf "Dotfiles repository already exists. Skipping clone.\n\n"
fi

# Check if the config directory exists, if not, create it
if [ ! -d "$HOME/.config" ]; then
    printf "Config directory not found. Creating directory...\n\n"
    mkdir -p "$HOME/.config"
fi
