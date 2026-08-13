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
    library_scripts/install-zsh.sh
    library_scripts/install-bash-enhancements.sh
    library_scripts/install-oh-my-posh.sh
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
test -n "$DOTFILES_CONFIG_DIR"
test -n "$DOTFILES_FISH_DIR"
test -n "$DOTFILES_ZSH_DIR"
test -n "$ZSH_DIR"
test -n "$DOTFILES_LINUX_SHELL_DIR"
grep -q 'refresh_dotfiles_paths' library_scripts/config.sh
grep -q 'install/link.sh' library_scripts/setup-dotfiles.sh
echo "  config exports look valid"

echo
echo "==> Install plan"
# shellcheck source=library_scripts/install-plan.sh
source library_scripts/install-plan.sh
plan_file=$(mktemp)
SHOW_INSTALL_PLAN=true INSTALL_TERRAFORM=false INSTALL_NEBIUS_CLI=false INSTALL_DOTNET=false \
    print_install_plan >"$plan_file"
grep -q "Installation Plan" "$plan_file"
grep -q "tmux" "$plan_file"
grep -q "Fish shell" "$plan_file"
rm -f "$plan_file"
echo "  install plan renders (default: fish on, zsh off)"

plan_file=$(mktemp)
SHOW_INSTALL_PLAN=true INSTALL_FISH=false INSTALL_ZSH=true \
INSTALL_TERRAFORM=false INSTALL_NEBIUS_CLI=false INSTALL_DOTNET=false \
    print_install_plan >"$plan_file"
grep -q "Zsh shell" "$plan_file"
if grep -q "Fish shell" "$plan_file"; then
    echo "Fish shell should not appear in the plan when INSTALL_FISH=false" >&2
    exit 1
fi
rm -f "$plan_file"
echo "  install plan renders (INSTALL_FISH=false, INSTALL_ZSH=true)"

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
