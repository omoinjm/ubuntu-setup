#!/bin/bash

# Check if nebius is installed
if ! command -v nebius &> /dev/null; then
    printf "nebius not found. Installing...\n"
    curl -sSL https://storage.eu-north1.nebius.cloud/cli/install.sh | bash
    
    printf "nebius successfully installed.\n\n"
else
    printf "nebius is already installed.\n\n"
fi
