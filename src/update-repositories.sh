#!/bin/bash

# Install prerequisites
sudo apt-get -qq update >/dev/null 2>&1
sudo apt-get -qq install -y software-properties-common >/dev/null 2>&1

# Git
sudo add-apt-repository -y ppa:git-core/ppa >/dev/null 2>&1

# Neovim
sudo add-apt-repository -y ppa:neovim-ppa/stable >/dev/null 2>&1
sudo add-apt-repository -y ppa:neovim-ppa/unstable >/dev/null 2>&1

# Tmux
# sudo add-apt-repository -y ppa:pi-rho/dev > /dev/null 2>&1
# sudo add-apt-repository --remove ppa:pi-rho/dev

# Fish
sudo add-apt-repository -y ppa:fish-shell/release-3 >/dev/null 2>&1

# Update the package list
sudo apt-get -qq update >/dev/null 2>&1
