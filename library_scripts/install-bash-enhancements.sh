#!/bin/bash

# Script: install-bash-enhancements.sh
# Purpose: Enhance the default bash shell (oh-my-posh prompt, PATH, NVM
#          sourcing, lsd alias). Always runs — bash is already the OS
#          default shell, this only appends idempotent config to ~/.bashrc.
# Exit codes: 0 = success, 1 = failure

set -e

# Load config if available
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [ -f "$ROOT_DIR/library_scripts/config.sh" ]; then
    # shellcheck source=library_scripts/config.sh
    source "$ROOT_DIR/library_scripts/config.sh"
fi
# shellcheck source=library_scripts/helpers.sh
source "$ROOT_DIR/library_scripts/helpers.sh"
# shellcheck source=library_scripts/install-oh-my-posh.sh
source "$ROOT_DIR/library_scripts/install-oh-my-posh.sh"

BASH_RC="${HOME}/.bashrc"

echo "Enhancing bash shell..."

# NOTE: any block appended below must go at the END of ~/.bashrc. Ubuntu's
# default ~/.bashrc starts with a non-interactive early-return guard
# (`case $- in *i*) ;; *) return;; esac`) — appending is what already keeps
# fzf's own bash integration (install-fzf.sh) working correctly, since PATH
# and prompt setup only need to apply to interactive shells anyway.

# -----------------------------------------------------------------------------
# Function: setup_bash_local_bin_path
# Description: Idempotently ensure ~/.local/bin is on PATH in ~/.bashrc
# -----------------------------------------------------------------------------
setup_bash_local_bin_path() {
    if ! grep -q '\.local/bin' "$BASH_RC" 2>/dev/null; then
        {
            echo ""
            echo "# ~/.local/bin on PATH"
            echo 'export PATH="$HOME/.local/bin:$PATH"'
        } >> "$BASH_RC"
        printf "Added ~/.local/bin to PATH in ~/.bashrc\n"
    else
        printf "PATH already includes ~/.local/bin in ~/.bashrc\n"
    fi
}

# -----------------------------------------------------------------------------
# Function: setup_bash_nvm
# Description: Idempotently ensure NVM is sourced in ~/.bashrc (defense in
#              depth — install-nvm.sh's upstream installer self-detects a
#              profile from $SHELL, which may not be bash by the time this
#              runs)
# -----------------------------------------------------------------------------
setup_bash_nvm() {
    if ! grep -q 'NVM_DIR' "$BASH_RC" 2>/dev/null; then
        {
            echo ""
            echo "# NVM"
            echo 'export NVM_DIR="$HOME/.nvm"'
            echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"'
        } >> "$BASH_RC"
        printf "Added NVM sourcing to ~/.bashrc\n"
    else
        printf "NVM already configured in ~/.bashrc\n"
    fi
}

# -----------------------------------------------------------------------------
# Function: setup_bash_lsd_alias
# Description: Alias ls -> lsd, only if lsd is already installed (by
#              install-fish.sh); never fails this module if lsd is absent
# -----------------------------------------------------------------------------
setup_bash_lsd_alias() {
    if ! command -v lsd &>/dev/null; then
        return 0
    fi
    if ! grep -q "alias ls=.lsd." "$BASH_RC" 2>/dev/null; then
        echo "alias ls='lsd'" >> "$BASH_RC"
        printf "Added lsd alias to ~/.bashrc\n"
    else
        printf "lsd alias already configured in ~/.bashrc\n"
    fi
}

# -----------------------------------------------------------------------------
# Main execution
# -----------------------------------------------------------------------------

[ -f "$BASH_RC" ] || touch "$BASH_RC"

setup_bash_local_bin_path
setup_bash_nvm

ensure_oh_my_posh_installed || true
if check_oh_my_posh_installed; then
    setup_oh_my_posh_in_rc bash "$BASH_RC"
else
    printf "Skipping oh-my-posh prompt setup because oh-my-posh is not installed.\n\n"
fi

setup_bash_lsd_alias

echo "✓ bash shell enhanced successfully"
exit 0
