#!/bin/bash

# Script: lib/progress.sh
# Purpose: Terminal spinners and progress indicators for long-running commands
# Usage: source lib/progress.sh

if [ -n "${_PROGRESS_SH_LOADED:-}" ]; then
    return 0 2>/dev/null || exit 0
fi
_PROGRESS_SH_LOADED=1

readonly PROGRESS_CYAN='\033[0;36m'
readonly PROGRESS_GREEN='\033[0;32m'
readonly PROGRESS_RED='\033[0;31m'
readonly PROGRESS_NC='\033[0m'

SPINNER_PID=""

# Returns 0 when animated progress should be shown.
spinner_enabled() {
    [ "${DISABLE_SPINNER:-false}" != "true" ] \
        && [ "${CI:-}" != "true" ] \
        && [ -t 1 ] \
        && [ -t 2 ]
}

_spinner_worker() {
    local message="$1"
    local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local frame=0

    while true; do
        printf "\r  ${PROGRESS_CYAN}%s${PROGRESS_NC} %s..." "${frames[frame]}" "$message" >&2
        frame=$(( (frame + 1) % ${#frames[@]} ))
        sleep 0.12
    done
}

# Start a background spinner (pairs with spinner_stop).
spinner_start() {
    local message="$1"

    if ! spinner_enabled; then
        SPINNER_PID=""
        return 0
    fi

    _spinner_worker "$message" &
    SPINNER_PID=$!
}

# Stop the background spinner and optionally show a status line.
spinner_stop() {
    local exit_code="${1:-0}"
    local message="${2:-}"

    if [ -n "$SPINNER_PID" ]; then
        kill "$SPINNER_PID" 2>/dev/null || true
        wait "$SPINNER_PID" 2>/dev/null || true
        SPINNER_PID=""
        printf "\r\033[K" >&2
    fi

    if [ -z "$message" ] || ! spinner_enabled; then
        return "$exit_code"
    fi

    if [ "$exit_code" -eq 0 ]; then
        printf "  ${PROGRESS_GREEN}✓${PROGRESS_NC} %s\n" "$message" >&2
    else
        printf "  ${PROGRESS_RED}✗${PROGRESS_NC} %s\n" "$message" >&2
    fi

    return "$exit_code"
}

# Run a command quietly with an inline spinner; logs output on failure.
with_spinner() {
    local message="$1"
    shift
    local output
    local exit_code=0

    output=$(mktemp)
    trap 'rm -f "$output"' RETURN

    if spinner_enabled; then
        spinner_start "$message"
        if ! "$@" >"$output" 2>&1; then
            exit_code=$?
        fi
        spinner_stop "$exit_code" "$message"
    else
        if ! "$@" >"$output" 2>&1; then
            exit_code=$?
        fi
    fi

    if [ -n "${LOG_FILE:-}" ]; then
        {
            echo "── $message ──"
            cat "$output"
            echo
        } >> "$LOG_FILE"
    fi

    if [ "$exit_code" -ne 0 ]; then
        cat "$output" >&2
    fi

    rm -f "$output"
    trap - RETURN
    return "$exit_code"
}

# Run a command with a spinner while still streaming output to the terminal.
with_spinner_live() {
    local message="$1"
    shift
    local exit_code=0

    if ! spinner_enabled; then
        "$@"
        return $?
    fi

    spinner_start "$message"
    if ! "$@"; then
        exit_code=$?
    fi
    spinner_stop "$exit_code"
    return "$exit_code"
}
