# Ubuntu Development Environment Setup

Automated installation script to set up a complete modern development environment on Ubuntu with modern tools and configurations.

## What Gets Installed

- **tmux** - Terminal multiplexer for session management
- **Fish shell** - Advanced command-line shell with better syntax highlighting
- **Neovim** - Modern text editor based on Vim
- **Node.js** - JavaScript runtime and npm package manager
- **Terraform** - Infrastructure-as-code tool
- **Nebius CLI** - Cloud platform CLI
- **Dotfiles** - Personal configuration files

## Quick Start

```bash
# Clone the repository
git clone https://github.com/omoinjm/ubuntu-setup.git
cd ubuntu-setup

# Make scripts executable
chmod +x install.sh library_scripts/*.sh

# Run the installation
./install.sh
```

## Requirements

- **Ubuntu** 18.04 LTS or newer
- **Sudo/root access** for package installation
- **Internet connection** for downloading packages and repositories
- **At least 2GB** of free disk space
- **Git** (will be installed/updated during setup)

## Installation Time

Typical installation takes **10-30 minutes** depending on:
- Internet connection speed
- System resources
- Number of packages already installed

## Documentation

For more information, see the [docs/](docs/) folder:

- **[OVERVIEW.md](docs/OVERVIEW.md)** - Project details and features
- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** - Technical architecture
- **[INSTALLATION_GUIDE.md](docs/INSTALLATION_GUIDE.md)** - Detailed setup instructions
- **[TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** - Common issues and solutions
- **[ADDING_MODULES.md](docs/ADDING_MODULES.md)** - How to add new tools
- **[IMPROVEMENTS.md](docs/IMPROVEMENTS.md)** - Recent improvements implemented
- **[AI_CONTEXT.md](docs/AI_CONTEXT.md)** - Context for AI systems analyzing this code

## What Happens During Installation

1. Updates system package repositories and adds PPAs
2. Clones personal dotfiles from GitHub
3. Installs and configures each tool in sequence
4. Verifies all installations were successful
5. Provides next steps for post-installation configuration

## Post-Installation Steps

```bash
# Set Fish as your default shell
chsh -s /usr/bin/fish

# Logout and login for changes to take effect
```

## Troubleshooting

If installation fails, check [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for solutions to common issues.

## License

See [LICENSE](LICENSE) for details.

