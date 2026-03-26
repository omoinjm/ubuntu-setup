#!/bin/bash

# Script: update-repositories.sh
# Purpose: Update system package repositories and add PPAs
# Exit codes: 0 = success, 1 = failure

set -e

echo "Updating system package repositories..."

# -----------------------------------------------------------------------------
# Function: install_prerequisites
# Description: Install software-properties-common for add-apt-repository
# Returns: 0 on success, 1 on failure
# -----------------------------------------------------------------------------
install_prerequisites() {
    sudo apt-get -qq update > /dev/null 2>&1
    sudo apt-get -qq install -y software-properties-common > /dev/null 2>&1
}

# -----------------------------------------------------------------------------
# Function: add_git_ppa
# Description: Add Git core PPA for latest Git version
# Returns: 0 on success
# -----------------------------------------------------------------------------
add_git_ppa() {
    echo "Adding Git PPA..."
    sudo add-apt-repository -y ppa:git-core/ppa > /dev/null 2>&1
}

# -----------------------------------------------------------------------------
# Function: add_neovim_ppa
# Description: Add Neovim stable and unstable PPAs
# Returns: 0 on success
# -----------------------------------------------------------------------------
add_neovim_ppa() {
    echo "Adding Neovim PPA..."
    sudo add-apt-repository -y ppa:neovim-ppa/stable > /dev/null 2>&1
    sudo add-apt-repository -y ppa:neovim-ppa/unstable > /dev/null 2>&1
}

# -----------------------------------------------------------------------------
# Function: add_fish_ppa
# Description: Add Fish shell release PPA
# Returns: 0 on success
# -----------------------------------------------------------------------------
add_fish_ppa() {
    echo "Adding Fish shell PPA..."
    sudo add-apt-repository -y ppa:fish-shell/release-3 > /dev/null 2>&1
}

# -----------------------------------------------------------------------------
# Function: add_dotnet_ppa
# Description: Add .NET backports PPA
# Returns: 0 on success
# -----------------------------------------------------------------------------
add_dotnet_ppa() {
    echo "Adding .NET PPA..."
    sudo add-apt-repository -y ppa:dotnet/backports > /dev/null 2>&1
}

# -----------------------------------------------------------------------------
# Function: update_package_list
# Description: Refresh package list after adding PPAs
# Returns: 0 on success, 1 on failure
# -----------------------------------------------------------------------------
update_package_list() {
    sudo apt-get -qq update > /dev/null 2>&1
}

# -----------------------------------------------------------------------------
# Main execution
# -----------------------------------------------------------------------------

# Install prerequisites
install_prerequisites

# Add PPAs for various tools
add_git_ppa
add_neovim_ppa
add_fish_ppa
add_dotnet_ppa

# Update package list after adding all PPAs
update_package_list

echo "✓ Repositories updated successfully"
exit 0
