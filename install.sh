#!/bin/bash

# Script: install.sh
# Purpose: Main orchestration script for Ubuntu development environment setup
# Exit codes: 0 = success, 1 = failure

set -e

# Source logging functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Note: logging will be added in future versions
# source "$SCRIPT_DIR/lib/logging.sh"

echo "═══════════════════════════════════════════════════════════════════"
echo "  Ubuntu Development Environment Setup"
echo "═══════════════════════════════════════════════════════════════════"
echo

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print section headers
print_section() {
    echo -e "${BLUE}→ $1${NC}"
}

# Function to print success
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Function to print error
print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Check prerequisites first
print_section "Checking system prerequisites..."
if ! ./library_scripts/check-prerequisites.sh; then
    print_error "Prerequisites check failed. Exiting."
    exit 1
fi
print_success "Prerequisites verified"
echo

# Update system repositories
print_section "Updating system repositories..."
if ! ./library_scripts/update-repositories.sh; then
    print_error "Failed to update repositories."
    exit 1
fi
print_success "Repositories updated"
echo

# Setup dotfiles
print_section "Setting up dotfiles..."
if ! ./library_scripts/setup-dotfiles.sh; then
    print_error "Failed to setup dotfiles."
    exit 1
fi
print_success "Dotfiles configured"
echo

# Install tmux
print_section "Installing tmux..."
if ! ./library_scripts/install-tmux.sh; then
    print_error "Failed to install tmux."
    exit 1
fi
print_success "tmux installed"
echo

# Install fish
print_section "Installing Fish shell..."
if ! ./library_scripts/install-fish.sh; then
    print_error "Failed to install Fish shell."
    exit 1
fi
print_success "Fish shell installed"
echo

# Install neovim
print_section "Installing Neovim..."
if ! ./library_scripts/install-neovim.sh; then
    print_error "Failed to install Neovim."
    exit 1
fi
print_success "Neovim installed"
echo

# Install nodejs
print_section "Installing Node.js..."
if ! ./library_scripts/install-nodejs.sh; then
    print_error "Failed to install Node.js."
    exit 1
fi
print_success "Node.js installed"
echo

# Install dotnet
print_section "Installing .NET SDK..."
if ! ./library_scripts/install-dotnet.sh; then
    print_error "Failed to install .NET SDK."
    exit 1
fi
print_success ".NET SDK installed"
echo

# Install terraform
print_section "Installing Terraform..."
if ! ./library_scripts/install-terraform.sh; then
    print_error "Failed to install Terraform."
    exit 1
fi
print_success "Terraform installed"
echo

# Install nebius CLI
print_section "Installing Nebius CLI..."
if ! ./library_scripts/install-nebius-cli.sh; then
    print_error "Failed to install Nebius CLI."
    exit 1
fi
print_success "Nebius CLI installed"
echo

echo "═══════════════════════════════════════════════════════════════════"
echo -e "${GREEN}✓ Setup complete!${NC}"
echo "═══════════════════════════════════════════════════════════════════"
echo
echo "Installed tools:"
tmux -V 2>/dev/null || echo "  tmux: installation may have failed"
fish --version 2>/dev/null || echo "  fish: installation may have failed"
nvim --version | head -1 2>/dev/null || echo "  neovim: installation may have failed"
node --version 2>/dev/null || echo "  node: installation may have failed"
terraform version 2>/dev/null | head -1 || echo "  terraform: installation may have failed"
echo
echo "Next steps:"
echo "  1. Verify all tools are installed: tmux -V, fish --version, etc."
echo "  2. Change default shell: chsh -s /usr/bin/fish"
echo "  3. Review and update dotfiles configuration"
echo "═══════════════════════════════════════════════════════════════════"
echo

exit 0
