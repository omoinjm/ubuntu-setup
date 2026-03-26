#!/bin/bash

# Script: install-dotnet.sh
# Purpose: Install .NET SDK and runtime
# Exit codes: 0 = success, 1 = failure

set -e

# .NET SDK versions to install
DOTNET_VERSIONS=("10.0" "9.0" "8.0")

echo "Installing .NET SDK and runtime..."

# -----------------------------------------------------------------------------
# Function: check_dotnet_installed
# Description: Check if dotnet command is available
# Returns: 0 if installed, 1 otherwise
# -----------------------------------------------------------------------------
check_dotnet_installed() {
    command -v dotnet &>/dev/null
}

# -----------------------------------------------------------------------------
# Function: install_dotnet_sdks
# Description: Install specified .NET SDK versions
# Arguments: Array of version strings (e.g., "10.0" "9.0" "8.0")
# Returns: 0 on success, 1 on failure
# -----------------------------------------------------------------------------
install_dotnet_sdks() {
    local versions=("$@")
    local packages=()

    for version in "${versions[@]}"; do
        packages+=("dotnet-sdk-${version}")
    done

    printf "Installing .NET SDKs: %s...\n" "${packages[*]}"
    sudo apt-get -qq update > /dev/null 2>&1
    sudo apt-get -qq install -y "${packages[@]}" > /dev/null 2>&1
    printf ".NET SDKs successfully installed.\n"
}

# -----------------------------------------------------------------------------
# Function: install_dotnet_runtimes
# Description: Install ASP.NET Core and .NET runtime libraries
# Arguments: Array of version strings
# Returns: 0 on success, 1 on failure
# -----------------------------------------------------------------------------
install_dotnet_runtimes() {
    local versions=("$@")
    local aspnet_packages=()
    local runtime_packages=()

    for version in "${versions[@]}"; do
        aspnet_packages+=("aspnetcore-runtime-${version}")
        runtime_packages+=("dotnet-runtime-${version}")
    done

    printf "Installing ASP.NET Core runtimes...\n"
    sudo apt-get -qq install -y "${aspnet_packages[@]}" > /dev/null 2>&1
    printf "ASP.NET Core runtimes installed.\n"

    printf "Installing .NET runtimes...\n"
    sudo apt-get -qq install -y "${runtime_packages[@]}" > /dev/null 2>&1
    printf ".NET runtimes installed.\n"
}

# -----------------------------------------------------------------------------
# Function: install_dependencies
# Description: Install required system dependencies for .NET
# Returns: 0 on success
# -----------------------------------------------------------------------------
install_dependencies() {
    printf "Installing zlib1g dependency...\n"
    sudo apt-get -qq install -y zlib1g > /dev/null 2>&1
}

# -----------------------------------------------------------------------------
# Function: verify_installation
# Description: Verify dotnet is installed and working
# Returns: 0 if verification passes, 1 otherwise
# -----------------------------------------------------------------------------
verify_installation() {
    if dotnet --version &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# -----------------------------------------------------------------------------
# Main execution
# -----------------------------------------------------------------------------

# Check if dotnet is already installed
if check_dotnet_installed; then
    printf "dotnet is already installed (version: %s)\n\n" "$(dotnet --version)"
else
    install_dotnet_sdks "${DOTNET_VERSIONS[@]}"
    install_dotnet_runtimes "${DOTNET_VERSIONS[@]}"
    echo
fi

# Install dependencies
install_dependencies
echo

# Verify installation
if ! verify_installation; then
    echo "Error: dotnet installation verification failed."
    exit 1
fi

printf ".NET version: %s\n\n" "$(dotnet --version)"
echo "✓ .NET SDK and runtime installed successfully"
exit 0
