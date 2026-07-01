# Architecture & System Design

## Directory Structure

```
ubuntu-setup/
├── install.sh                      # Main entry point - orchestrates installation
├── uninstall.sh                    # Remove installed tools
├── scripts/
│   └── ci-smoke.sh                 # CI smoke tests (syntax, shellcheck, structure)
├── library_scripts/                # Installation modules
│   ├── config.sh                   # Shared configuration and feature flags
│   ├── check-prerequisites.sh      # Pre-flight system validation
│   ├── update-repositories.sh      # Update apt and add PPAs
│   ├── setup-dotfiles.sh           # Clone dotfiles from GitHub
│   ├── install-tmux.sh
│   ├── install-fish.sh
│   ├── install-neovim.sh
│   ├── install-nvm.sh
│   ├── install-fzf.sh
│   ├── install-fonts.sh
│   ├── install-pv.sh                 # Optional pipe viewer (INSTALL_PV=true, default)
│   ├── install-terraform.sh        # Optional (INSTALL_TERRAFORM=true)
│   ├── install-nebius-cli.sh       # Optional (INSTALL_NEBIUS_CLI=true)
│   └── install-dotnet.sh           # Optional (INSTALL_DOTNET=true)
├── lib/
│   ├── logging.sh                  # Shared logging helpers
│   └── progress.sh                 # Spinner/progress indicators
├── .devcontainer/                  # Docker dev container config
├── .github/workflows/ci.yml        # GitHub Actions CI
└── docs/                           # Documentation
```

## Execution Flow

```
install.sh (main script)
    │
    ├─→ init_logging (lib/logging.sh)
    ├─→ config.sh
    ├─→ check-prerequisites.sh
    ├─→ update-repositories.sh
    ├─→ setup-dotfiles.sh
    ├─→ install-tmux.sh
    ├─→ install-fish.sh
    ├─→ install-neovim.sh
    ├─→ install-nvm.sh
    ├─→ install-fzf.sh
    ├─→ install-fonts.sh
    ├─→ install-terraform.sh          (if INSTALL_TERRAFORM=true)
    ├─→ install-nebius-cli.sh       (if INSTALL_NEBIUS_CLI=true)
    └─→ install-dotnet.sh           (if INSTALL_DOTNET=true)

Success: All installations complete, log written to ~/.ubuntu-setup-install.log
```

## Module Design Pattern

Each installation script in `library_scripts/` follows this pattern:

1. **Load config** — Source `config.sh` for paths and flags
2. **Check prerequisites** — Verify dependencies are available
3. **Install package** — Use apt, curl, or vendor installers
4. **Configure** — Symlink dotfiles or write shell integration
5. **Verify installation** — Test that the tool works
6. **Report status** — Return exit code 0 (success) or 1 (failure)

## Error Handling Strategy

- **Fail fast** — Main script stops if any required module fails
- **Optional modules** — Controlled by environment variables in `config.sh`
- **Dotfiles** — Clone failure exits unless `DOTFILES_OPTIONAL=true`
- **Exit codes** — Scripts use 0 for success, 1 for failure
- **Logging** — `install.sh` writes structured logs via `lib/logging.sh`

## Dependencies

### External

- Ubuntu/Debian package system (`apt`, `add-apt-repository`)
- Git and curl for downloads and dotfiles
- HashiCorp apt repo (Terraform, when enabled)
- GitHub releases (fzf, NVM, Nerd Fonts)

### Internal

- All modules source `library_scripts/config.sh`
- `install.sh` orchestrates modules in dependency order
- Dotfiles are cloned before tool modules that symlink configs
