# Ubuntu Development Environment Setup

Automated installation script to set up a complete modern development environment on Ubuntu with modern tools and configurations.

## What Gets Installed

**Core (always installed):**

- **tmux** — Terminal multiplexer for session management
- **Fish shell** — Advanced command-line shell with syntax highlighting and oh-my-posh
- **Neovim** — Modern text editor with common dependencies (ripgrep, fd, lazygit)
- **NVM + Node.js LTS** — Node version manager and latest LTS runtime
- **fzf** — Fuzzy finder with shell integration
- **Nerd Fonts** — Droid Sans Mono Nerd Font for terminal icons
- **Dotfiles** — Personal configuration files from GitHub

**Optional (enable with environment variables):**

- **Terraform** — `INSTALL_TERRAFORM=true ./install.sh`
- **Nebius CLI** — `INSTALL_NEBIUS_CLI=true ./install.sh`
- **.NET SDK** — `INSTALL_DOTNET=true ./install.sh`

## Quick Start

```bash
# Clone the repository
git clone https://github.com/omoinjm/ubuntu-setup.git
cd ubuntu-setup

# Make scripts executable
chmod +x install.sh uninstall.sh library_scripts/*.sh scripts/ci-smoke.sh

# Run the installation
./install.sh

# Optional tools
INSTALL_TERRAFORM=true INSTALL_NEBIUS_CLI=true ./install.sh
```

## Requirements

- **Ubuntu** 18.04 LTS or newer
- **Sudo/root access** for package installation
- **Internet connection** for downloading packages and repositories
- **At least 2GB** of free disk space
- **Git** and **curl** (validated during setup)

## Configuration

Environment variables (see `library_scripts/config.sh`):

| Variable | Default | Description |
|----------|---------|-------------|
| `DOTFILES_REPO` | `https://github.com/omoinjm/.dotfiles.git` | Dotfiles HTTPS URL |
| `DOTFILES_OPTIONAL` | `false` | Continue if dotfiles clone fails |
| `INSTALL_TERRAFORM` | `false` | Install Terraform |
| `INSTALL_NEBIUS_CLI` | `false` | Install Nebius CLI |
| `INSTALL_DOTNET` | `false` | Install .NET SDK |

## Documentation

For more information, see the [docs/](docs/) folder:

- **[START_HERE.md](docs/START_HERE.md)** — Onboarding guide
- **[OVERVIEW.md](docs/OVERVIEW.md)** — Project details and features
- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** — Technical architecture
- **[INSTALLATION_GUIDE.md](docs/INSTALLATION_GUIDE.md)** — Detailed setup instructions
- **[TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** — Common issues and solutions
- **[ADDING_MODULES.md](docs/ADDING_MODULES.md)** — How to add new tools
- **[AI_CONTEXT.md](docs/AI_CONTEXT.md)** — Context for AI systems analyzing this code

## What Happens During Installation

1. Validates system prerequisites (OS, sudo, disk, curl)
2. Updates system package repositories and adds PPAs
3. Clones personal dotfiles from GitHub
4. Installs and configures each tool in sequence
5. Verifies installations and prints next steps
6. Writes a log to `~/.ubuntu-setup-install.log`

## Post-Installation Steps

```bash
# Set Fish as your default shell
chsh -s /usr/bin/fish

# Logout and login for changes to take effect
```

## Uninstall

```bash
./uninstall.sh
```

## Development / CI

```bash
./scripts/ci-smoke.sh
```

GitHub Actions runs syntax checks, ShellCheck, and structural smoke tests on every push and pull request.

## Troubleshooting

If installation fails, check [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for solutions to common issues.

## License

See [LICENSE](LICENSE) for details.
