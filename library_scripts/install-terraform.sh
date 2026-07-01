#!/bin/bash

# Script: install-terraform.sh
# Purpose: Install Terraform from HashiCorp apt repository
# Exit codes: 0 = success, 1 = failure

set -e

TOOL_NAME="terraform"

echo "Installing $TOOL_NAME..."

if command -v terraform &>/dev/null; then
    printf "terraform is already installed: %s\n\n" "$(terraform --version | head -1)"
    exit 0
fi

if ! command -v gpg &>/dev/null; then
    sudo apt-get -qq update > /dev/null 2>&1
    sudo apt-get -qq install -y gnupg software-properties-common > /dev/null 2>&1
fi

if [ ! -f /usr/share/keyrings/hashicorp-archive-keyring.gpg ]; then
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
fi

if [ ! -f /etc/apt/sources.list.d/hashicorp.list ]; then
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(. /etc/os-release && echo "$VERSION_CODENAME") main" \
        | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null
fi

sudo apt-get -qq update > /dev/null 2>&1
sudo apt-get -qq install -y terraform > /dev/null 2>&1

if ! command -v terraform &>/dev/null; then
    echo "Error: terraform installation verification failed."
    exit 1
fi

printf "terraform installed: %s\n\n" "$(terraform --version | head -1)"
echo "✓ $TOOL_NAME installed successfully"
exit 0
