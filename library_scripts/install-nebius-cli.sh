#!/bin/bash

# Script: install-nebius-cli.sh
# Purpose: Install Nebius CLI
# Exit codes: 0 = success, 1 = failure

set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=library_scripts/helpers.sh
source "$ROOT_DIR/library_scripts/helpers.sh"

TOOL_NAME="nebius"
INSTALLER_URL="https://storage.eu-north1.nebius.cloud/cli/install.sh"

echo "Installing $TOOL_NAME CLI..."

if command -v nebius &>/dev/null; then
    printf "nebius is already installed: %s\n\n" "$(nebius --version 2>/dev/null || echo "installed")"
    exit 0
fi

if ! command -v curl &>/dev/null; then
    echo "Error: curl is required to install Nebius CLI."
    exit 1
fi

installer_script=$(mktemp)
trap 'rm -f "$installer_script"' EXIT

if ! run_download "Downloading Nebius CLI installer" "$INSTALLER_URL" "$installer_script"; then
    echo "Error: Failed to download Nebius CLI installer."
    exit 1
fi

if [ ! -s "$installer_script" ]; then
    echo "Error: Nebius CLI installer download was empty."
    exit 1
fi

with_spinner "Installing Nebius CLI" bash "$installer_script"

if ! command -v nebius &>/dev/null; then
    echo "Error: nebius installation verification failed."
    exit 1
fi

printf "nebius installed: %s\n\n" "$(nebius --version 2>/dev/null || echo "installed")"
echo "✓ $TOOL_NAME CLI installed successfully"
exit 0
