#!/bin/bash

# Script: install-fonts.sh
# Purpose: Install and configure Nerd Fonts (Droid Sans Mono)
# Exit codes: 0 = success, 1 = failure

set -e

# Load config if available
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [ -f "$ROOT_DIR/library_scripts/config.sh" ]; then
    source "$ROOT_DIR/library_scripts/config.sh"
fi

# Font configuration
FONT_NAME="Droid Sans Mono Nerd Font"
FONT_FILE="DroidSansMNerdFont-Regular.otf"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/DroidSansMono/DroidSansMNerdFont-Regular.otf"
FONT_DIR="${FONT_DIR:-$HOME/.local/share/fonts}"
TOOL_NAME="fonts"

echo "Installing $FONT_NAME..."

# -----------------------------------------------------------------------------
# Function: check_font_installed
# Description: Check if the font file exists in the user font directory
# Returns: 0 if installed, 1 otherwise
# -----------------------------------------------------------------------------
check_font_installed() {
    [ -f "$FONT_DIR/$FONT_FILE" ]
}

# -----------------------------------------------------------------------------
# Function: get_font_info
# Description: Get information about the installed font
# Returns: Font file path or empty
# -----------------------------------------------------------------------------
get_font_info() {
    if [ -f "$FONT_DIR/$FONT_FILE" ]; then
        echo "$FONT_DIR/$FONT_FILE"
    fi
}

# -----------------------------------------------------------------------------
# Function: download_font
# Description: Download the font file from GitHub
# Arguments: font url
# Returns: 0 on success, 1 on failure
# -----------------------------------------------------------------------------
download_font() {
    local url="$1"
    local temp_dir
    temp_dir=$(mktemp -d)

    printf "Downloading %s...\n" "$FONT_NAME"

    # Download the font file
    if ! curl -fsSL -o "$temp_dir/$FONT_FILE" "$url"; then
        echo "Error: Failed to download font from GitHub"
        rm -rf "$temp_dir"
        return 1
    fi

    # Create font directory and move font file
    mkdir -p "$FONT_DIR"
    mv "$temp_dir/$FONT_FILE" "$FONT_DIR/"

    # Clean up
    rm -rf "$temp_dir"

    return 0
}

# -----------------------------------------------------------------------------
# Function: install_font
# Description: Main font installation function
# Returns: 0 on success, 1 on failure
# -----------------------------------------------------------------------------
install_font() {
    # Create font directory
    mkdir -p "$FONT_DIR"

    # Download and install font
    if ! download_font "$FONT_URL"; then
        echo "Error: Font installation failed"
        return 1
    fi

    # Verify installation
    if ! [ -f "$FONT_DIR/$FONT_FILE" ]; then
        echo "Error: Font file not found after installation"
        return 1
    fi

    # Update font cache
    printf "Updating font cache...\n"
    if command -v fc-cache &>/dev/null; then
        fc-cache -f "$FONT_DIR" &>/dev/null || true
    fi

    printf "%s successfully installed to %s\n\n" "$FONT_NAME" "$(get_font_info)"
}

# -----------------------------------------------------------------------------
# Function: verify_font_installation
# Description: Verify font is installed correctly
# Returns: 0 if verification passes, 1 otherwise
# -----------------------------------------------------------------------------
verify_font_installation() {
    local font_path
    font_path=$(get_font_info)

    if [ -z "$font_path" ]; then
        echo "Error: Font file not found"
        return 1
    fi

    # Check file exists and is readable
    if ! [ -r "$font_path" ]; then
        echo "Error: Font file is not readable"
        return 1
    fi

    return 0
}

# -----------------------------------------------------------------------------
# Function: display_font_info
# Description: Display installed font information
# Returns: 0 on success
# -----------------------------------------------------------------------------
display_font_info() {
    local font_path
    font_path=$(get_font_info)
    printf "%s: %s\n" "$FONT_NAME" "$font_path"
}

# -----------------------------------------------------------------------------
# Main execution
# -----------------------------------------------------------------------------

# Check if font is already installed
if check_font_installed; then
    font_path=$(get_font_info)
    printf "%s is already installed: %s\n\n" "$FONT_NAME" "$font_path"
else
    printf "%s not found. Installing...\n\n" "$FONT_NAME"

    # Install font
    if ! install_font; then
        exit 1
    fi
fi

# Verify installation
if ! verify_font_installation; then
    echo "Error: Font installation verification failed."
    exit 1
fi

# Display font information
display_font_info
echo

printf "✓ $TOOL_NAME installed successfully\n"
exit 0
