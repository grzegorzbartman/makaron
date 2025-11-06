#!/bin/bash

# Install htop
if ! command -v htop &> /dev/null; then
    brew install htop
fi

