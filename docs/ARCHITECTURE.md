# Architecture & System Design

## Directory Structure

```
ubuntu-setup/
├── install.sh                      # Main entry point - orchestrates installation
├── src/                            # Installation scripts
│   ├── update-repositories.sh      # Update system package lists
│   ├── setup-dotfiles.sh           # Clone dotfiles from GitHub
│   ├── install-tmux.sh             # Terminal multiplexer
│   ├── install-fish.sh             # Advanced shell
│   ├── install-neovim.sh           # Text editor
│   ├── install-nodejs.sh           # JavaScript runtime
│   ├── install-terraform.sh        # Infrastructure-as-code tool
│   └── install-nebius-cli.sh       # Cloud CLI
├── .devcontainer/                  # Docker dev container config
├── docs/                           # Documentation
└── LICENSE                         # Project license
```

## Execution Flow

```
install.sh (main script)
    │
    ├─→ update-repositories.sh
    │   └─→ Updates apt package lists
    │
    ├─→ setup-dotfiles.sh
    │   └─→ Clones GitHub dotfiles repo
    │
    ├─→ install-tmux.sh
    │   └─→ Installs tmux and dependencies
    │
    ├─→ install-fish.sh
    │   └─→ Installs Fish shell and configs
    │
    ├─→ install-neovim.sh
    │   └─→ Installs Neovim and plugins
    │
    ├─→ install-nodejs.sh
    │   └─→ Installs Node.js and npm
    │
    ├─→ install-terraform.sh
    │   └─→ Installs Terraform
    │
    └─→ install-nebius-cli.sh
        └─→ Installs Nebius CLI tool

Success: All installations complete
```

## Module Design Pattern

Each installation script (`src/*.sh`) follows this pattern:

1. **Check Prerequisites** - Verify dependencies are available
2. **Install Package** - Use appropriate package manager (apt, npm, etc.)
3. **Configure** - Set up configuration files or environment variables
4. **Verify Installation** - Test that the tool works
5. **Report Status** - Return appropriate exit codes

## Error Handling Strategy

- **Fail Fast** - Main script stops if any module fails
- **Exit Codes** - Scripts use exit code 1 for failure, 0 for success
- **User Feedback** - Echo messages before each installation step

## Dependencies

### External
- Ubuntu/Debian package system
- Git (for cloning dotfiles)
- Package managers: apt, npm, etc.

### Internal
- All scripts source a common directory context
- Scripts assume sequential execution order
