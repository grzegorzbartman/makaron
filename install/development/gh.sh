#!/bin/bash

# Install GitHub CLI
if ! command -v gh &> /dev/null; then
    brew install gh
fi

