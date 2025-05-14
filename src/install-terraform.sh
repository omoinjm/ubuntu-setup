#!/bin/bash

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
    printf "terraform not found. Installing...\n"
    wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt-get -qq update > /dev/null 2>&1 && sudo apt-get -qq install -y terraform > /dev/null 2>&1

    printf "terraform successfully installed.\n\n"
else
    printf "terraform is already installed.\n\n"
fi
