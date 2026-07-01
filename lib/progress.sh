#!/bin/bash

# Script: lib/progress.sh
# Purpose: Terminal spinners, elapsed time, and download progress indicators
# Usage: source lib/progress.sh

if [ -n "${_PROGRESS_SH_LOADED:-}" ]; then
    return 0 2>/dev/null || exit 0
fi
_PROGRESS_SH_LOADED=1

readonly PROGRESS_CYAN='\033[0;36m'
readonly PROGRESS_GREEN='\033[0;32m'
readonly PROGRESS_RED='\033[0;31m'
readonly PROGRESS_DIM='\033[2m'
readonly PROGRESS_NC='\033[0m'

SPINNER_PID=""
SPINNER_START=0

# Returns 0 when animated progress should be shown.
spinner_enabled() {
    [ "${DISABLE_SPINNER:-false}" != "true" ] \
        && [ "${CI:-}" != "true" ] \
        && [ -t 1 ] \
        && [ -t 2 ]
}

# Format seconds as "42s" or "1m 42s".
format_elapsed() {
    local total="${1:-0}"
    local minutes=$((total / 60))
    local seconds=$((total % 60))

    if [ "$minutes" -gt 0 ]; then
        printf '%dm %02ds' "$minutes" "$seconds"
    else
        printf '%ds' "$seconds"
    fi
}

_log_progress_output() {
    local message="$1"
    local details="${2:-}"

    if [ -n "${LOG_FILE:-}" ]; then
        {
            echo "── $message ──"
            [ -n "$details" ] && echo "$details"
            echo
        } >> "$LOG_FILE"
    fi
}

# Print the shell command before it runs (when SHOW_INSTALL_COMMANDS=true).
announce_command() {
    [ "${SHOW_INSTALL_COMMANDS:-true}" = "true" ] || return 0
    printf "  ${PROGRESS_DIM}\$ %s${PROGRESS_NC}\n" "$*" >&2
    if [ -n "${LOG_FILE:-}" ]; then
        echo "CMD: $*" >> "$LOG_FILE"
    fi
}

