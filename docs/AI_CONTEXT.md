# AI Context Guide

This document provides essential context for AI systems (like Claude, ChatGPT, GitHub Copilot, etc.) analyzing, modifying, or extending this codebase.

## Project Summary at a Glance

- **Name:** ubuntu-setup
- **Type:** Automated Linux environment setup
- **Language:** Bash shell scripting
- **Purpose:** One-command installation of a complete development environment for Ubuntu
- **Scope:** 8 tools across system management, editing, runtime, and cloud operations

## Key Information for AI Assistants

### Project Goals

1. **Automation** - Eliminate manual configuration steps
2. **Reproducibility** - Ensure consistent setups across machines
3. **Modularity** - Each tool is independently installable
4. **Reliability** - Fail fast with clear error messages
5. **User-Friendly** - Minimal user interaction required

### Critical Design Decisions

| Decision | Reason | Impact |
|----------|--------|--------|
| Modular scripts in `src/` | Easy to update/extend | Each tool is isolated |
| Sequential execution | Clear dependency management | Fail fast if any step fails |
| Exit code checking | Robust error handling | Installation stops on first failure |
| User feedback via echo | Transparency | Users know what's happening |
| No rollback mechanism | Simplicity | Users should have backups |

### Naming Conventions

- **Main script:** `install.sh`
- **Module scripts:** `src/install-<toolname>.sh`
- **Update scripts:** `src/update-<component>.sh`
- **Config scripts:** `src/setup-<component>.sh`

### Code Patterns to Follow

**Main script pattern:**
```bash
if ! ./src/install-<tool>.sh; then
    echo "Failed to install <tool>. Exiting."
    exit 1
fi
```

**Module script pattern:**
```bash
#!/bin/bash
set -e
# Check prerequisites
# Install package
# Verify installation
exit 0
```

## Common Tasks and Approaches

### Task: Add a New Tool

1. Create `src/install-<toolname>.sh`
2. Add execution block to `install.sh` with error checking
3. Update `docs/ARCHITECTURE.md` and `docs/OVERVIEW.md`
4. Test in isolation and full run

See `docs/ADDING_MODULES.md` for detailed guide.

### Task: Fix a Failing Installation

1. Identify which script is failing (check error message)
2. Review the script in `src/`
3. Check `docs/TROUBLESHOOTING.md` for known issues
4. Make targeted fix to single script
5. Test the specific script: `./src/install-<tool>.sh`
6. Test full installation: `./install.sh`

### Task: Update Documentation

- High-level overview: `docs/OVERVIEW.md`
- Technical details: `docs/ARCHITECTURE.md`
- How-to guides: `docs/INSTALLATION_GUIDE.md`, `docs/ADDING_MODULES.md`
- Problem solving: `docs/TROUBLESHOOTING.md`
- AI context: `docs/AI_CONTEXT.md` (this file)

### Task: Understand Execution Flow

```
install.sh
  ├─ update-repositories.sh (prepare system)
  ├─ setup-dotfiles.sh (fetch configs)
  ├─ install-tmux.sh (terminal multiplexer)
  ├─ install-fish.sh (shell)
  ├─ install-neovim.sh (editor)
  ├─ install-nodejs.sh (runtime)
  ├─ install-terraform.sh (infrastructure)
  └─ install-nebius-cli.sh (cloud CLI)
```

Each script must succeed for the next to run.

## Critical Constraints

### Do NOT Violate These

1. **Error Handling** - Always check exit codes with `if ! ... ; then ... exit 1; fi`
2. **User Feedback** - Always echo progress messages
3. **Exit Codes** - Return 0 on success, 1 on failure
4. **Script Independence** - Each script should be testable alone
5. **Idempotency** - Installing twice shouldn't cause issues
6. **Ubuntu Compatibility** - Support Ubuntu 18.04 LTS and newer

### Things That Would Break the Project

- Scripts without proper error checking
- Not returning correct exit codes
- Silent failures with no user feedback
- Dependencies between scripts not documented
- Scripts that require manual intervention
- Modifications that change install order without reason

## File Relationships

```
README.md ─────→ Quick project overview
            ├──→ docs/README.md ────→ Documentation index
            ├──→ docs/OVERVIEW.md ──→ What the project does
            ├──→ docs/ARCHITECTURE.md → How it's structured
            ├──→ docs/INSTALLATION_GUIDE.md → How to use it
            ├──→ docs/ADDING_MODULES.md → How to extend it
            ├──→ docs/TROUBLESHOOTING.md → How to fix problems
            └──→ docs/AI_CONTEXT.md → This file

install.sh ──→ Orchestrates installations
src/*.sh ──→ Individual tool installation scripts
```

## Before Making Changes

✓ Read the relevant documentation file

✓ Understand why the current implementation works

✓ Check `docs/TROUBLESHOOTING.md` for known issues

✓ Plan the minimal change needed

✓ Test in isolation (individual script)

✓ Test full integration (entire install.sh)

✓ Update documentation if behavior changes

## Testing Checklist for Any Change

- [ ] Individual script works: `./src/install-<tool>.sh`
- [ ] Full installation works: `./install.sh`
- [ ] Error handling works (introduce intentional error)
- [ ] User feedback is clear (review all echo messages)
- [ ] Documentation is updated
- [ ] No breaking changes to existing behavior

## Performance Considerations

- Typical installation: 10-30 minutes
- Bottleneck: Package downloads and compilation
- Optimization: Minimize redundant updates (use `-qq` for apt)
- User experience: Show progress, don't wait silently

## Security Considerations

- Scripts use `sudo` for system-wide installations
- Private dotfiles handled via SSH/GitHub credentials
- No hardcoded passwords or secrets
- User runs scripts explicitly (not auto-executed)

## Common Misconceptions to Avoid

❌ Scripts need to support all Linux distros (NO - Ubuntu only)

❌ Need a rollback mechanism (NO - users should have backups)

❌ Tools can be installed in any order (NO - follow the sequence)

❌ Scripts should check if tools already exist (NO - idempotency is nice but not required)

✓ Scripts should be simple and focused

✓ Error messages should be clear

✓ User feedback is important

## References

- **Official Documentation:** `docs/` folder
- **Ubuntu Package Manager:** apt-get
- **Main Entry Point:** `install.sh`
- **Module Template:** `docs/ADDING_MODULES.md`
