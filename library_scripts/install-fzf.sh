#!/bin/bash

# Script: install-fzf.sh
# Purpose: Install and configure fzf (fuzzy finder)
# Exit codes: 0 = success, 1 = failure

set -e

# Load config if available
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [ -f "$ROOT_DIR/library_scripts/config.sh" ]; then
    source "$ROOT_DIR/library_scripts/config.sh"
fi

# fzf version to install (pinned for reproducibility)
FZF_VERSION="v0.70.0"
TOOL_NAME="fzf"

# fzf installation directory
export FZF_DIR="${FZF_DIR:-$HOME/.fzf}"

echo "Installing $TOOL_NAME..."

# -----------------------------------------------------------------------------
# Function: check_fzf_installed
# Description: Check if fzf executable exists and is runnable
# Returns: 0 if installed, 1 otherwise
# -----------------------------------------------------------------------------
check_fzf_installed() {
    [ -x "$FZF_DIR/bin/fzf" ] && command -v fzf &>/dev/null
}

# -----------------------------------------------------------------------------
# Function: get_fzf_version
# Description: Get the installed fzf version
# Returns: Version string or empty
# -----------------------------------------------------------------------------
get_fzf_version() {
    if [ -x "$FZF_DIR/bin/fzf" ]; then
        "$FZF_DIR/bin/fzf" --version 2>/dev/null | head -1
    fi
}

# -----------------------------------------------------------------------------
# Function: download_fzf
# Description: Download fzf binary from GitHub releases
# Arguments: fzf version (e.g., "v0.70.0")
# Returns: 0 on success, 1 on failure
# -----------------------------------------------------------------------------
download_fzf() {
    local version="$1"
    local temp_dir
    temp_dir=$(mktemp -d)
    local archive_name="fzf-${version#v}-linux_amd64.tar.gz"
    local download_url="https://github.com/junegunn/fzf/releases/download/${version}/${archive_name}"

    printf "Downloading fzf %s...\n" "$version"

    # Download the archive
    if ! curl -fsSL -o "$temp_dir/$archive_name" "$download_url"; then
        echo "Error: Failed to download fzf from GitHub"
        rm -rf "$temp_dir"
        return 1
    fi

    # Extract to temp directory
    if ! tar -xzf "$temp_dir/$archive_name" -C "$temp_dir"; then
        echo "Error: Failed to extract fzf archive"
        rm -rf "$temp_dir"
        return 1
    fi

    # Create fzf directory and move binaries
    mkdir -p "$FZF_DIR/bin"
    mv "$temp_dir/fzf" "$FZF_DIR/bin/"
    chmod +x "$FZF_DIR/bin/fzf"

    # Copy shell integration scripts
    if [ -f "$temp_dir/shell/key-bindings.bash" ]; then
        mkdir -p "$FZF_DIR/shell"
        cp "$temp_dir/shell/"* "$FZF_DIR/shell/" 2>/dev/null || true
    fi

    # Clean up
    rm -rf "$temp_dir"

    return 0
}

# -----------------------------------------------------------------------------
# Function: install_fzf
# Description: Main fzf installation function
# Returns: 0 on success, 1 on failure
# -----------------------------------------------------------------------------
install_fzf() {
    # Create fzf directory
    mkdir -p "$FZF_DIR"

    # Download and install fzf
    if ! download_fzf "$FZF_VERSION"; then
        echo "Error: fzf installation failed"
        return 1
    fi

    # Verify installation
    if ! [ -x "$FZF_DIR/bin/fzf" ]; then
        echo "Error: fzf binary not found after installation"
        return 1
    fi

    printf "fzf %s successfully installed to %s\n\n" "$(get_fzf_version)" "$FZF_DIR"
}

