#!/bin/bash
# CI smoke tests: syntax validation, static analysis, and structural checks.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "==> Syntax check (bash -n)"
while IFS= read -r -d '' script; do
    bash -n "$script"
    echo "  OK: $script"
done < <(find . -type f -name '*.sh' ! -path './.git/*' -print0)

echo
echo "==> ShellCheck"
if ! command -v shellcheck >/dev/null 2>&1; then
    echo "ShellCheck not installed; skipping."
else
    while IFS= read -r -d '' script; do
        shellcheck -S warning -x "$script"
        echo "  OK: $script"
    done < <(find . -type f -name '*.sh' ! -path './.git/*' -print0)
fi

echo
echo "==> install.sh module references"
required_modules=(
    library_scripts/config.sh
    library_scripts/check-prerequisites.sh
    library_scripts/update-repositories.sh
    library_scripts/setup-dotfiles.sh
    library_scripts/install-tmux.sh
    library_scripts/install-fish.sh
    library_scripts/install-neovim.sh
    library_scripts/install-nvm.sh
    library_scripts/install-fzf.sh
    library_scripts/install-fonts.sh
    library_scripts/install-pv.sh
    library_scripts/install-terraform.sh
    library_scripts/install-nebius-cli.sh
    library_scripts/install-dotnet.sh
    lib/logging.sh
    lib/progress.sh
    library_scripts/helpers.sh
)

for module in "${required_modules[@]}"; do
    if [ ! -f "$module" ]; then
        echo "Missing required module: $module" >&2
        exit 1
    fi
    echo "  found: $module"
done

echo
echo "==> config.sh exports"
# shellcheck source=library_scripts/config.sh
source library_scripts/config.sh
test -n "$CONFIG_DIR"
test -n "$DOTFILES_DIR"
test -n "$DOTFILES_REPO"
echo "  config exports look valid"

echo
echo "==> Progress helpers"
DISABLE_SPINNER=true
# shellcheck source=lib/progress.sh
source lib/progress.sh
with_spinner "Progress helper check" true
test "$(format_elapsed 0)" = "0s"
test "$(format_elapsed 65)" = "1m 05s"
echo "  progress helpers work"

echo
echo "==> Executable bit check"
for script in install.sh uninstall.sh library_scripts/*.sh lib/*.sh scripts/*.sh; do
    if [ -f "$script" ] && [ ! -x "$script" ]; then
        echo "Script is not executable: $script" >&2
        exit 1
    fi
    echo "  executable: $script"
done

echo
echo "All CI smoke checks passed."
