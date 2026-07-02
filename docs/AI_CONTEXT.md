# AI Context Guide

Essential context for AI systems analyzing, modifying, or extending this codebase.

## Project Summary

- **Name:** ubuntu-setup
- **Type:** Automated Linux environment setup
- **Language:** Bash
- **Purpose:** One-command installation of a development environment on Ubuntu
- **Modules:** `library_scripts/` (not `src/`)

## Key Design Decisions

| Decision | Reason |
|----------|--------|
| Modular scripts in `library_scripts/` | Each tool is isolated and testable |
| `run_step` helper in `install.sh` | Consistent logging and fail-fast behavior |
| Optional tools via env vars | Keep default install lean |
| `lib/logging.sh` | Structured install logs at `~/.ubuntu-setup-install.log` |
| `lib/progress.sh` | Spinners, command echo, and `pv`-backed download progress |
| `install-plan.sh` | Pre-install summary; `--show-plan` exits before changes |
| `scripts/ci-smoke.sh` | Local and CI validation |

## Naming Conventions

- **Main script:** `install.sh`
- **Modules:** `library_scripts/install-<tool>.sh`
- **Setup scripts:** `library_scripts/setup-<component>.sh`
- **Helpers:** `library_scripts/helpers.sh`, `library_scripts/install-plan.sh`
- **Config:** `library_scripts/config.sh`

## Code Patterns

**Main orchestration (`install.sh`):**

```bash
run_step "Installing tmux" "$LIB_DIR/install-tmux.sh"
```

**Optional module:**

```bash
if [ "$INSTALL_TERRAFORM" = "true" ]; then
    run_step "Installing Terraform" "$LIB_DIR/install-terraform.sh"
fi
```

**Module script:**

```bash
#!/bin/bash
set -e
source "$ROOT_DIR/library_scripts/config.sh"
# install, verify, exit 0 or 1
```

## Execution Flow

```
install.sh
  ├─ init_logging (lib/logging.sh, lib/progress.sh)
  ├─ config.sh
  ├─ install-plan.sh → print_install_plan  (--show-plan exits here)
  ├─ check-prerequisites.sh
  ├─ update-repositories.sh
  ├─ install-pv.sh              (skips when INSTALL_PV=false)
  ├─ setup-dotfiles.sh
  ├─ install-tmux.sh
  ├─ install-fish.sh
  ├─ install-neovim.sh
  ├─ install-nvm.sh
  ├─ install-fzf.sh
  ├─ install-fonts.sh
  ├─ install-terraform.sh      (optional)
  ├─ install-nebius-cli.sh    (optional)
  └─ install-dotnet.sh        (optional)
```

## Common Tasks

### Add a new tool

1. Create `library_scripts/install-<tool>.sh`
2. Add `run_step` call to `install.sh`
3. Add env flag to `config.sh` if optional
4. Update docs and `scripts/ci-smoke.sh`
5. Run `./scripts/ci-smoke.sh`

### Fix a failing install

1. Check `~/.ubuntu-setup-install.log`
2. Run the failing module directly
3. See `docs/TROUBLESHOOTING.md`
4. Re-run `./install.sh`

## Critical Constraints

1. Check exit codes — required modules must fail the install
2. Source `config.sh` for paths and flags
3. Keep modules idempotent where possible
4. Ubuntu-focused — do not assume other distros
5. Update docs when behavior changes
6. Run CI smoke tests before finishing

## Testing Checklist

- [ ] `./library_scripts/install-<tool>.sh`
- [ ] `./install.sh`
- [ ] `./scripts/ci-smoke.sh`
- [ ] Documentation updated

## Security Notes

- Uses `sudo` for system packages
- Downloads installers to temp files before execution (Nebius, NVM)
- Dotfiles use SSH with HTTPS fallback
- No secrets in the repository

## References

- Entry point: `install.sh`
- Config: `library_scripts/config.sh`
- CI: `.github/workflows/ci.yml`, `scripts/ci-smoke.sh`
- Module template: `docs/ADDING_MODULES.md`
