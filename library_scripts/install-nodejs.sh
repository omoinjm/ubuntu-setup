#!/bin/bash

# Script: install-nodejs.sh
# Purpose: Install Node.js runtime and nvm (Node Version Manager)
# Exit codes: 0 = success, 1 = failure

set -e

TOOL_NAME="nodejs"

echo "Installing $TOOL_NAME..."

# Install Node.js
if ! command -v node &> /dev/null; then
    printf "nodejs not found. Installing...\n"
    sudo apt-get -qq update > /dev/null 2>&1 && sudo apt-get -qq install -y nodejs > /dev/null 2>&1
    printf "nodejs successfully installed.\n\n"
else
  printf "nodejs is already installed.\n\n"
fi

# Verify installation
if ! node --version &> /dev/null; then
    echo "Error: nodejs installation verification failed."
    exit 1
fi

printf "Node.js version: $(node --version)\n"
printf "npm version: $(npm --version)\n\n"

echo "✓ $TOOL_NAME installed successfully"
exit 0


