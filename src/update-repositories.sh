#!/bin/bash

# Script: update-repositories.sh
# Purpose: Update system package repositories and add PPAs
# Exit codes: 0 = success, 1 = failure

set -e

echo "Updating system package repositories..."

# Install prerequisites
sudo apt-get -qq update > /dev/null 2>&1
sudo apt-get -qq install -y software-properties-common > /dev/null 2>&1

# Git
echo "Adding Git PPA..."
sudo add-apt-repository -y ppa:git-core/ppa > /dev/null 2>&1

# Neovim
echo "Adding Neovim PPA..."
sudo add-apt-repository -y ppa:neovim-ppa/stable > /dev/null 2>&1

# Tmux
echo "Adding Tmux PPA..."
sudo add-apt-repository -y ppa:pi-rho/dev > /dev/null 2>&1

echo "✓ Repositories updated successfully"
exit 0

# Fish
sudo add-apt-repository -y ppa:fish-shell/release-3 > /dev/null 2>&1

# Update the package list
sudo apt-get -qq update > /dev/null 2>&1
