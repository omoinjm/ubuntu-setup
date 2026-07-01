#!/bin/bash

# Script: setup-dotfiles.sh
# Purpose: Clone and setup dotfiles from GitHub repository
# Exit codes: 0 = success, 1 = failure

set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=library_scripts/config.sh
source "$ROOT_DIR/library_scripts/config.sh"

echo "Setting up dotfiles..."

if ! command -v git &>/dev/null; then
    echo "Error: Git is required but not installed."
    exit 1
fi

check_ssh_key() {
    if [ -f "$HOME/.ssh/id_ed25519.pub" ] || [ -f "$HOME/.ssh/id_rsa.pub" ]; then
        if ssh-add -l &>/dev/null; then
            return 0
        fi
        if ssh -T -o BatchMode=yes -o ConnectTimeout=5 git@github.com &>/dev/null; then
            return 0
        fi
    fi
    return 1
}

clone_repo() {
    local repo_url="$1"
    local dest="$2"

    git clone "$repo_url" "$dest"
}

handle_clone_failure() {
    printf "Error: Could not clone dotfiles repository.\n"
    printf "You can clone it manually later:\n"
    printf "  git clone %s %s\n\n" "$DOTFILES_REPO" "$DOTFILES_DIR"

    if [ "$DOTFILES_OPTIONAL" = "true" ]; then
        printf "Continuing because DOTFILES_OPTIONAL=true\n"
        return 0
    fi

    return 1
}

if [ -d "$DOTFILES_DIR/.git" ]; then
    printf "Dotfiles repository already exists at %s.\n\n" "$DOTFILES_DIR"
else
    printf "Cloning dotfiles repository into %s...\n" "$DOTFILES_DIR"

    cloned=false
    if check_ssh_key; then
        printf "Using SSH authentication...\n"
        if clone_repo "$DOTFILES_REPO_SSH" "$DOTFILES_DIR" 2>/dev/null; then
            cloned=true
            printf "Dotfiles repository cloned successfully via SSH.\n\n"
        else
            printf "SSH clone failed, falling back to HTTPS...\n"
        fi
    else
        printf "No SSH key found, using HTTPS...\n"
    fi

    if [ "$cloned" = false ]; then
        if clone_repo "$DOTFILES_REPO" "$DOTFILES_DIR"; then
            printf "Dotfiles repository cloned successfully via HTTPS.\n\n"
        else
            handle_clone_failure || exit 1
        fi
    fi
fi

echo "✓ Dotfiles setup completed successfully"
exit 0
