#!/bin/bash

# Install fzf
if ! command -v fzf &> /dev/null; then
    brew install fzf
fi

