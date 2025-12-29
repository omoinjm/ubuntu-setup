#!/bin/bash

# Script: lib/logging.sh
# Purpose: Provide common logging functions for all scripts
# Usage: source lib/logging.sh

# Color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Log file location
export LOG_FILE="${LOG_FILE:-$HOME/.ubuntu-setup-install.log}"

# Initialize log file
init_logging() {
    mkdir -p "$(dirname "$LOG_FILE")"
    echo "=== Ubuntu Setup Installation Log ===" >> "$LOG_FILE"
    echo "Date: $(date)" >> "$LOG_FILE"
    echo "User: $USER" >> "$LOG_FILE"
    echo "System: $(uname -a)" >> "$LOG_FILE"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >> "$LOG_FILE"
}

# Log a message
log_message() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

# Print info message (console + log)
info() {
    local message="$*"
    echo -e "${BLUE}ℹ $message${NC}"
    log_message "INFO" "$message"
}

# Print success message (console + log)
success() {
    local message="$*"
    echo -e "${GREEN}✓ $message${NC}"
    log_message "SUCCESS" "$message"
}

# Print warning message (console + log)
warn() {
    local message="$*"
    echo -e "${YELLOW}⚠ $message${NC}"
    log_message "WARN" "$message"
}

# Print error message (console + log) and exit
error() {
    local message="$*"
    echo -e "${RED}✗ $message${NC}" >&2
    log_message "ERROR" "$message"
    exit 1
}

# Print section header
section() {
    local message="$*"
    echo
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $message${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo
    log_message "SECTION" "$message"
}

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Verify tool installation
verify_tool() {
    local tool="$1"
    local version_cmd="${2:-$tool --version}"
    
    if command_exists "$tool"; then
        local version=$(eval "$version_cmd" 2>/dev/null || echo "unknown")
        success "$tool installed: $version"
        log_message "VERIFY" "$tool: $version"
        return 0
    else
        warn "$tool not found after installation"
        log_message "VERIFY_FAIL" "$tool: not found"
        return 1
    fi
}

# End logging with summary
end_logging() {
    local status="$1"
    local message="${2:-Installation completed}"
    
    echo >> "$LOG_FILE"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >> "$LOG_FILE"
    echo "Status: $status" >> "$LOG_FILE"
    echo "End Time: $(date)" >> "$LOG_FILE"
    echo "Log file saved to: $LOG_FILE" >> "$LOG_FILE"
    
    if [ "$status" = "SUCCESS" ]; then
        success "$message"
        info "Full log saved to: $LOG_FILE"
    else
        error "$message (see log: $LOG_FILE)"
    fi
}

export -f log_message info success warn error section command_exists verify_tool end_logging init_logging
