#!/bin/bash

# Script: uninstall.sh
# Purpose: Uninstall tools installed by setup
# Exit codes: 0 = success, 1 = failure

set -e

echo "═══════════════════════════════════════════════════════════════════"
echo "  Ubuntu Development Environment - Uninstall"
echo "═══════════════════════════════════════════════════════════════════"
echo
echo "⚠ Warning: This will uninstall the following tools:"
echo "  • tmux"
echo "  • Fish shell"
echo "  • Neovim"
echo "  • Node.js"
echo "  • Terraform"
echo "  • Nebius CLI"
echo
echo "Your dotfiles will NOT be deleted."
echo
read -p "Continue with uninstallation? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstallation cancelled."
    exit 0
fi

echo
echo "Uninstalling tools..."
echo

# Uninstall tmux
if command -v tmux &> /dev/null; then
    echo "Uninstalling tmux..."
    sudo apt-get remove -y tmux > /dev/null 2>&1 && echo "✓ tmux removed" || echo "⚠ Failed to remove tmux"
fi

# Uninstall Fish
if command -v fish &> /dev/null; then
    echo "Uninstalling Fish..."
    sudo apt-get remove -y fish > /dev/null 2>&1 && echo "✓ Fish removed" || echo "⚠ Failed to remove Fish"
fi

# Uninstall Neovim
if command -v nvim &> /dev/null; then
    echo "Uninstalling Neovim..."
    sudo apt-get remove -y neovim > /dev/null 2>&1 && echo "✓ Neovim removed" || echo "⚠ Failed to remove Neovim"
fi

# Uninstall Node.js
if command -v node &> /dev/null; then
    echo "Uninstalling Node.js..."
    sudo apt-get remove -y nodejs npm > /dev/null 2>&1 && echo "✓ Node.js removed" || echo "⚠ Failed to remove Node.js"
fi

# Uninstall Terraform
if command -v terraform &> /dev/null; then
    echo "Uninstalling Terraform..."
    sudo apt-get remove -y terraform > /dev/null 2>&1 && echo "✓ Terraform removed" || echo "⚠ Failed to remove Terraform"
fi

# Uninstall Nebius
if command -v nebius &> /dev/null; then
    echo "Uninstalling Nebius CLI..."
    # Try to remove the symlink
    sudo rm -f /usr/bin/nebius 2>/dev/null || true
    # Remove the binary
    rm -rf ~/.nebius 2>/dev/null || true
    echo "✓ Nebius CLI removed"
fi

# Clean up package lists
echo "Cleaning up package lists..."
sudo apt-get autoremove -y > /dev/null 2>&1
sudo apt-get autoclean -y > /dev/null 2>&1

echo
echo "═══════════════════════════════════════════════════════════════════"
echo "✓ Uninstallation complete!"
echo "═══════════════════════════════════════════════════════════════════"
echo
echo "Note: Config directories were preserved:"
echo "  • ~/.config/fish"
echo "  • ~/.config/tmux"
echo "  • ~/.dotfiles (if cloned)"
echo
echo "To remove these manually:"
echo "  rm -rf ~/.config/fish ~/.config/tmux ~/.dotfiles"
echo "═══════════════════════════════════════════════════════════════════"
echo

exit 0