_spinner_worker() {
    local message="$1"
    local start="${2:-$SECONDS}"
    local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local frame=0
    local elapsed

    while true; do
        elapsed=$(format_elapsed $((SECONDS - start)))
        printf "\r  ${PROGRESS_CYAN}%s${PROGRESS_NC} %s ${PROGRESS_DIM}(%s)${PROGRESS_NC}..." \
            "${frames[frame]}" "$message" "$elapsed" >&2
        frame=$(( (frame + 1) % ${#frames[@]} ))
        sleep 0.12
    done
}

# Start a background spinner (pairs with spinner_stop).
spinner_start() {
    local message="$1"

    if ! spinner_enabled; then
        SPINNER_PID=""
        SPINNER_START=0
        return 0
    fi

    SPINNER_START=$SECONDS
    _spinner_worker "$message" "$SPINNER_START" &
    SPINNER_PID=$!
}

# Stop the background spinner and optionally show a status line.
spinner_stop() {
    local exit_code="${1:-0}"
    local message="${2:-}"
    local elapsed=""

    if [ -n "$SPINNER_PID" ]; then
        kill "$SPINNER_PID" 2>/dev/null || true
        wait "$SPINNER_PID" 2>/dev/null || true
        SPINNER_PID=""
        printf "\r\033[K" >&2
    fi

    if [ "$SPINNER_START" -gt 0 ]; then
        elapsed=$(format_elapsed $((SECONDS - SPINNER_START)))
        SPINNER_START=0
    fi

    if [ -z "$message" ] || ! spinner_enabled; then
        return "$exit_code"
    fi

    if [ "$exit_code" -eq 0 ]; then
        printf "  ${PROGRESS_GREEN}✓${PROGRESS_NC} %s ${PROGRESS_DIM}(%s)${PROGRESS_NC}\n" "$message" "$elapsed" >&2
    else
        printf "  ${PROGRESS_RED}✗${PROGRESS_NC} %s ${PROGRESS_DIM}(%s)${PROGRESS_NC}\n" "$message" "$elapsed" >&2
    fi

    return "$exit_code"
}

# Run a command quietly with an inline spinner; logs output on failure.
with_spinner() {
    local message="$1"
    shift
    local output
    local exit_code=0

    announce_command "$*"

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

    if [ "$exit_code" -eq 0 ]; then
        _log_progress_output "$message" "completed"
    else
        _log_progress_output "$message" "$(cat "$output")"
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

    announce_command "$*"

    if ! spinner_enabled; then
        "$@"
        return $?
    fi

    spinner_start "$message"
    if ! "$@"; then
        exit_code=$?
    fi
    spinner_stop "$exit_code" "$message"
    return "$exit_code"
}

_get_remote_content_length() {
    local url="$1"
    curl -fsI "$url" 2>/dev/null | awk 'tolower($1) == "content-length:" { print $2 }' | tr -d '\r'
}

# Install pv on demand when enabled and missing (no-op if already present).
_ensure_pv_available() {
    command -v pv &>/dev/null && return 0
    [ "${INSTALL_PV:-true}" = "true" ] || return 1

    if ! command -v apt-get &>/dev/null; then
        return 1
    fi

    with_spinner "Installing pv (pipe viewer)" sudo apt-get -qq install -y pv
    command -v pv &>/dev/null
}

_download_with_pv() {
    local message="$1"
    local url="$2"
    local dest="$3"
    local size

    _ensure_pv_available || return 1

    size=$(_get_remote_content_length "$url")
    [ -n "$size" ] && [ "$size" -gt 0 ] 2>/dev/null || return 1

    curl -fsL "$url" | pv -s "$size" -N "$message" -f -brap -e >"$dest"
}

_download_with_curl_bar() {
    local message="$1"
    local url="$2"
    local dest="$3"
    local start=$SECONDS
    local ticker_pid=""
    local exit_code=0

    printf "  ${PROGRESS_CYAN}↓${PROGRESS_NC} %s  ${PROGRESS_DIM}(%s)${PROGRESS_NC}\n" \
        "$message" "$(format_elapsed 0)" >&2

    (
        while true; do
            sleep 1
            printf "\033[1F\r  ${PROGRESS_CYAN}↓${PROGRESS_NC} %s  ${PROGRESS_DIM}(%s)${PROGRESS_NC}\n" \
                "$message" "$(format_elapsed $((SECONDS - start)))" >&2
        done
    ) &
    ticker_pid=$!

    if curl -fSL --progress-bar "$url" -o "$dest" >&2; then
        exit_code=0
    else
        exit_code=1
    fi

    kill "$ticker_pid" 2>/dev/null || true
    wait "$ticker_pid" 2>/dev/null || true
    printf "\033[2F\r\033[K" >&2

    if [ "$exit_code" -eq 0 ]; then
        printf "  ${PROGRESS_GREEN}✓${PROGRESS_NC} %s  ${PROGRESS_DIM}(%s)${PROGRESS_NC}\n" \
            "$message" "$(format_elapsed $((SECONDS - start)))" >&2
    else
        printf "  ${PROGRESS_RED}✗${PROGRESS_NC} %s  ${PROGRESS_DIM}(%s)${PROGRESS_NC}\n" \
            "$message" "$(format_elapsed $((SECONDS - start)))" >&2
    fi

    return "$exit_code"
}

# Download a file with live elapsed time and a progress bar.
download_with_progress() {
    local message="$1"
    local url="$2"
    local dest="$3"
    local start=$SECONDS
    local exit_code=0

    if ! spinner_enabled; then
        announce_command "curl -fsSL -o $(printf '%q' "$dest") $(printf '%q' "$url")"
        if curl -fsSL -o "$dest" "$url"; then
            _log_progress_output "$message" "downloaded $url"
            return 0
        fi
        _log_progress_output "$message" "failed to download $url"
        return 1
    fi

    _ensure_pv_available || true

    announce_command "curl -fsL $(printf '%q' "$url") | pv -s <bytes> -N $(printf '%q' "$message") > $(printf '%q' "$dest")"
    if _download_with_pv "$message" "$url" "$dest"; then
        printf "  ${PROGRESS_GREEN}✓${PROGRESS_NC} %s  ${PROGRESS_DIM}(%s)${PROGRESS_NC}\n" \
            "$message" "$(format_elapsed $((SECONDS - start)))" >&2
        _log_progress_output "$message" "downloaded via pv: $url"
        return 0
    fi

    announce_command "curl -fSL --progress-bar $(printf '%q' "$url") -o $(printf '%q' "$dest")"
    if _download_with_curl_bar "$message" "$url" "$dest"; then
        _log_progress_output "$message" "downloaded via curl: $url"
        return 0
    fi

    exit_code=$?
    _log_progress_output "$message" "failed to download $url"
    return "$exit_code"
}
