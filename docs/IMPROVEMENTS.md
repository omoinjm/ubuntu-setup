# Recommended Improvements

This document outlines improvements organized by priority and impact.

---

## 🔴 Critical Issues (Must Fix)

### 1. **install-neovim.sh is Empty**

**Problem:** The neovim installation script is completely empty (1 line only)

**Impact:** neovim installation will fail silently

**Fix:**
```bash
#!/bin/bash

# Check if neovim is installed
if ! command -v nvim &> /dev/null; then
    printf "neovim not found. Installing...\n"
    sudo apt-get -qq update > /dev/null 2>&1 && sudo apt-get -qq install -y neovim > /dev/null 2>&1
    printf "neovim successfully installed.\n\n"
else
    printf "neovim is already installed.\n\n"
fi
```

---

### 2. **Hardcoded Paths in Scripts**

**Problem:** Scripts use hardcoded user path `/home/njm/` instead of `$HOME` or `~`

**Location:** `src/install-fish.sh` line with lsd extraction

**Current:**
```bash
tar -xzf /home/njm/lsd-v1.1.5-x86_64-unknown-linux-gnu.tar.gz -C $CONFIG_DIR
```

**Should be:**
```bash
tar -xzf $CONFIG_DIR/lsd-v1.1.5-x86_64-unknown-linux-gnu.tar.gz -C $CONFIG_DIR
```

**Impact:** Script fails for any user except 'njm'

---

### 3. **Missing Error Handling and Exit Codes**

**Problem:** Many scripts don't return exit codes or check for errors

**Examples:**
- `install-neovim.sh` - completely empty, returns non-zero automatically
- `install-fish.sh` - doesn't check if `ln -s` succeeds
- `install-nodejs.sh` - curl pipeline has no error checking
- `setup-dotfiles.sh` - runs commands but doesn't verify success

**Fix Pattern:**
```bash
#!/bin/bash
set -e  # Exit on any error

# ... rest of script
```

---

### 4. **Missing Variable Definitions**

**Problem:** Scripts reference undefined variables like `$FISH_DIR`, `$TMUX_DIR`, `$CONFIG_DIR`

**Current:** These are never defined in the scripts

**Fix:** Define at the top of each script:
```bash
#!/bin/bash
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
FISH_DIR="$CONFIG_DIR/fish"
TMUX_DIR="$CONFIG_DIR/tmux"
```

---

### 5. **Inconsistent Symlink Creation (Will Fail)**

**Problem:** Scripts create symlinks without checking if target exists or if link already exists

**Locations:**
- `install-fish.sh`: `ln -s $FISH_DIR ~/.config/fish`
- `install-tmux.sh`: `ln -s $TMUX_DIR ~/.config/tmux`

**Issues:**
- `$FISH_DIR` expands to `~/.config/fish`, so command becomes `ln -s ~/.config/fish ~/.config/fish` (invalid)
- Link creation will fail if directory already exists
- No error checking

**Fix:**
```bash
# Only link if dotfiles repo has the config
if [ -d "$DOTFILES_REPO/fish" ] && [ ! -e "$FISH_DIR" ]; then
    ln -s "$DOTFILES_REPO/fish" "$FISH_DIR"
fi
```

---

## 🟠 High Priority (Should Fix)

### 6. **Main install.sh Typo**

**Problem:** Line 50 has wrong script name

**Current:**
```bash
if ! ./src/install-nebius-cli; then
```

**Should be:**
```bash
if ! ./src/install-nebius-cli.sh; then
```

---

### 7. **Inconsistent Output Formatting**

**Problem:** Mix of `echo`, `printf`, and different message formats

**Current:**
```bash
echo "tmux not found. Installing..."
printf "fish not found. Installing...\n"
echo "tmux successfully installed!"
printf "fish successfully installed.\n\n"
```

**Fix:** Use consistent approach:
```bash
#!/bin/bash
log() { echo "[INFO] $*"; }
error() { echo "[ERROR] $*" >&2; exit 1; }

log "Installing tool..."
# ... do work
log "Tool installed successfully"
```

---

### 8. **update-repositories.sh Doesn't Check Success**

**Problem:** Script runs but doesn't verify PPA additions worked

**Current:**
```bash
sudo add-apt-repository -y ppa:git-core/ppa > /dev/null 2>&1
```

**Issue:** If PPA fails, no error is reported

**Fix:**
```bash
#!/bin/bash
set -e
# ... rest of script
```

---

### 9. **setup-dotfiles.sh Missing Git Clone**

**Problem:** Script doesn't actually clone the dotfiles repository

**Current:** Only creates directories and sets ownership

