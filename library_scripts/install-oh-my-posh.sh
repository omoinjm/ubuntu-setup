#!/bin/bash

# Script: install-oh-my-posh.sh
# Purpose: Shared oh-my-posh install + per-shell prompt-init helpers.
#          Sourced by install-fish.sh, install-zsh.sh, and
#          install-bash-enhancements.sh — not run directly via run_step.

if [ -n "${_INSTALL_OH_MY_POSH_SH_LOADED:-}" ]; then
    return 0 2>/dev/null || exit 0
fi
_INSTALL_OH_MY_POSH_SH_LOADED=1

OH_MY_POSH_ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=library_scripts/helpers.sh
source "$OH_MY_POSH_ROOT_DIR/library_scripts/helpers.sh"

OH_MY_POSH_THEME="${OH_MY_POSH_THEME:-tonybaloney}"

# -----------------------------------------------------------------------------
# Function: check_oh_my_posh_installed
# Description: Check if oh-my-posh is available
# Returns: 0 if installed, 1 otherwise
# -----------------------------------------------------------------------------
check_oh_my_posh_installed() {
    command -v oh-my-posh &>/dev/null
}

# -----------------------------------------------------------------------------
# Function: install_oh_my_posh
# Description: Install oh-my-posh prompt theme engine
# Returns: 0 on success (warning on failure is acceptable)
# -----------------------------------------------------------------------------
install_oh_my_posh() {
    printf "Installing oh-my-posh...\n"
    if with_spinner "Installing oh-my-posh" bash -c 'curl -fsSL https://ohmyposh.dev/install.sh | bash'; then
        printf "oh-my-posh successfully installed.\n\n"
        return 0
    else
        printf "Warning: oh-my-posh installation failed. Continuing without it.\n\n"
        return 1
    fi
}

# -----------------------------------------------------------------------------
# Function: ensure_oh_my_posh_installed
# Description: Install oh-my-posh if missing; no-op (with version print) if present
# Returns: 0 if oh-my-posh ends up available, 1 otherwise
# -----------------------------------------------------------------------------
ensure_oh_my_posh_installed() {
    if check_oh_my_posh_installed; then
        printf "oh-my-posh is already installed: %s\n\n" "$(oh-my-posh --version 2>/dev/null || echo unknown)"
        return 0
    fi
    install_oh_my_posh
}

# -----------------------------------------------------------------------------
# Function: oh_my_posh_init_line
# Description: Print the oh-my-posh init line for a given shell
# Arguments: $1 = shell name (fish|zsh|bash), $2 = theme (optional)
# Returns: 0 on success, 1 for unsupported shells
# -----------------------------------------------------------------------------
oh_my_posh_init_line() {
    local shell_name="$1"
    local theme="${2:-$OH_MY_POSH_THEME}"
    local theme_url="https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/${theme}.omp.json"

    case "$shell_name" in
        fish) echo "oh-my-posh init fish --config \"${theme_url}\" | source" ;;
        zsh) echo "eval \"\$(oh-my-posh init zsh --config '${theme_url}')\"" ;;
        bash) echo "eval \"\$(oh-my-posh init bash --config '${theme_url}')\"" ;;
        *)
            echo "Error: unsupported shell '$shell_name' for oh-my-posh init" >&2
            return 1
            ;;
    esac
}

# -----------------------------------------------------------------------------
# Function: setup_oh_my_posh_in_rc
# Description: Idempotently append the oh-my-posh init line to a shell rc file
# Arguments: $1 = shell name (fish|zsh|bash), $2 = rc file path, $3 = theme (optional)
# Returns: 0 on success
# -----------------------------------------------------------------------------
setup_oh_my_posh_in_rc() {
    local shell_name="$1"
    local rc_file="$2"
    local theme="${3:-$OH_MY_POSH_THEME}"
    local init_line

    init_line="$(oh_my_posh_init_line "$shell_name" "$theme")" || return 1

    if grep -q "oh-my-posh" "$rc_file" 2>/dev/null; then
        printf "oh-my-posh already configured in %s\n" "$rc_file"
        return 0
    fi

    {
        echo ""
        echo "# oh-my-posh prompt"
        echo "$init_line"
    } >> "$rc_file"
    printf "Added oh-my-posh (%s) configuration to %s\n" "$theme" "$rc_file"
}
