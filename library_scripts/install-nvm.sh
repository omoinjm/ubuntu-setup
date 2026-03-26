#!/bin/bash

# Script: install-nvm.sh
# Purpose: Install NVM (Node Version Manager)
# Exit codes: 0 = success, 1 = failure

set -e

# Load config if available
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [ -f "$ROOT_DIR/library_scripts/config.sh" ]; then
    source "$ROOT_DIR/library_scripts/config.sh"
fi

# NVM version to install (pinned for reproducibility)
NVM_VERSION="v0.40.4"
TOOL_NAME="nvm"

# NVM installation directory
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

echo "Installing $TOOL_NAME..."

# -----------------------------------------------------------------------------
# Function: check_nvm_installed
# Description: Check if nvm.sh exists and is readable
# Returns: 0 if installed, 1 otherwise
# -----------------------------------------------------------------------------
check_nvm_installed() {
    [ -s "$NVM_DIR/nvm.sh" ]
}

# -----------------------------------------------------------------------------
# Function: download_nvm_install_script
# Description: Download the NVM install script from GitHub
# Arguments: NVM version (e.g., "v0.40.4")
# Returns: 0 on success, 1 on failure
# -----------------------------------------------------------------------------
download_nvm_install_script() {
    local version="$1"
    local install_script="$NVM_DIR/install.sh"

    curl -fsSL -o "$install_script" "https://raw.githubusercontent.com/nvm-sh/nvm/${version}/install.sh"

    if [ ! -s "$install_script" ]; then
        echo "Error: Failed to download NVM install script"
        return 1
    fi

    return 0
}

# -----------------------------------------------------------------------------
# Function: install_nvm
# Description: Run the NVM install script and clean up
# Returns: 0 on success, 1 on failure
# -----------------------------------------------------------------------------
install_nvm() {
    local install_script="$NVM_DIR/install.sh"

    # Run the install script silently
    bash "$install_script" > /dev/null 2>&1

    # Clean up install script
    rm -f "$install_script"

    printf "nvm successfully installed.\n\n"
}

# -----------------------------------------------------------------------------
# Function: source_nvm
# Description: Source nvm.sh to make nvm command available
# Returns: 0 if successful, 1 if nvm.sh not found
# -----------------------------------------------------------------------------
source_nvm() {
    # shellcheck disable=SC1090
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
}

# -----------------------------------------------------------------------------
# Function: verify_nvm_installation
# Description: Verify nvm command is available
# Returns: 0 if verification passes, 1 otherwise
# -----------------------------------------------------------------------------
verify_nvm_installation() {
    command -v nvm &> /dev/null
}

# -----------------------------------------------------------------------------
# Function: display_nvm_info
# Description: Display installed nvm and node versions
# Returns: 0 on success
# -----------------------------------------------------------------------------
display_nvm_info() {
    local nvm_version
    local node_version

    nvm_version=$(nvm --version 2>/dev/null || echo "unknown")
    printf "nvm version: %s\n" "$nvm_version"

    if command -v node &> /dev/null; then
        node_version=$(node --version 2>/dev/null || echo "not installed")
        printf "node version: %s\n" "$node_version"
    else
        printf "node: not installed (run 'nvm install --lts' to install)\n"
    fi
}

# -----------------------------------------------------------------------------
# Main execution
# -----------------------------------------------------------------------------

# Check if NVM is already installed
if check_nvm_installed; then
    printf "nvm is already installed.\n\n"
else
    printf "nvm not found. Installing...\n"

    # Create NVM directory
    mkdir -p "$NVM_DIR"

    # Download and run install script
    if ! download_nvm_install_script "$NVM_VERSION"; then
        exit 1
    fi

    install_nvm
fi

# Source nvm to make it available in current shell
source_nvm

# Verify installation
if ! verify_nvm_installation; then
    echo "Error: nvm installation verification failed."
    echo "NVM was installed but the 'nvm' command is not available."
    echo "You may need to restart your shell or run: source $NVM_DIR/nvm.sh"
    exit 1
fi

# Install latest LTS version of Node.js
echo "Installing latest LTS version of Node.js..."
nvm install --lts

# Display version information
echo
display_nvm_info
echo

printf "\n"
echo "✓ $TOOL_NAME installed successfully"
exit 0
