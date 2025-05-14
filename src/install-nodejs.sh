#!/bin/bash

# Check if nodejs is installed
if ! command -v node &> /dev/null; then
    printf "nodejs not found. Installing...\n"
    sudo apt-get -qq update > /dev/null 2>&1 && sudo apt-get -qq install -y nodejs > /dev/null 2>&1
    printf "nodejs successfully installed.\n\n"
else
    printf "nodejs is already installed.\n\n"
fi

# Check if nvm is installed
if ! command -v nvm &> /dev/null; then
  printf "nvm not found. Installing...\n"

  # Install for fish shell
  fisher add edc/bass

  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

  printf "nvm successfully installed.\n\n"
else
  printf "nvm is already installed.\n\n"
fi