**Missing:** Actually pulling the repo from GitHub

**Fix:** Should include:
```bash
DOTFILES_REPO_URL="https://github.com/omoinjm/dotfiles"
DOTFILES_DIR="$HOME/.config/dotfiles"

if [ ! -d "$DOTFILES_DIR" ]; then
    git clone "$DOTFILES_REPO_URL" "$DOTFILES_DIR"
fi
```

---

### 10. **install-nodejs.sh Uses Fisher Before Fish is Installed**

**Problem:** Script calls `fisher add edc/bass` before Fish is installed

**Current order:**
1. `install-fish.sh` installs Fish
2. `install-nodejs.sh` tries to use `fisher` (Fish plugin manager)

**Issue:** Fisher requires Fish to be already installed AND running fish shell

**Fix:**
- Move fisher/nvm setup to `install-fish.sh` after Fish is installed
- Or use source commands that work in bash

---

### 11. **No Validation of Tool Installation**

**Problem:** Scripts only check if tools exist after install, not if they actually work

**Current:**
```bash
if ! command -v tmux &> /dev/null; then
    # install
else
    echo "already installed"
fi
```

**Missing:** Version check or basic command execution

**Fix:**
```bash
# Verify it actually works
if tmux -V &> /dev/null; then
    log "tmux verified"
else
    error "tmux installation failed verification"
fi
```

---

## 🟡 Medium Priority (Nice to Have)

### 12. **No Version Pinning**

**Problem:** Installations use latest versions, but don't track what versions were installed

**Impact:** Reproducing the same setup later may install different versions

**Fix:** Create a `versions.txt` file after installation:
```bash
tmux --version >> ~/.setup-versions.txt
fish --version >> ~/.setup-versions.txt
# etc.
```

---

### 13. **No Uninstall Script**

**Problem:** Only installation scripts exist, no way to cleanly uninstall

**Improvement:** Create `uninstall.sh`:
```bash
#!/bin/bash
# Uninstall all tools in reverse order
./src/uninstall-nebius-cli.sh
./src/uninstall-terraform.sh
# etc.
```

---

### 14. **README.md is Too Minimal**

**Problem:** Main README only has one line

**Current:**
```
# omoinjm's linux terminal setup (Ubuntu)
```

**Fix:** Should have:
- What this project does
- Quick start instructions
- Link to documentation
- Prerequisites
- Typical use case

