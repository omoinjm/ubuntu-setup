#!/bin/bash

# Script: install-dotnet.sh
# Purpose: Install .NET SDK and runtime
# Exit codes: 0 = success, 1 = failure

set -e

echo "Installing .NET SDK and runtime..."

# Check if dotnet is installed
if ! command -v dotnet &>/dev/null; then
  printf "dotnet not found. Installing...\n"
  
  # Update before installing
  sudo apt-get -qq update > /dev/null 2>&1
  
  # Install .NET SDK
  sudo apt-get -qq install -y dotnet-sdk-10.0 dotnet-sdk-9.0 dotnet-sdk-8.0 > /dev/null 2>&1
  printf "dotnet SDKs successfully installed.\n"
  
  # Install runtime
  printf "Installing ASP.NET Core runtime...\n"
  sudo apt-get -qq install -y aspnetcore-runtime-10.0 aspnetcore-runtime-9.0 aspnetcore-runtime-8.0 > /dev/null 2>&1
  sudo apt-get -qq install -y dotnet-runtime-10.0 dotnet-runtime-9.0 dotnet-runtime-8.0 > /dev/null 2>&1
  printf "Runtime successfully installed.\n\n"
else
  printf "dotnet is already installed.\n\n"
fi

# Install dependencies
printf "Installing zlib1g dependency...\n"
sudo apt-get -qq install -y zlib1g > /dev/null 2>&1

# Verify installation
if ! dotnet --version &>/dev/null; then
  echo "Error: dotnet installation verification failed."
  exit 1
fi

printf ".NET version: $(dotnet --version)\n\n"
echo "✓ .NET SDK and runtime installed successfully"
exit 0
