#!/bin/bash

# Script: bootstrap.sh
# Purpose: One-line remote installer. Fetches ubuntu-setup into a temp
#          directory and hands off to install.sh. Intended for:
#            curl -fsSL https://raw.githubusercontent.com/omoinjm/ubuntu-setup/main/bootstrap.sh | bash
# Exit codes: 0 = success, 1 = failure
#
# Kept dependency-free (no sourcing other repo files) since it runs before
# the repository exists on disk.

set -e

REPO_URL="https://github.com/omoinjm/ubuntu-setup.git"
CLONE_DIR="$(mktemp -d -t ubuntu-setup.XXXXXXXX)"

cleanup() {
    rm -rf "$CLONE_DIR"
}
trap cleanup EXIT

if ! command -v git &> /dev/null; then
    echo "✗ Error: git is required but not installed." >&2
    echo "  Install it first: sudo apt-get update && sudo apt-get install -y git" >&2
    exit 1
fi

if [ -z "$UBUNTU_SETUP_VERSION" ]; then
    UBUNTU_SETUP_VERSION="$(git ls-remote --tags --sort=-v:refname "$REPO_URL" 2>/dev/null \
        | awk -F/ '{print $NF}' | grep -v '\^{}$' | head -1)"
    UBUNTU_SETUP_VERSION="${UBUNTU_SETUP_VERSION:-main}"
fi

echo "Fetching ubuntu-setup (${UBUNTU_SETUP_VERSION})..."
if ! git clone --depth 1 --branch "$UBUNTU_SETUP_VERSION" "$REPO_URL" "$CLONE_DIR" 2>/dev/null; then
    echo "✗ Error: could not clone ${REPO_URL} at ${UBUNTU_SETUP_VERSION}" >&2
    exit 1
fi

cd "$CLONE_DIR"
exec ./install.sh "$@"
