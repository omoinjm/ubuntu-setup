#!/bin/bash

# Script: setup-dotfiles.sh
# Purpose: Clone and setup dotfiles from GitHub repository
# Exit codes: 0 = success, 1 = failure

set -e

# Load config
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/library_scripts/config.sh"

# Dotfiles repository
DOTFILES_REPO="git@github.com:omoinjm/.dotfiles.git"
DOTFILES_REPO_HTTPS="https://github.com/omoinjm/.dotfiles.git"

echo "Setting up dotfiles..."

# Check if Git is installed
if ! command -v git &>/dev/null; then
    echo "Error: Git is required but not installed."
    exit 1
fi

# Function to check if SSH key exists for GitHub
check_ssh_key() {
    if [ -f "$HOME/.ssh/id_ed25519.pub" ] || [ -f "$HOME/.ssh/id_rsa.pub" ]; then
        # Check if SSH agent is running and has keys
        if ssh-add -l &>/dev/null; then
            return 0
        fi
        # Check if we can authenticate with SSH
        if ssh -T -o BatchMode=yes -o ConnectTimeout=5 git@github.com &>/dev/null; then
            return 0
        fi
    fi
    return 1
}

# Function to clone repository with fallback
clone_repo() {
    local repo_url="$1"
    local dest="$2"
    
    if git clone "$repo_url" "$dest" 2>/dev/null; then
        return 0
    fi
    return 1
}

# Check if dotfiles repo already exists
if [ -d "$DOTFILES_DIR/.git" ]; then
    printf "Dotfiles repository already exists at %s.\n\n" "$DOTFILES_DIR"
else
    printf "Cloning dotfiles repository into %s...\n" "$DOTFILES_DIR"
    
    # Try SSH first if SSH key is available, otherwise use HTTPS
    if check_ssh_key; then
        printf "Using SSH authentication...\n"
        if clone_repo "$DOTFILES_REPO" "$DOTFILES_DIR"; then
            printf "Dotfiles repository cloned successfully via SSH.\n\n"
        else
            printf "SSH clone failed, falling back to HTTPS...\n"
            if clone_repo "$DOTFILES_REPO_HTTPS" "$DOTFILES_DIR"; then
                printf "Dotfiles repository cloned successfully via HTTPS.\n\n"
            else
                printf "Warning: Could not clone dotfiles repository.\n"
                printf "You can clone it manually later:\n"
                printf "  git clone %s %s\n\n" "$DOTFILES_REPO_HTTPS" "$DOTFILES_DIR"
            fi
        fi
    else
        printf "No SSH key found, using HTTPS...\n"
        if clone_repo "$DOTFILES_REPO_HTTPS" "$DOTFILES_DIR"; then
            printf "Dotfiles repository cloned successfully via HTTPS.\n\n"
        else
            printf "Warning: Could not clone dotfiles repository.\n"
            printf "This may be expected if the repository is private or does not exist.\n"
            printf "You can clone it manually later:\n"
            printf "  git clone %s %s\n\n" "$DOTFILES_REPO_HTTPS" "$DOTFILES_DIR"
        fi
    fi
fi

echo "✓ Dotfiles setup completed successfully"
exit 0
