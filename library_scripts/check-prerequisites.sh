#!/bin/bash

# Script: src/check-prerequisites.sh
# Purpose: Verify system is ready for installation
# Exit codes: 0 = success, 1 = failure

set -e

echo "Checking system prerequisites..."
echo

# Check Ubuntu version
check_ubuntu_version() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [ "$ID" != "ubuntu" ]; then
            echo "⚠ Warning: This system is not Ubuntu ($ID). Some tools may not install correctly."
            return 0
        fi
        echo "✓ Ubuntu detected: $PRETTY_NAME"
        return 0
    else
        echo "⚠ Warning: Could not determine OS type"
        return 0
    fi
}

# Check sudo access
check_sudo() {
    if sudo -n true 2>/dev/null; then
        echo "✓ Sudo access confirmed (no password prompt needed)"
        return 0
    elif command -v sudo &> /dev/null; then
        echo "✓ Sudo is available (password may be required)"
        return 0
    else
        echo "✗ Error: Sudo is required but not found"
        return 1
    fi
}

# Check internet connectivity
check_internet() {
    if ping -c 1 8.8.8.8 &> /dev/null; then
        echo "✓ Internet connectivity confirmed"
        return 0
    else
        echo "⚠ Warning: Could not ping 8.8.8.8 (DNS may be down)"
        return 0
    fi
}

# Check disk space
check_disk_space() {
    local available=$(df $HOME | awk 'NR==2 {print $4}')
    local required=$((2000000)) # 2GB in KB
    
    if [ "$available" -gt "$required" ]; then
        local gb=$((available / 1048576))
        echo "✓ Sufficient disk space available (~${gb}GB)"
        return 0
    else
        local gb=$((available / 1048576))
        echo "⚠ Warning: Low disk space available (~${gb}GB). Minimum 2GB recommended."
        return 0
    fi
}

# Check if Git is installed
check_git() {
    if command -v git &> /dev/null; then
        local version=$(git --version)
        echo "✓ Git is installed: $version"
        return 0
    else
        echo "⚠ Warning: Git is not installed. It will be installed during setup."
        return 0
    fi
}

# Check if curl is installed
check_curl() {
    if command -v curl &> /dev/null; then
        echo "✓ curl is installed"
        return 0
    else
        echo "✗ Error: curl is required but not installed"
        return 1
    fi
}

# Check if wget is installed
check_wget() {
    if command -v wget &> /dev/null; then
        echo "✓ wget is installed"
        return 0
    else
        echo "⚠ Warning: wget is not installed. Some installers may fail."
        return 0
    fi
}

echo "─────────────────────────────────────────────────────────────────"
check_ubuntu_version
check_sudo || exit 1
check_internet
check_disk_space
check_git
check_curl || exit 1
check_wget
echo "─────────────────────────────────────────────────────────────────"
echo

echo "✓ Prerequisites check completed"
exit 0
