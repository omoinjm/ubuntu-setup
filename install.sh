#!/bin/bash

# Script: install.sh
# Purpose: Main orchestration script for Ubuntu development environment setup
# Exit codes: 0 = success, 1 = failure

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Source logging functions
if [ -f "$SCRIPT_DIR/lib/logging.sh" ]; then
    source "$SCRIPT_DIR/lib/logging.sh"
    LOGGING_ENABLED=true
else
    LOGGING_ENABLED=false
fi

# Print section headers
print_section() {
    echo -e "${BLUE}→ $1${NC}"
}

# Print success
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Print error
print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Print header
echo "═══════════════════════════════════════════════════════════════════"
echo "  Ubuntu Development Environment Setup"
echo "═══════════════════════════════════════════════════════════════════"
echo

# Load configuration
print_section "Loading configuration..."
source "$SCRIPT_DIR/library_scripts/config.sh"
print_success "Configuration loaded"
echo

# Create required directories
print_section "Creating required directories..."
mkdir -p "$CONFIG_DIR" "$DOTFILES_DIR" "$LOG_DIR" "$BIN_DIR"
sudo chown -R "$USER:$USER" "$CONFIG_DIR" 2>/dev/null || true
print_success "Directories created"
echo

# Check prerequisites first
print_section "Checking system prerequisites..."
if ! "$SCRIPT_DIR/library_scripts/check-prerequisites.sh"; then
    print_error "Prerequisites check failed. Exiting."
    if [ "$LOGGING_ENABLED" = true ]; then
        end_logging "FAILED" "Prerequisites check failed"
    fi
    exit 1
fi
print_success "Prerequisites verified"
echo

# Update system repositories
print_section "Updating system repositories..."
if ! "$SCRIPT_DIR/library_scripts/update-repositories.sh"; then
    print_error "Failed to update repositories."
    if [ "$LOGGING_ENABLED" = true ]; then
        end_logging "FAILED" "Failed to update repositories"
    fi
    exit 1
fi
print_success "Repositories updated"
echo

# Setup dotfiles
print_section "Setting up dotfiles..."
if ! "$SCRIPT_DIR/library_scripts/setup-dotfiles.sh"; then
    print_error "Failed to setup dotfiles."
    if [ "$LOGGING_ENABLED" = true ]; then
        end_logging "FAILED" "Failed to setup dotfiles"
    fi
    exit 1
fi
print_success "Dotfiles configured"
echo

# Install tmux
print_section "Installing tmux..."
if ! "$SCRIPT_DIR/library_scripts/install-tmux.sh"; then
    print_error "Failed to install tmux."
    if [ "$LOGGING_ENABLED" = true ]; then
        end_logging "FAILED" "Failed to install tmux"
    fi
    exit 1
fi
print_success "tmux installed"
echo

# Install fish
print_section "Installing Fish shell..."
if ! "$SCRIPT_DIR/library_scripts/install-fish.sh"; then
    print_error "Failed to install Fish shell."
    if [ "$LOGGING_ENABLED" = true ]; then
        end_logging "FAILED" "Failed to install Fish shell"
    fi
    exit 1
fi
print_success "Fish shell installed"
echo

# Install neovim
print_section "Installing Neovim..."
if ! "$SCRIPT_DIR/library_scripts/install-neovim.sh"; then
    print_error "Failed to install Neovim."
    if [ "$LOGGING_ENABLED" = true ]; then
        end_logging "FAILED" "Failed to install Neovim"
    fi
    exit 1
fi
print_success "Neovim installed"
echo

# Install NVM
print_section "Installing NVM..."
if ! "$SCRIPT_DIR/library_scripts/install-nvm.sh"; then
    print_error "Failed to install NVM."
    if [ "$LOGGING_ENABLED" = true ]; then
        end_logging "FAILED" "Failed to install NVM"
    fi
    exit 1
fi
print_success "NVM installed"
echo

# Install fzf
print_section "Installing fzf (fuzzy finder)..."
if ! "$SCRIPT_DIR/library_scripts/install-fzf.sh"; then
    print_error "Failed to install fzf."
    if [ "$LOGGING_ENABLED" = true ]; then
        end_logging "FAILED" "Failed to install fzf"
    fi
    exit 1
fi
print_success "fzf installed"
echo

# Install .NET SDK (optional - uncomment if needed)
# print_section "Installing .NET SDK..."
# if ! "$SCRIPT_DIR/library_scripts/install-dotnet.sh"; then
#     print_error "Failed to install .NET SDK."
#     if [ "$LOGGING_ENABLED" = true ]; then
#         end_logging "FAILED" "Failed to install .NET SDK"
#     fi
#     exit 1
# fi
# print_success ".NET SDK installed"
# echo

# Installation complete
echo "═══════════════════════════════════════════════════════════════════"
echo -e "${GREEN}✓ Setup complete!${NC}"
echo "═══════════════════════════════════════════════════════════════════"
echo
echo "Installed tools:"
tmux -V 2>/dev/null && print_success "tmux: $(tmux -V)" || echo "  tmux: not found"
fish --version 2>/dev/null && print_success "fish: $(fish --version)" || echo "  fish: not found"
nvim --version 2>/dev/null | head -1 && print_success "neovim: $(nvim --version | head -1)" || echo "  neovim: not found"
if [ -f "$NVM_DIR/nvm.sh" ]; then
    # shellcheck disable=SC1090
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm --version >/dev/null 2>&1 && print_success "nvm: $(nvm --version)" || echo "  nvm: not loaded"
    node --version 2>/dev/null && print_success "node: $(node --version)" || echo "  node: not installed (run: nvm install --lts)"
else
    echo "  nvm: not found"
    echo "  node: not found"
fi
if [ -x "$HOME/.fzf/bin/fzf" ]; then
    print_success "fzf: $($HOME/.fzf/bin/fzf --version 2>/dev/null | head -1)"
else
    echo "  fzf: not found"
fi

echo
echo "Next steps:"
echo "  1. Set Fish as your default shell: chsh -s /usr/bin/fish"
echo "  2. Logout and login for changes to take effect"
echo "  3. Review your dotfiles: ~/.dotfiles"
echo "═══════════════════════════════════════════════════════════════════"
echo

if [ "$LOGGING_ENABLED" = true ]; then
    end_logging "SUCCESS" "Installation completed successfully"
fi

exit 0
