# START HERE - Ubuntu Setup Project

Welcome to the ubuntu-setup repository.

## Quick Start

```bash
git clone https://github.com/omoinjm/ubuntu-setup.git
cd ubuntu-setup

chmod +x install.sh uninstall.sh library_scripts/*.sh scripts/ci-smoke.sh

./install.sh
```

Optional tools:

```bash
INSTALL_TERRAFORM=true INSTALL_NEBIUS_CLI=true ./install.sh
```

## What Gets Installed

**Core:**

- tmux
- Fish shell (+ oh-my-posh, lsd when available)
- Neovim (+ ripgrep, fd, lazygit)
- NVM + Node.js LTS
- fzf
- Droid Sans Mono Nerd Font
- Dotfiles from GitHub

**Optional:**

- Terraform (`INSTALL_TERRAFORM=true`)
- Nebius CLI (`INSTALL_NEBIUS_CLI=true`)
- .NET SDK (`INSTALL_DOTNET=true`)

## Documentation Guide

### For first-time users

1. [README.md](../README.md) — Overview and quick start
2. [INSTALLATION_GUIDE.md](./INSTALLATION_GUIDE.md) — Step-by-step setup
3. [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) — If something goes wrong

### For developers

1. [ARCHITECTURE.md](./ARCHITECTURE.md) — How it is built
2. [ADDING_MODULES.md](./ADDING_MODULES.md) — How to add new tools
3. [AI_CONTEXT.md](./AI_CONTEXT.md) — For AI systems analyzing code

## Project Structure

```
.
├── install.sh
├── uninstall.sh
├── scripts/ci-smoke.sh
├── library_scripts/          # Installation modules
│   ├── config.sh
│   ├── check-prerequisites.sh
│   ├── update-repositories.sh
│   ├── setup-dotfiles.sh
│   ├── install-tmux.sh
│   ├── install-fish.sh
│   ├── install-neovim.sh
│   ├── install-nvm.sh
│   ├── install-fzf.sh
│   ├── install-fonts.sh
│   ├── install-terraform.sh
│   ├── install-nebius-cli.sh
│   └── install-dotnet.sh
├── lib/logging.sh
└── docs/
```

## Usage

```bash
# Full install
./install.sh

# Pre-flight check only
./library_scripts/check-prerequisites.sh

# CI smoke tests
./scripts/ci-smoke.sh

# Uninstall
./uninstall.sh
```

## Configuration

See `library_scripts/config.sh` or the README for environment variables such as `DOTFILES_REPO`, `DOTFILES_OPTIONAL`, and optional install flags.

## Support

- Installation issues → [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
- Extending the project → [ADDING_MODULES.md](./ADDING_MODULES.md)
- Technical details → [ARCHITECTURE.md](./ARCHITECTURE.md)