**Suggested:**
```markdown
# Ubuntu Development Environment Setup

Automated installation script to set up a complete modern development 
environment on Ubuntu with tmux, Fish shell, Neovim, Node.js, Terraform, 
and cloud tools.

## Quick Start

```bash
git clone https://github.com/omoinjm/ubuntu-setup.git
cd ubuntu-setup
chmod +x install.sh src/*.sh
./install.sh
```

## Documentation

See [docs/README.md](docs/README.md) for comprehensive guides.

## What Gets Installed

- tmux - Terminal multiplexer
- Fish - Advanced shell
- Neovim - Text editor
- Node.js - JavaScript runtime
- Terraform - Infrastructure-as-code
- Nebius CLI - Cloud CLI
- Dotfiles - Personal configurations

## Requirements

- Ubuntu 18.04+ LTS
- Sudo access
- Internet connection
```

---

### 15. **No Progress Indicator or Timing**

**Problem:** Users don't know how long installation takes or progress

**Improvement:**
```bash
start_time=$(date +%s)

# ... do work ...

end_time=$(date +%s)
duration=$((end_time - start_time))
echo "Installation completed in ${duration}s"
```

---

### 16. **Missing Pre-flight Checks**

**Problem:** No validation that system is suitable for installation

**Should check:**
- Ubuntu version compatibility
- Disk space available
- Internet connectivity
- Sudo privileges

**Fix:** Add `src/check-prerequisites.sh`:
```bash
#!/bin/bash
# Check Ubuntu version
# Check disk space
# Check internet
# Check sudo
```

---

### 17. **Dotfiles Repository Not Referenced**

**Problem:** Setup mentions dotfiles but doesn't link to the dotfiles repo

**Missing from setup-dotfiles.sh:**
- URL to the actual dotfiles repository
- What dotfiles are being installed

**Fix:** Add comment with repo URL and document which configs come from dotfiles

---

### 18. **No Logging**

**Problem:** No record of what was installed and when

**Improvement:** Add logging:
```bash
LOG_FILE="$HOME/.setup-install.log"
log() { 
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}
```

---

## 🟢 Low Priority (Polish)

### 19. **Inconsistent Indentation**

**Problem:** Mix of 2-space, 4-space, and tab indentation

**Fix:** Standardize to 4-space indentation throughout

---

### 20. **Missing Script Headers**

**Problem:** Some scripts lack description headers

**Fix:** Add to all scripts:
```bash
#!/bin/bash
# Script: install-tool.sh
# Purpose: Install and configure tool-name
# Exit codes: 0 = success, 1 = failure
```

---

### 21. **lsd Installation is Over-Complicated**

**Problem:** `install-fish.sh` has complex lsd installation with hardcoded version

**Current:**
```bash
curl -Lo $CONFIG_DIR/lsd-v1.1.5-x86_64-unknown-linux-gnu.tar.gz \
    https://github.com/lsd-rs/lsd/releases/download/v1.1.5/...
tar -xzf ...
sudo mv ...
```

**Fix:** Use simpler approach:
```bash
# Try package manager first
if sudo apt-get install -y lsd 2>/dev/null; then
    log "lsd installed from repository"
else
    # Fallback to latest release
    log "Installing lsd from GitHub releases"
    # ... simpler approach
fi
```

---

### 22. **Nebius CLI Security**

**Problem:** Script pipes curl output to bash without verification

**Current:**
```bash
curl -sSL https://storage.eu-north1.nebius.cloud/cli/install.sh | bash
```

**Fix:** More secure approach:
```bash
installer_script=$(mktemp)
trap "rm $installer_script" EXIT
curl -sSL https://storage.eu-north1.nebius.cloud/cli/install.sh > "$installer_script"
# Optionally: verify checksum
bash "$installer_script"
```

---

### 23. **No Rollback on Partial Failure**

**Problem:** If installation fails halfway, system is in inconsistent state

**Improvement:** Document this in `TROUBLESHOOTING.md` and add section on how to recover

---

### 24. **Fish Config Manipulation is Fragile**

**Problem:** Script modifies `config.fish` with `head -n -2` to remove last 2 lines

**Current:**
```bash
head -n -2 $FISH_CONF > temp_file && mv temp_file $FISH_CONF
```

**Issues:**
- Assumes file ends with exactly 2 lines to remove
- No backup
- No error checking
- Could corrupt file

**Fix:**
```bash
# Backup first
cp "$FISH_CONF" "$FISH_CONF.backup"

# Use safer approach
if ! grep -q "oh-my-posh" "$FISH_CONF"; then
    echo "$TEXT_APPEND" >> "$FISH_CONF"
fi
```

---

## Summary of Priority Fixes

| Priority | Item | Impact | Time |
|----------|------|--------|------|
| 🔴 Critical | Empty neovim script | Installation fails | 5 min |
| 🔴 Critical | Hardcoded paths | Works only for user 'njm' | 10 min |
| 🔴 Critical | Missing exit codes | Errors silently ignored | 15 min |
| 🔴 Critical | Undefined variables | Scripts fail | 10 min |
| 🔴 Critical | Symlink logic broken | Fish/tmux config won't link | 10 min |
| 🟠 High | Nebius script name typo | Installation fails | 1 min |
| 🟠 High | Missing git clone | Dotfiles not installed | 5 min |
| 🟠 High | Fisher before Fish | nvm installation fails | 10 min |
| 🟡 Medium | Minimal README | Poor first impression | 10 min |
| 🟡 Medium | No logging | Can't debug issues | 15 min |

---

## Recommended Implementation Order

1. **Phase 1 (Critical)** - Fix breaking issues:
   - [ ] Write neovim script
   - [ ] Fix hardcoded paths
   - [ ] Add `set -e` to all scripts
   - [ ] Define variables
   - [ ] Fix symlink logic
   - [ ] Fix nebius script name typo

2. **Phase 2 (High Priority)** - Fix functionality:
   - [ ] Add git clone to setup-dotfiles
   - [ ] Move fisher setup to fish script
   - [ ] Add validation checks
   - [ ] Add comprehensive error handling

3. **Phase 3 (Medium)** - Improve usability:
   - [ ] Enhance README.md
   - [ ] Add logging
   - [ ] Add pre-flight checks
   - [ ] Standardize output formatting

4. **Phase 4 (Polish)** - Clean up:
   - [ ] Fix indentation
   - [ ] Add script headers
   - [ ] Simplify complex installs
   - [ ] Improve security

---

## Testing After Fixes

After implementing these improvements, test:

```bash
# Run on clean Ubuntu VM
git clone <repo>
cd ubuntu-setup
./install.sh

# Verify all tools installed
tmux -V
fish --version
nvim --version
node --version
terraform --version
nebius --version

# Verify configs linked correctly
ls -la ~/.config/fish
ls -la ~/.config/tmux

# Check for errors in log
cat ~/.setup-install.log
```
