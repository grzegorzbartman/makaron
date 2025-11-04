#!/bin/bash

# Install pipx
if ! command -v pipx &> /dev/null; then
    brew install pipx
    pipx ensurepath
fi


