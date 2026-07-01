#!/bin/bash

# Script: install-pv.sh
# Purpose: Optionally install pv (pipe viewer) for download progress bars
# Exit codes: 0 = success, 1 = failure

set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=library_scripts/config.sh
source "$ROOT_DIR/library_scripts/config.sh"
# shellcheck source=library_scripts/helpers.sh
source "$ROOT_DIR/library_scripts/helpers.sh"

TOOL_NAME="pv"

if [ "$INSTALL_PV" != "true" ]; then
    printf "Skipping %s install (INSTALL_PV=false).\n" "$TOOL_NAME"
    exit 0
fi

echo "Checking for $TOOL_NAME..."

if command -v pv &>/dev/null; then
    printf "%s is already installed: %s\n\n" "$TOOL_NAME" "$(pv --version 2>/dev/null | head -1 || echo "installed")"
    exit 0
fi

if ! command -v apt-get &>/dev/null; then
    printf "Warning: apt-get not found; cannot install %s. Downloads will use curl progress bars.\n\n" "$TOOL_NAME"
    exit 0
fi

run_apt "Installing pv (pipe viewer)" -qq install -y pv

if ! command -v pv &>/dev/null; then
    printf "Warning: %s installation failed. Downloads will use curl progress bars.\n\n" "$TOOL_NAME"
    exit 0
fi

printf "%s installed: %s\n\n" "$TOOL_NAME" "$(pv --version 2>/dev/null | head -1 || echo "installed")"
echo "✓ $TOOL_NAME installed successfully"
exit 0
