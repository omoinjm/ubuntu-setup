#!/bin/bash

# Shared helpers for installation modules (progress + common runners).

if [ -n "${_HELPERS_SH_LOADED:-}" ]; then
    return 0 2>/dev/null || exit 0
fi
_HELPERS_SH_LOADED=1

HELPERS_ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck source=lib/progress.sh
source "$HELPERS_ROOT_DIR/lib/progress.sh"

run_apt() {
    local message="$1"
    shift
    with_spinner "$message" sudo apt-get "$@"
}

run_curl() {
    local message="$1"
    shift
    with_spinner "$message" curl "$@"
}

run_git_clone() {
    local message="$1"
    local repo_url="$2"
    local dest="$3"
    with_spinner "$message" git clone "$repo_url" "$dest"
}
