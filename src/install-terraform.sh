#!/bin/bash

# Script: install-terraform.sh
# Purpose: Install Terraform infrastructure-as-code tool
# Exit codes: 0 = success, 1 = failure

set -e

TOOL_NAME="terraform"

echo "Installing $TOOL_NAME..."

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
    printf "terraform not found. Installing...\n"
    
    # Add HashiCorp GPG key
    wget -q -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    
    # Add HashiCorp repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null
    
    # Install terraform
    sudo apt-get -qq update > /dev/null 2>&1 && sudo apt-get -qq install -y terraform > /dev/null 2>&1
    printf "terraform successfully installed.\n\n"
else
    printf "terraform is already installed.\n\n"
fi

# Verify installation
if ! terraform -v &> /dev/null; then
    echo "Error: terraform installation verification failed."
    exit 1
fi

printf "Terraform version: $(terraform -v | head -1)\n\n"
echo "✓ $TOOL_NAME installed successfully"
exit 0
