#!/bin/bash

# Installation plan summary — lists packages, downloads, and steps before install runs.
# Usage: source after library_scripts/config.sh, then call print_install_plan

if [ -n "${_INSTALL_PLAN_SH_LOADED:-}" ]; then
    return 0 2>/dev/null || exit 0
fi
_INSTALL_PLAN_SH_LOADED=1

_plan_section() {
    local title="$1"
    echo
    echo "$title"
    echo "$(printf '─%.0s' {1..50})"
}

_plan_item() {
    printf '  • %s\n' "$1"
}

print_install_plan() {
    [ "${SHOW_INSTALL_PLAN:-true}" = "true" ] || return 0

    echo
    echo "═══════════════════════════════════════════════════════════════════"
    echo "  Installation Plan"
    echo "═══════════════════════════════════════════════════════════════════"

    _plan_section "Steps"
    _plan_item "System prerequisites check"
    _plan_item "Update apt repositories and add PPAs"
    if [ "${INSTALL_PV:-true}" = "true" ]; then
        _plan_item "Install pv (pipe viewer) for download progress"
    fi
    _plan_item "Clone dotfiles from ${DOTFILES_REPO:-<not set>}"
    _plan_item "Link dotfiles configs (fish, nvim, tmux, lazygit) into ~/.config"
    _plan_item "Install tmux"
    _plan_item "Install Fish shell (+ oh-my-posh, lsd when available)"
    _plan_item "Install Neovim and dependencies"
    _plan_item "Install NVM and Node.js LTS"
    _plan_item "Install fzf"
    _plan_item "Install Nerd Font"
    if [ "${INSTALL_TERRAFORM:-false}" = "true" ]; then
        _plan_item "Install Terraform"
    fi
    if [ "${INSTALL_NEBIUS_CLI:-false}" = "true" ]; then
        _plan_item "Install Nebius CLI"
    fi
    if [ "${INSTALL_DOTNET:-false}" = "true" ]; then
        _plan_item "Install .NET SDK and runtimes"
    fi

    _plan_section "APT packages"
    _plan_item "software-properties-common"
    if [ "${INSTALL_PV:-true}" = "true" ]; then
        _plan_item "pv"
    fi
    _plan_item "tmux"
    _plan_item "fish, unzip"
    _plan_item "lsd (if available in apt)"
    _plan_item "neovim, lazygit, gcc, ripgrep, fd-find"
    if [ "${INSTALL_TERRAFORM:-false}" = "true" ]; then
        _plan_item "gnupg, terraform (via HashiCorp apt repo)"
    fi
    if [ "${INSTALL_DOTNET:-false}" = "true" ]; then
        _plan_item "dotnet-sdk-10.0, dotnet-sdk-9.0, dotnet-sdk-8.0"
        _plan_item "aspnetcore-runtime-*, dotnet-runtime-*, zlib1g"
    fi

    _plan_section "PPAs"
    _plan_item "ppa:git-core/ppa"
    _plan_item "ppa:neovim-ppa/stable"
    _plan_item "ppa:fish-shell/release-3"
    _plan_item "ppa:dotnet/backports"
    if [ "${INSTALL_TERRAFORM:-false}" = "true" ]; then
        _plan_item "HashiCorp apt repository (apt.releases.hashicorp.com)"
    fi

    _plan_section "Downloads and remote installers"
    _plan_item "Dotfiles: ${DOTFILES_REPO}"
    _plan_item "NVM v0.40.4 (github.com/nvm-sh/nvm)"
    _plan_item "Node.js LTS (via nvm install --lts)"
    _plan_item "fzf v0.70.0 (github.com/junegunn/fzf releases)"
    _plan_item "Droid Sans Mono Nerd Font (github.com/ryanoasis/nerd-fonts)"
    _plan_item "oh-my-posh (ohmyposh.dev/install.sh)"
    if [ "${INSTALL_NEBIUS_CLI:-false}" = "true" ]; then
        _plan_item "Nebius CLI (storage.eu-north1.nebius.cloud/cli/install.sh)"
    fi

    echo
    if [ "${SHOW_INSTALL_COMMANDS:-true}" = "true" ]; then
        echo "Each command will be printed as it runs (SHOW_INSTALL_COMMANDS=true)."
    else
        echo "Command output is hidden (SHOW_INSTALL_COMMANDS=false)."
    fi
    echo "═══════════════════════════════════════════════════════════════════"
    echo
}
