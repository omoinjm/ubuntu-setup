# Project Overview

## Purpose

This project provides an automated setup script for configuring an Ubuntu Linux development environment with modern tools and configurations.

## What It Does

The `install.sh` script orchestrates the installation and configuration of:

1. **Repository Management** - Updates system package repositories
2. **Dotfiles** - Pulls personal configuration files from GitHub
3. **Terminal Multiplexer** - tmux for terminal session management
4. **Shell** - Fish shell for enhanced command-line experience
5. **Editor** - Neovim for advanced text editing
6. **Runtime** - Node.js for JavaScript development
7. **Infrastructure** - Terraform for infrastructure-as-code
8. **Cloud CLI** - Nebius CLI for cloud operations

## Key Features

- **Modular Design** - Each tool has its own installation script
- **Error Handling** - Scripts exit early if any installation fails
- **Automated Process** - Single command to set up entire development environment
- **Reproducible Setup** - Ensures consistent environment across machines

## Who Should Use This

- Developers setting up new Ubuntu systems
- DevOps engineers needing a reproducible development environment
- Anyone wanting a modern terminal-based development setup

## Prerequisites

- Ubuntu Linux distribution
- Bash shell
- Internet connection
- Sudo privileges
