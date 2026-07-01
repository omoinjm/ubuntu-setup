# Project Overview

## Purpose

This project provides an automated setup script for configuring an Ubuntu Linux development environment with modern tools and configurations.

## What It Does

The `install.sh` script orchestrates the installation and configuration of:

1. **Repository management** — Updates system package repositories and PPAs
2. **Dotfiles** — Clones personal configuration files from GitHub
3. **Terminal multiplexer** — tmux
4. **Shell** — Fish with oh-my-posh and optional lsd
5. **Editor** — Neovim with common CLI dependencies
6. **Runtime** — NVM and Node.js LTS
7. **Productivity** — fzf fuzzy finder and Nerd Fonts
8. **Optional** — Terraform, Nebius CLI, and .NET SDK when enabled via env vars

## Key Features

- **Modular design** — Each tool has its own script in `library_scripts/`
- **Fail-fast error handling** — Installation stops when a required step fails
- **Configurable** — Dotfiles URL and optional tools via environment variables
- **Logged installs** — Writes to `~/.ubuntu-setup-install.log`
- **Progress spinners** — Animated indicators with elapsed time for long-running steps
- **Download progress** — `pv` installed automatically when missing (`INSTALL_PV=true`); falls back to `curl --progress-bar` if skipped or unavailable
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
