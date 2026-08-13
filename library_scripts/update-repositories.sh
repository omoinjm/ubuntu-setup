#!/bin/bash

# Script: update-repositories.sh
# Purpose: Update system package repositories and add PPAs
# Exit codes: 0 = success, 1 = failure

set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=library_scripts/helpers.sh
source "$ROOT_DIR/library_scripts/helpers.sh"

echo "Updating system package repositories..."

# -----------------------------------------------------------------------------
# Function: install_prerequisites
# Description: Install software-properties-common for add-apt-repository
# Returns: 0 on success, 1 on failure
# -----------------------------------------------------------------------------
install_prerequisites() {
    run_apt "Updating package lists" -qq update
    run_apt "Installing repository tools" -qq install -y software-properties-common
}

add_git_ppa() {
    echo "Adding Git PPA..."
    with_spinner "Adding Git PPA" sudo add-apt-repository -y ppa:git-core/ppa
}

add_fish_ppa() {
    echo "Adding Fish shell PPA..."
    with_spinner "Adding Fish shell PPA" sudo add-apt-repository -y ppa:fish-shell/release-3
}

add_dotnet_ppa() {
    echo "Adding .NET PPA..."
    with_spinner "Adding .NET PPA" sudo add-apt-repository -y ppa:dotnet/backports
}

update_package_list() {
    run_apt "Refreshing package lists" -qq update
}

# -----------------------------------------------------------------------------
# Main execution
# -----------------------------------------------------------------------------

# Install prerequisites
install_prerequisites

# Add PPAs for various tools
add_git_ppa
add_fish_ppa
add_dotnet_ppa

# Update package list after adding all PPAs
update_package_list

echo "✓ Repositories updated successfully"
exit 0
