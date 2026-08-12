#!/bin/bash

# Script: install.sh
# Purpose: Main orchestration script for Ubuntu development environment setup
# Exit codes: 0 = success, 1 = failure

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/library_scripts"
SHOW_PLAN_ONLY=false

for arg in "$@"; do
    case "$arg" in
        --show-plan)
            SHOW_PLAN_ONLY=true
            ;;
        -h|--help)
            echo "Usage: ./install.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --show-plan    Print the installation plan and exit"
            echo ""
            echo "Environment variables: see library_scripts/config.sh and README.md"
            exit 0
            ;;
    esac
done

# Source logging functions
# shellcheck source=lib/logging.sh
source "$SCRIPT_DIR/lib/logging.sh"
# shellcheck source=lib/progress.sh
source "$SCRIPT_DIR/lib/progress.sh"
init_logging

fail_step() {
    local message="$1"
    end_logging "FAILED" "$message"
    exit 1
}

run_step() {
    local label="$1"
    local script="$2"
    local exit_code=0
    local step_start=$SECONDS

    section "$label"
    announce_command "$script"
    spinner_start "$label"
    if ! "$script"; then
        exit_code=$?
    fi
    spinner_stop "$exit_code"
    if [ "$exit_code" -ne 0 ]; then
        fail_step "$label failed."
    fi
    success "$label completed ($(format_elapsed $((SECONDS - step_start))))"
    echo
}

echo "═══════════════════════════════════════════════════════════════════"
echo "  Ubuntu Development Environment Setup"
echo "═══════════════════════════════════════════════════════════════════"
echo

section "Loading configuration..."
# shellcheck source=library_scripts/config.sh
source "$LIB_DIR/config.sh"
success "Configuration loaded"
echo

# shellcheck source=library_scripts/install-plan.sh
source "$LIB_DIR/install-plan.sh"
print_install_plan

if [ "$SHOW_PLAN_ONLY" = true ]; then
    info "Plan only mode (--show-plan). Exiting without installing."
    exit 0
fi

section "Creating required directories..."
mkdir -p "$CONFIG_DIR" "$DOTFILES_DIR" "$LOG_DIR" "$BIN_DIR"
sudo chown -R "$USER:$USER" "$CONFIG_DIR" 2>/dev/null || true
success "Directories created"
echo

run_step "Checking system prerequisites" "$LIB_DIR/check-prerequisites.sh"
run_step "Updating system repositories" "$LIB_DIR/update-repositories.sh"
run_step "Installing pv (pipe viewer)" "$LIB_DIR/install-pv.sh"
run_step "Setting up dotfiles" "$LIB_DIR/setup-dotfiles.sh"
run_step "Installing tmux" "$LIB_DIR/install-tmux.sh"
run_step "Installing Fish shell" "$LIB_DIR/install-fish.sh"
run_step "Installing Neovim" "$LIB_DIR/install-neovim.sh"
run_step "Installing NVM" "$LIB_DIR/install-nvm.sh"
run_step "Installing fzf (fuzzy finder)" "$LIB_DIR/install-fzf.sh"
run_step "Installing fonts" "$LIB_DIR/install-fonts.sh"

if [ "$INSTALL_TERRAFORM" = "true" ]; then
    run_step "Installing Terraform" "$LIB_DIR/install-terraform.sh"
fi

if [ "$INSTALL_NEBIUS_CLI" = "true" ]; then
    run_step "Installing Nebius CLI" "$LIB_DIR/install-nebius-cli.sh"
fi

if [ "$INSTALL_DOTNET" = "true" ]; then
    run_step "Installing .NET SDK" "$LIB_DIR/install-dotnet.sh"
fi

echo "═══════════════════════════════════════════════════════════════════"
success "Setup complete!"
echo "═══════════════════════════════════════════════════════════════════"
echo
echo "Installed tools:"
if tmux -V &>/dev/null; then success "tmux: $(tmux -V)"; else warn "tmux: not found"; fi
if fish --version &>/dev/null; then success "fish: $(fish --version)"; else warn "fish: not found"; fi
if nvim --version &>/dev/null; then success "neovim: $(nvim --version | head -1)"; else warn "neovim: not found"; fi
if [ -f "$NVM_DIR/nvm.sh" ]; then
    # shellcheck disable=SC1090,SC1091
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    if command -v nvm &>/dev/null; then success "nvm: $(nvm --version)"; else warn "nvm: not loaded"; fi
    if node --version &>/dev/null; then success "node: $(node --version)"; else warn "node: not installed (run: nvm install --lts)"; fi
else
    warn "nvm: not found"
    warn "node: not found"
fi
if [ -x "$FZF_DIR/bin/fzf" ]; then
    success "fzf: $("$FZF_DIR/bin/fzf" --version 2>/dev/null | head -1)"
else
    warn "fzf: not found"
fi
if [ -f "$HOME/.local/share/fonts/DroidSansMNerdFont-Regular.otf" ]; then
    success "fonts: Droid Sans Mono Nerd Font installed"
else
    warn "fonts: not found"
fi
if [ "$INSTALL_TERRAFORM" = "true" ]; then
    if terraform --version &>/dev/null; then success "terraform: $(terraform --version | head -1)"; else warn "terraform: not found"; fi
fi
if [ "$INSTALL_NEBIUS_CLI" = "true" ]; then
    if nebius --version &>/dev/null; then success "nebius: $(nebius --version 2>/dev/null)"; else warn "nebius: not found"; fi
fi
if [ "$INSTALL_DOTNET" = "true" ]; then
    if dotnet --version &>/dev/null; then success "dotnet: $(dotnet --version 2>/dev/null)"; else warn "dotnet: not found"; fi
fi

echo
echo "Next steps:"
echo "  1. Set Fish as your default shell: chsh -s /usr/bin/fish"
echo "  2. Logout and login for changes to take effect"
echo "  3. Review your dotfiles: $DOTFILES_DIR"
echo "  4. Copy secret templates from $DOTFILES_DIR/secrets/ if needed"
if [ "$INSTALL_TERRAFORM" != "true" ] || [ "$INSTALL_NEBIUS_CLI" != "true" ]; then
    echo "  5. Optional tools: set INSTALL_TERRAFORM=true or INSTALL_NEBIUS_CLI=true and re-run"
fi
echo "═══════════════════════════════════════════════════════════════════"
echo

end_logging "SUCCESS" "Installation completed successfully"
exit 0
