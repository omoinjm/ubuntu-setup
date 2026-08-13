# Project Overview

## Purpose

This project provides an automated setup script for configuring an Ubuntu Linux development environment with modern tools and configurations.

## What It Does

The `install.sh` script orchestrates the installation and configuration of:

1. **Repository management** — Updates system package repositories and PPAs
2. **Pipe viewer (pv)** — Installed by default for enhanced download progress bars
3. **Dotfiles** — Clones personal configuration files from GitHub
4. **Terminal multiplexer** — tmux
5. **Shell** — bash is always enhanced (oh-my-posh, PATH, NVM sourcing); Fish (default-on, oh-my-posh + optional lsd) and Zsh (opt-in, oh-my-posh) are both available, each toggled via `INSTALL_FISH`/`INSTALL_ZSH`
6. **Editor** — Neovim with common CLI dependencies
7. **Runtime** — NVM and Node.js LTS
8. **Productivity** — fzf fuzzy finder and Nerd Fonts
9. **Optional** — Zsh, Terraform, Nebius CLI, and .NET SDK when enabled via env vars

## Key Features

- **Modular design** — Each tool has its own script in `library_scripts/`
- **Fail-fast error handling** — Installation stops when a required step fails
- **Configurable** — Dotfiles URL, optional tools, and install visibility via environment variables
- **Logged installs** — Writes to `~/.ubuntu-setup-install.log`
- **Dry-run plan** — `./install.sh --show-plan` previews steps without making changes
- **Progress spinners** — Animated indicators with elapsed time (`DISABLE_SPINNER=true` to turn off)
- **Install plan** — Summary of steps, apt packages, PPAs, and downloads before install begins (`SHOW_INSTALL_PLAN=true`)
- **Command visibility** — Each shell command is printed as it runs (`SHOW_INSTALL_COMMANDS=true`)
- **Download progress** — File downloads use `pv` for byte/rate/ETA bars when available (`INSTALL_PV=true`, default)
- **CI validated** — GitHub Actions runs smoke tests on every change
- **Uninstall support** — `uninstall.sh` removes installed components

## Who Should Use This

- Developers setting up new Ubuntu systems
- DevOps engineers needing a reproducible development environment
- Anyone wanting a modern terminal-based development setup

## Prerequisites

- Ubuntu Linux distribution
- Bash shell
- Internet connection
- Sudo privileges
- curl and git (checked during setup)
