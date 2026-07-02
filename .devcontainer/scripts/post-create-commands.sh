#!/bin/bash
set -euo pipefail

# Check for required environment variables
: "${GIT_USER_EMAIL:?Need to set GIT_USER_EMAIL}"
: "${GIT_USER_NAME:?Need to set GIT_USER_NAME}"

setup_ssh_key() {
    local key=""
    for candidate in "$HOME/.ssh/id_ed25519" "$HOME/.ssh/id_rsa"; do
        if [ -f "$candidate" ]; then
            key="$candidate"
            break
        fi
    done

    if [ -z "$key" ]; then
        echo "No SSH private key found in ~/.ssh; skipping ssh-agent setup."
        return 0
    fi

    chmod 600 "$key"
    eval "$(ssh-agent -s)"
    ssh-add "$key" </dev/null 2>/dev/null || {
        echo "Could not add SSH key automatically (passphrase-protected?). Add manually after attach."
        return 0
    }

    {
        echo "chmod 600 $key"
        echo 'eval "$(ssh-agent -s)"'
        echo "ssh-add $key"
    } >> "$HOME/.bashrc"
}

setup_ssh_key

git config --global --add safe.directory /workspaces/ubuntu-setup
git config --global user.email "$GIT_USER_EMAIL"
git config --global user.name "$GIT_USER_NAME"

find /workspaces/ubuntu-setup/ -type f -name "*.sh" -exec chmod +x {} +
