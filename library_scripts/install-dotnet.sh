#!/bin/bash

# Script: install-dotnet.sh
# Purpose: Install .NET SDK and runtime
# Exit codes: 0 = success, 1 = failure

set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=library_scripts/helpers.sh
source "$ROOT_DIR/library_scripts/helpers.sh"

DOTNET_VERSIONS=("10.0" "9.0" "8.0")

echo "Installing .NET SDK and runtime..."

check_dotnet_installed() {
    command -v dotnet &>/dev/null
}

install_dotnet_sdks() {
    local versions=("$@")
    local packages=()

    for version in "${versions[@]}"; do
        packages+=("dotnet-sdk-${version}")
    done

    printf "Installing .NET SDKs: %s...\n" "${packages[*]}"
    run_apt "Updating package lists for .NET" -qq update
    run_apt "Installing .NET SDKs" -qq install -y "${packages[@]}"
    printf ".NET SDKs successfully installed.\n"
}

install_dotnet_runtimes() {
    local versions=("$@")
    local aspnet_packages=()
    local runtime_packages=()

    for version in "${versions[@]}"; do
        aspnet_packages+=("aspnetcore-runtime-${version}")
        runtime_packages+=("dotnet-runtime-${version}")
    done

    printf "Installing ASP.NET Core runtimes...\n"
    run_apt "Installing ASP.NET Core runtimes" -qq install -y "${aspnet_packages[@]}"
    printf "ASP.NET Core runtimes installed.\n"

    printf "Installing .NET runtimes...\n"
    run_apt "Installing .NET runtimes" -qq install -y "${runtime_packages[@]}"
    printf ".NET runtimes installed.\n"
}

install_dependencies() {
    printf "Installing zlib1g dependency...\n"
    run_apt "Installing zlib1g" -qq install -y zlib1g
}

verify_installation() {
    dotnet --version &>/dev/null
}

if check_dotnet_installed; then
    printf "dotnet is already installed (version: %s)\n\n" "$(dotnet --version)"
else
    install_dotnet_sdks "${DOTNET_VERSIONS[@]}"
    install_dotnet_runtimes "${DOTNET_VERSIONS[@]}"
    echo
fi

install_dependencies
echo

if ! verify_installation; then
    echo "Error: dotnet installation verification failed."
    exit 1
fi

printf ".NET version: %s\n\n" "$(dotnet --version)"
echo "✓ .NET SDK and runtime installed successfully"
exit 0
