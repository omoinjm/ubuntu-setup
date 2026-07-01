#!/bin/bash

# Script: uninstall.sh
# Purpose: Uninstall tools installed by setup
# Exit codes: 0 = success, 1 = failure

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=library_scripts/config.sh
source "$SCRIPT_DIR/library_scripts/config.sh"

echo "═══════════════════════════════════════════════════════════════════"
echo "  Ubuntu Development Environment - Uninstall"
echo "═══════════════════════════════════════════════════════════════════"
echo
echo "⚠ Warning: This will uninstall the following tools:"
echo "  • tmux"
echo "  • Fish shell"
echo "  • Neovim"
echo "  • NVM and Node.js"
echo "  • fzf"
echo "  • Nerd Fonts (user install)"
if [ "$INSTALL_TERRAFORM" = "true" ] || command -v terraform &>/dev/null; then
    echo "  • Terraform"
fi
if [ "$INSTALL_NEBIUS_CLI" = "true" ] || command -v nebius &>/dev/null; then
    echo "  • Nebius CLI"
fi
if [ "$INSTALL_DOTNET" = "true" ] || command -v dotnet &>/dev/null; then
    echo "  • .NET SDK"
fi
echo
echo "Your dotfiles at $DOTFILES_DIR will NOT be deleted."
echo
read -r -p "Continue with uninstallation? (y/N) " -n 1 REPLY
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstallation cancelled."
    exit 0
fi

echo
echo "Uninstalling tools..."
echo

remove_apt_package() {
    local package="$1"
    local label="${2:-$package}"
    if dpkg -l "$package" &>/dev/null; then
        echo "Uninstalling $label..."
        sudo apt-get remove -y "$package" > /dev/null 2>&1 && echo "✓ $label removed" || echo "⚠ Failed to remove $label"
    fi
}

if command -v tmux &>/dev/null; then
    remove_apt_package tmux tmux
fi

if command -v fish &>/dev/null; then
    remove_apt_package fish "Fish shell"
fi

if command -v nvim &>/dev/null; then
    remove_apt_package neovim Neovim
fi

if [ -d "$NVM_DIR" ]; then
    echo "Removing NVM..."
    rm -rf "$NVM_DIR"
    echo "✓ NVM removed"
fi

if [ -d "$FZF_DIR" ]; then
    echo "Removing fzf..."
    rm -rf "$FZF_DIR"
    rm -f "$HOME/.fzf.bash" "$HOME/.fzf.zsh"
    echo "✓ fzf removed"
fi

if [ -f "$HOME/.local/share/fonts/DroidSansMNerdFont-Regular.otf" ]; then
    echo "Removing Nerd Font..."
    rm -f "$HOME/.local/share/fonts/DroidSansMNerdFont-Regular.otf"
    if command -v fc-cache &>/dev/null; then
        fc-cache -f "$HOME/.local/share/fonts" &>/dev/null || true
    fi
    echo "✓ Nerd Font removed"
fi

if command -v oh-my-posh &>/dev/null; then
    echo "Removing oh-my-posh..."
    sudo rm -f /usr/local/bin/oh-my-posh 2>/dev/null || true
    rm -f "$HOME/.local/bin/oh-my-posh" 2>/dev/null || true
    echo "✓ oh-my-posh removed"
fi

if command -v terraform &>/dev/null; then
    remove_apt_package terraform Terraform
    sudo rm -f /etc/apt/sources.list.d/hashicorp.list 2>/dev/null || true
    sudo rm -f /usr/share/keyrings/hashicorp-archive-keyring.gpg 2>/dev/null || true
fi

if command -v nebius &>/dev/null || [ -d "$HOME/.nebius" ]; then
    echo "Removing Nebius CLI..."
    sudo rm -f /usr/bin/nebius /usr/local/bin/nebius 2>/dev/null || true
    rm -rf "$HOME/.nebius" 2>/dev/null || true
    echo "✓ Nebius CLI removed"
fi

if command -v dotnet &>/dev/null; then
    echo "Removing .NET SDK packages..."
    mapfile -t dotnet_packages < <(dpkg -l | awk '/^ii\s+dotnet-/ {print $2}')
    if [ "${#dotnet_packages[@]}" -gt 0 ]; then
        sudo apt-get remove -y "${dotnet_packages[@]}" > /dev/null 2>&1 && echo "✓ .NET packages removed" || echo "⚠ Failed to remove some .NET packages"
    fi
fi

echo "Cleaning up package lists..."
sudo apt-get autoremove -y > /dev/null 2>&1
sudo apt-get autoclean -y > /dev/null 2>&1

echo
echo "═══════════════════════════════════════════════════════════════════"
echo "✓ Uninstallation complete!"
echo "═══════════════════════════════════════════════════════════════════"
echo
echo "Note: Config directories were preserved:"
echo "  • $FISH_DIR"
echo "  • $TMUX_DIR"
echo "  • $NEOVIM_DIR"
echo "  • $DOTFILES_DIR (if cloned)"
echo
echo "To remove these manually:"
echo "  rm -rf $FISH_DIR $TMUX_DIR $NEOVIM_DIR $DOTFILES_DIR"
echo "═══════════════════════════════════════════════════════════════════"
echo

exit 0
