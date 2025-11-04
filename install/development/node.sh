#!/bin/bash

# Install Node.js
if ! command -v node &> /dev/null; then
    brew install node
fi

# Install Yarn
if ! command -v yarn &> /dev/null; then
    brew install yarn
fi


