#!/bin/bash

# Load config if available
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [ -f "$ROOT_DIR/config.sh" ]; then
  source "$ROOT_DIR/config.sh"
fi

# Check if tmux is installed
if ! command -v tmux &>/dev/null; then
  echo "tmux not found. Installing..."
  sudo apt-get -qq install -y tmux >/dev/null 2>&1
  echo "tmux successfully installed!"
else
  echo "tmux is already installed!"
fi

# Set a symbolic link to the repo
ln -s $TMUX_DIR "$CONFIG_DIR/tmux"

# Set the path to the tmux config file
export TMUX_CONF="$TMUX_DIR/tmux.conf"

# Optionally, verify the path
printf "tmux config file set to: $TMUX_CONF \n\n"
