#!/bin/bash

# Load config if available
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [ -f "$ROOT_DIR/config.sh" ]; then
    source "$ROOT_DIR/config.sh"
fi

# Check if fish is installed
if ! command -v fish &> /dev/null; then
    printf "fish not found. Installing...\n"
    sudo apt-get -qq update > /dev/null 2>&1 && sudo apt-get -qq install -y fish > /dev/null 2>&1
    printf "fish successfully installed.\n\n"
else
    printf "fish is already installed.\n\n"
fi

# Set a symbolic link to the repo
ln -s $FISH_DIR "$CONFIG_DIR/fish"

FISH_CONF="$FISH_DIR/config.fish"

# Remove default oh-my-posh color theme
head -n -2 $FISH_CONF > temp_file && mv temp_file $FISH_CONF

# Setup default theme
THEME="tonybaloney"
THEME_URL="https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/$THEME.omp.json"
TEXT_APPEND="oh-my-posh init fish --config \"$THEME_URL\" | source"

echo "$TEXT_APPEND" | tee -a $FISH_CONF > /dev/null 

# Install oh-my-posh
if ! command -v oh-my-posh &> /dev/null; then
  printf "Installing oh-my-posh...\n" 
  curl -s https://ohmyposh.dev/install.sh | bash -s > /dev/null 2>&1 
  printf "oh-my-posh successfully installed.\n\n"
else
  printf "oh-my-posh is already installed.\n\n"
fi

# Install lsd (icon files / folders)
if ! command -v lsd &> /dev/null; then
  printf "Installing LSD (LSDeluxe)...\n"

  curl -Lo $CONFIG_DIR/lsd-v1.1.5-x86_64-unknown-linux-gnu.tar.gz \
    https://github.com/lsd-rs/lsd/releases/download/v1.1.5/lsd-v1.1.5-x86_64-unknown-linux-gnu.tar.gz

  tar -xzf $CONFIG_DIR/lsd-v1.1.5-x86_64-unknown-linux-gnu.tar.gz -C $CONFIG_DIR

  sudo mv $CONFIG_DIR/lsd-v1.1.5-x86_64-unknown-linux-gnu/lsd /usr/local/bin/

  rm -rf $CONFIG_DIR/lsd-v1.1.5-x86_64-unknown-linux-gnu.tar.gz \
         $CONFIG_DIR/lsd-v1.1.5-x86_64-unknown-linux-gnu

  printf "LSD successfully installed.\n\n"
else
  printf "LSD is already installed.\n\n"
fi

