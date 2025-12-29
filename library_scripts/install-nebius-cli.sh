#!/bin/bash

# Script: install-nebius-cli.sh
# Purpose: Install Nebius cloud CLI tool
# Exit codes: 0 = success, 1 = failure

set -e

echo "Installing Nebius CLI..."

# Check if nebius is installed
if ! command -v nebius &>/dev/null; then
  printf "nebius not found. Installing...\n"
  
  # Download to temp file for security
  installer_script=$(mktemp)
  trap "rm -f $installer_script" EXIT
  
  if curl -sSL https://storage.eu-north1.nebius.cloud/cli/install.sh > "$installer_script" 2>/dev/null; then
    bash "$installer_script" > /dev/null 2>&1 || true
    
    # Create symlink if binary exists
    if [ -f "$HOME/.nebius/bin/nebius" ]; then
      sudo ln -sf "$HOME/.nebius/bin/nebius" /usr/bin/nebius 2>/dev/null || true
      printf "nebius successfully installed.\n\n"
    else
      echo "Warning: nebius binary not found after installation"
    fi
  else
    echo "Warning: Could not download nebius installer"
  fi
else
  printf "nebius is already installed.\n\n"
fi

# Verify installation (non-fatal)
if command -v nebius &>/dev/null; then
  echo "✓ nebius installed successfully"
  exit 0
else
  echo "Warning: nebius may not be properly installed, but continuing..."
  exit 0
fi
