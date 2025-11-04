#!/bin/bash

# Install Platform.sh CLI
if ! command -v platform &> /dev/null; then
    brew install platformsh-cli
fi


