# Adding New Modules

This guide explains how to add new installation modules to the setup script.

## Module Structure

Each module is a shell script in the `library_scripts/` directory following this naming convention:

```
library_scripts/install-<toolname>.sh
```

## Template for New Modules

```bash
#!/bin/bash

# Script: install-example.sh
# Purpose: Install and configure example tool
# Exit codes: 0 = success, 1 = failure

set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=library_scripts/config.sh
source "$ROOT_DIR/library_scripts/config.sh"

TOOL_NAME="example-tool"

echo "Installing $TOOL_NAME..."

if ! command -v git &> /dev/null; then
    echo "Error: Git is required but not installed."
    exit 1
fi

sudo apt-get -qq update > /dev/null 2>&1
sudo apt-get -qq install -y example-tool > /dev/null 2>&1

if ! command -v example-tool &> /dev/null; then
    echo "Error: $TOOL_NAME installation verification failed."
    exit 1
fi

echo "✓ $TOOL_NAME installed successfully"
exit 0
```

## Step-by-Step: Add a New Tool

### 1. Create the script

```bash
touch library_scripts/install-mynewtool.sh
chmod +x library_scripts/install-mynewtool.sh
```

### 2. Write the script

Follow the template above:

- Add a shebang (`#!/bin/bash`)
- Include a comment header with purpose
- Use `set -e`
- Source `config.sh` for shared paths
- Check prerequisites, install, verify, and return exit codes

### 3. Update `install.sh`

Add your module using the existing `run_step` helper:

```bash
run_step "Installing mynewtool" "$LIB_DIR/install-mynewtool.sh"
```

For optional tools, gate it with an environment variable in `config.sh`:

```bash
export INSTALL_MYNEWTOOL="${INSTALL_MYNEWTOOL:-false}"
```

Then in `install.sh`:

```bash
if [ "$INSTALL_MYNEWTOOL" = "true" ]; then
    run_step "Installing mynewtool" "$LIB_DIR/install-mynewtool.sh"
fi
```

### 4. Update documentation

- Add the tool to `docs/ARCHITECTURE.md`
- Add the tool to `README.md` and `docs/OVERVIEW.md`
- Add troubleshooting notes if needed

### 5. Update CI

Add the new script path to `scripts/ci-smoke.sh` in the `required_modules` array.

### 6. Test

```bash
./library_scripts/install-mynewtool.sh
./install.sh
./scripts/ci-smoke.sh
```

## Best Practices

### Error handling

- Check prerequisites before installation
- Validate with version checks or `command -v`
- Return exit code 1 on failure

### User feedback

- Echo progress messages
- Show tool version after installation
- Use consistent success markers (`✓`)

### Compatibility

- Target Ubuntu LTS releases
- Detect architecture when downloading binaries (`uname -m`)
- Skip or warn when a package is unavailable instead of failing hard for optional extras

## Common Patterns

### Install from apt

```bash
sudo apt-get -qq update > /dev/null 2>&1
sudo apt-get -qq install -y package-name > /dev/null 2>&1
```

### Install from a downloaded script

```bash
installer_script=$(mktemp)
trap 'rm -f "$installer_script"' EXIT
curl -fsSL https://example.com/installer.sh -o "$installer_script"
bash "$installer_script"
```

### Configure with dotfiles

Dotfiles live under `home/.config/<app>` in the repo. After clone, `setup-dotfiles.sh` runs `install/link.sh` to symlink fish, nvim, tmux, and lazygit into `~/.config`. Individual install scripts keep a fallback symlink when `install/link.sh` is missing (legacy `src/config/` layout).

```bash
refresh_dotfiles_paths
if [ -d "$DOTFILES_SOME_DIR" ] && [ ! -e "$SOME_CONFIG_DIR" ]; then
    ln -s "$DOTFILES_SOME_DIR" "$SOME_CONFIG_DIR"
fi
```

## Module Dependencies

If your module depends on another tool:

1. Add a prerequisite check at the start
2. Note the dependency in comments
3. Order `install.sh` so dependencies run first

## Testing Checklist

- [ ] Script runs without errors
- [ ] Tool is installed in the expected location
- [ ] Version command works
- [ ] Configuration is applied correctly
- [ ] Exit code 0 on success, 1 on failure
- [ ] `./scripts/ci-smoke.sh` passes
- [ ] Works on a clean Ubuntu install
