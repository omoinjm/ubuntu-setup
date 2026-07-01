#!/bin/bash

# Script: install-terraform.sh
# Purpose: Install Terraform from HashiCorp apt repository
# Exit codes: 0 = success, 1 = failure

set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=library_scripts/helpers.sh
source "$ROOT_DIR/library_scripts/helpers.sh"

TOOL_NAME="terraform"

echo "Installing $TOOL_NAME..."

if command -v terraform &>/dev/null; then
    printf "terraform is already installed: %s\n\n" "$(terraform --version | head -1)"
    exit 0
fi

if ! command -v gpg &>/dev/null; then
    run_apt "Installing GPG tools" -qq update
    run_apt "Installing GPG tools" -qq install -y gnupg software-properties-common
fi

if [ ! -f /usr/share/keyrings/hashicorp-archive-keyring.gpg ]; then
    with_spinner "Adding HashiCorp GPG key" bash -c \
        'curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg'
fi

if [ ! -f /etc/apt/sources.list.d/hashicorp.list ]; then
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(. /etc/os-release && echo "$VERSION_CODENAME") main" \
        | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null
fi

run_apt "Refreshing package lists" -qq update
run_apt "Installing Terraform" -qq install -y terraform

if ! command -v terraform &>/dev/null; then
    echo "Error: terraform installation verification failed."
    exit 1
fi

printf "terraform installed: %s\n\n" "$(terraform --version | head -1)"
echo "✓ $TOOL_NAME installed successfully"
exit 0
