#!/bin/bash

# Check if nodejs is installed
if ! command -v dotnet &>/dev/null; then
  printf "dotnet not found. Installing...\n"
  sudo apt-get -qq install -y dotnet-sdk-10.0 dotnet-sdk-9.0 dotnet-sdk-8.0 >/dev/null 2>&1
  printf "dotnet successfully installed.\n\n"

  printf "Installing runtime"
  sudo apt-get -qq install -y aspnetcore-runtime-10.0 aspnetcore-runtime-9.0 aspnetcore-runtime-8.0 >/dev/null 2>&1
  sudo apt-get -qq install -y dotnet-runtime-10.0 dotnet-runtime-9.0 dotnet-runtime-8.0 >/dev/null 2>&1
  printf "Runtime installed"
else
  printf "dotnet is already installed.\n\n"
fi

# Install dependencies
sudo apt install -y zlib1g
