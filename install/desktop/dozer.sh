#!/bin/bash

# Install Dozer
if ! brew list --cask dozer &> /dev/null; then
    echo "Installing Dozer..."
    brew install --cask dozer
fi


