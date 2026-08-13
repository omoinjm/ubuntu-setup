#!/bin/bash

# Script: install-zsh.sh
# Purpose: Install and configure Zsh shell with oh-my-posh theme (opt-in;
#          gated by INSTALL_ZSH=true in install.sh)
# Exit codes: 0 = success, 1 = failure

set -e

# Load config if available
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [ -f "$ROOT_DIR/library_scripts/config.sh" ]; then
    # shellcheck source=library_scripts/config.sh
    source "$ROOT_DIR/library_scripts/config.sh"
else
    CONFIG_DIR="${HOME}/.config"
    ZSH_DIR="$CONFIG_DIR/zsh"
fi
# shellcheck source=library_scripts/helpers.sh
source "$ROOT_DIR/library_scripts/helpers.sh"
# shellcheck source=library_scripts/install-oh-my-posh.sh
source "$ROOT_DIR/library_scripts/install-oh-my-posh.sh"

ZSHRC="${HOME}/.zshrc"

echo "Installing zsh shell..."

# -----------------------------------------------------------------------------
# Function: check_zsh_installed
# Description: Check if zsh is available
# Returns: 0 if installed, 1 otherwise
# -----------------------------------------------------------------------------
check_zsh_installed() {
    command -v zsh &>/dev/null
}

# -----------------------------------------------------------------------------
# Function: install_zsh
# Description: Install zsh from the standard Ubuntu repository (no PPA needed)
# Returns: 0 on success, 1 on failure
# -----------------------------------------------------------------------------
install_zsh() {
    printf "zsh not found. Installing...\n"
    run_apt "Updating package lists" -qq update
    run_apt "Installing Zsh shell" -qq install -y zsh
    printf "zsh successfully installed.\n\n"
}

# -----------------------------------------------------------------------------
# Function: verify_zsh_installation
# Description: Verify zsh is installed and working
# Returns: 0 if verification passes, 1 otherwise
# -----------------------------------------------------------------------------
verify_zsh_installation() {
    zsh --version &>/dev/null
}

# -----------------------------------------------------------------------------
# Function: setup_zsh_config_dir
# Description: Create zsh config directory or symlink to dotfiles (mirrors
#              setup_fish_config_dir in install-fish.sh). The dotfiles repo
#              has no zsh directory today, so this typically just creates an
#              empty $ZSH_DIR — the real defaults live in ~/.zshrc, written
#              by create_zshrc_fallback below.
# Returns: 0 on success
# -----------------------------------------------------------------------------
setup_zsh_config_dir() {
    if [ ! -d "$CONFIG_DIR" ]; then
        mkdir -p "$CONFIG_DIR"
    fi

    refresh_dotfiles_paths
    if [ -d "$DOTFILES_ZSH_DIR" ] && [ ! -e "$ZSH_DIR" ]; then
        ln -s "$DOTFILES_ZSH_DIR" "$ZSH_DIR"
        printf "Symbolic link created: %s -> dotfiles\n" "$ZSH_DIR"
    elif [ ! -d "$ZSH_DIR" ]; then
        mkdir -p "$ZSH_DIR"
        printf "Config directory created: %s\n\n" "$ZSH_DIR"
    fi
}

# -----------------------------------------------------------------------------
# Function: create_zshrc_fallback
# Description: Create a minimal ~/.zshrc if none exists, sourcing any
#              dotfiles-managed *.zsh files from $ZSH_DIR
# -----------------------------------------------------------------------------
create_zshrc_fallback() {
    if [ -f "$ZSHRC" ]; then
        return 0
    fi
    cat > "$ZSHRC" << EOF
# Managed baseline created by ubuntu-setup (install-zsh.sh)
# Safe to edit; re-running install.sh only appends missing blocks
# guarded by grep checks, it never overwrites this file.

# Source additional zsh config from \$ZSH_DIR if present (dotfiles-managed)
if [ -d "$ZSH_DIR" ]; then
    for _zsh_conf_file in "$ZSH_DIR"/*.zsh; do
        [ -r "\$_zsh_conf_file" ] && source "\$_zsh_conf_file"
    done
    unset _zsh_conf_file
fi
EOF
    printf "Created fallback ~/.zshrc\n"
}

# -----------------------------------------------------------------------------
# Function: setup_zsh_local_bin_path
# Description: Idempotently ensure ~/.local/bin is on PATH in ~/.zshrc
# -----------------------------------------------------------------------------
setup_zsh_local_bin_path() {
    if ! grep -q '\.local/bin' "$ZSHRC" 2>/dev/null; then
        {
            echo ""
            echo "# ~/.local/bin on PATH"
            echo 'export PATH="$HOME/.local/bin:$PATH"'
        } >> "$ZSHRC"
        printf "Added ~/.local/bin to PATH in ~/.zshrc\n"
    else
        printf "~/.local/bin already on PATH in ~/.zshrc\n"
    fi
}

# -----------------------------------------------------------------------------
# Function: setup_zsh_nvm
# Description: Idempotently ensure NVM is sourced in ~/.zshrc
# -----------------------------------------------------------------------------
setup_zsh_nvm() {
    if ! grep -q 'NVM_DIR' "$ZSHRC" 2>/dev/null; then
        {
            echo ""
            echo "# NVM"
            echo 'export NVM_DIR="$HOME/.nvm"'
            echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"'
        } >> "$ZSHRC"
        printf "Added NVM sourcing to ~/.zshrc\n"
    else
        printf "NVM already configured in ~/.zshrc\n"
    fi
}

# -----------------------------------------------------------------------------
# Function: setup_zsh_lsd_alias
# Description: Alias ls -> lsd, only if lsd is already installed
# -----------------------------------------------------------------------------
setup_zsh_lsd_alias() {
    if ! command -v lsd &>/dev/null; then
        return 0
    fi
    if ! grep -q "alias ls=.lsd." "$ZSHRC" 2>/dev/null; then
        echo "alias ls='lsd'" >> "$ZSHRC"
        printf "Added lsd alias to ~/.zshrc\n"
    else
        printf "lsd alias already configured in ~/.zshrc\n"
    fi
}

# -----------------------------------------------------------------------------
# Main execution
# -----------------------------------------------------------------------------

if check_zsh_installed; then
    zsh_version=$(zsh --version 2>/dev/null || echo "unknown")
    printf "zsh is already installed: %s\n\n" "$zsh_version"
else
    install_zsh
fi

if ! verify_zsh_installation; then
    echo "Error: zsh installation verification failed."
    exit 1
fi

setup_zsh_config_dir
create_zshrc_fallback
setup_zsh_local_bin_path
setup_zsh_nvm

ensure_oh_my_posh_installed || true
if check_oh_my_posh_installed; then
    setup_oh_my_posh_in_rc zsh "$ZSHRC"
else
    printf "Skipping oh-my-posh theme setup because oh-my-posh is not installed.\n\n"
fi

setup_zsh_lsd_alias

echo "✓ zsh shell configured successfully"
exit 0