# -----------------------------------------------------------------------------
# Function: setup_fzf_shell_integration
# Description: Configure shell integration for bash, zsh, and fish
# Returns: 0 on success
# -----------------------------------------------------------------------------
setup_fzf_shell_integration() {
    local bash_rc="${HOME}/.bashrc"
    local zsh_rc="${HOME}/.zshrc"
    local fish_functions_dir="${HOME}/.config/fish/functions"
    local fish_conf_dir="${HOME}/.config/fish"
    local fzf_bash="$FZF_DIR/shell/key-bindings.bash"
    local fzf_zsh="$FZF_DIR/shell/key-bindings.zsh"

    printf "Setting up shell integration...\n"

    # Setup bash integration
    if [ -f "$bash_rc" ]; then
        if ! grep -q "fzf.bash" "$bash_rc" 2>/dev/null; then
            # Check for existing fzf config and remove it
            sed -i '/\[ -f ~/.fzf.bash \] && source ~/.fzf.bash/d' "$bash_rc" 2>/dev/null || true
            sed -i '/export PATH="\$HOME\/.fzf\/bin:\$PATH"/d' "$bash_rc" 2>/dev/null || true
            echo "" >> "$bash_rc"
            echo "# fzf configuration" >> "$bash_rc"
            echo "export PATH=\"\$HOME/.fzf/bin:\$PATH\"" >> "$bash_rc"
            echo "[ -f ~/.fzf.bash ] && source ~/.fzf.bash" >> "$bash_rc"
            printf "  - Added fzf integration to .bashrc\n"
        else
            printf "  - fzf already configured in .bashrc\n"
        fi
    fi

    # Create .fzf.bash if it doesn't exist
    if [ ! -f "${HOME}/.fzf.bash" ] && [ -f "$fzf_bash" ]; then
        cp "$fzf_bash" "${HOME}/.fzf.bash"
        printf "  - Created ~/.fzf.bash\n"
    elif [ ! -f "${HOME}/.fzf.bash" ]; then
        # Create minimal fzf bash config
        cat > "${HOME}/.fzf.bash" << 'EOF'
# FZF Bash Integration
if [ -x ~/.fzf/bin/fzf ]; then
    [ -n "$PS1" ] && source ~/.fzf/shell/key-bindings.bash 2>/dev/null || true
fi
EOF
        printf "  - Created minimal ~/.fzf.bash\n"
    fi

    # Setup zsh integration
    if [ -f "$zsh_rc" ]; then
        if ! grep -q "fzf.zsh" "$zsh_rc" 2>/dev/null; then
            # Check for existing fzf config and remove it
            sed -i '/\[ -f ~/.fzf.zsh \] && source ~/.fzf.zsh/d' "$zsh_rc" 2>/dev/null || true
            sed -i '/export PATH="\$HOME\/.fzf\/bin:\$PATH"/d' "$zsh_rc" 2>/dev/null || true
            echo "" >> "$zsh_rc"
            echo "# fzf configuration" >> "$zsh_rc"
            echo "export PATH=\"\$HOME/.fzf/bin:\$PATH\"" >> "$zsh_rc"
            echo "[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh" >> "$zsh_rc"
            printf "  - Added fzf integration to .zshrc\n"
        else
            printf "  - fzf already configured in .zshrc\n"
        fi
    fi

    # Create .fzf.zsh if it doesn't exist
    if [ ! -f "${HOME}/.fzf.zsh" ] && [ -f "$fzf_zsh" ]; then
        cp "$fzf_zsh" "${HOME}/.fzf.zsh"
        printf "  - Created ~/.fzf.zsh\n"
    elif [ ! -f "${HOME}/.fzf.zsh" ]; then
        # Create minimal fzf zsh config
        cat > "${HOME}/.fzf.zsh" << 'EOF'
# FZF Zsh Integration
if [ -x ~/.fzf/bin/fzf ]; then
    [ -n "$PS1" ] && source ~/.fzf/shell/key-bindings.zsh 2>/dev/null || true
fi
EOF
        printf "  - Created minimal ~/.fzf.zsh\n"
    fi

    # Setup fish integration
    mkdir -p "$fish_functions_dir"
    mkdir -p "$fish_conf_dir"
    local fish_key_bindings="$fish_functions_dir/fish_user_key_bindings.fish"
    local fish_conf="$fish_conf_dir/conf.d/fzf.fish"

    # Create fish config with PATH export
    if [ ! -f "$fish_conf" ]; then
        cat > "$fish_conf" << 'EOF'
# fzf configuration
set -gx PATH "$HOME/.fzf/bin" $PATH
EOF
        printf "  - Added fzf PATH to fish config\n"
    else
        if ! grep -q ".fzf/bin" "$fish_conf" 2>/dev/null; then
            echo "set -gx PATH \"\$HOME/.fzf/bin\" \$PATH" >> "$fish_conf"
            printf "  - Added fzf PATH to fish config\n"
        else
            printf "  - fzf PATH already configured in fish\n"
        fi
    fi

    # Setup fish key bindings
    if [ -f "$fish_key_bindings" ]; then
        if ! grep -q "fzf" "$fish_key_bindings" 2>/dev/null; then
            echo "" >> "$fish_key_bindings"
            echo "# fzf key bindings" >> "$fish_key_bindings"
            echo "function fish_user_key_bindings" >> "$fish_key_bindings"
            echo "  ~/.fzf/bin/fzf --fish | source" >> "$fish_key_bindings"
            echo "end" >> "$fish_key_bindings"
            printf "  - Added fzf integration to fish key bindings\n"
        else
            printf "  - fzf already configured in fish\n"
        fi
    else
        cat > "$fish_key_bindings" << 'EOF'
function fish_user_key_bindings
  ~/.fzf/bin/fzf --fish | source
end
EOF
        printf "  - Created fish_user_key_bindings.fish with fzf\n"
    fi

    printf "\n"
}

# -----------------------------------------------------------------------------
# Function: verify_fzf_installation
# Description: Verify fzf is working correctly
# Returns: 0 if verification passes, 1 otherwise
# -----------------------------------------------------------------------------
verify_fzf_installation() {
    local fzf_version
    fzf_version=$(get_fzf_version)

    if [ -z "$fzf_version" ]; then
        echo "Error: fzf version check failed"
        return 1
    fi

    # Test that fzf runs
    if ! echo "test" | "$FZF_DIR/bin/fzf" --version &>/dev/null; then
        echo "Error: fzf executable test failed"
        return 1
    fi

    return 0
}

# -----------------------------------------------------------------------------
# Function: display_fzf_info
# Description: Display installed fzf version
# Returns: 0 on success
# -----------------------------------------------------------------------------
display_fzf_info() {
    local fzf_version
    fzf_version=$(get_fzf_version)
    printf "fzf version: %s\n" "$fzf_version"
}

# -----------------------------------------------------------------------------
# Main execution
# -----------------------------------------------------------------------------

# Check if fzf is already installed
if check_fzf_installed; then
    fzf_version=$(get_fzf_version)
    printf "fzf is already installed: %s\n\n" "$fzf_version"
    printf "Reconfiguring shell integration...\n\n"
    setup_fzf_shell_integration
else
    printf "fzf not found. Installing...\n\n"

    # Install fzf
    if ! install_fzf; then
        exit 1
    fi
fi

# Setup shell integration
setup_fzf_shell_integration

# Verify installation
if ! verify_fzf_installation; then
    echo "Error: fzf installation verification failed."
    echo "You may need to restart your shell or run: export PATH=\"\$HOME/.fzf/bin:\$PATH\""
    exit 1
fi

# Display version information
display_fzf_info
echo

printf "✓ $TOOL_NAME installed successfully\n"
exit 0
