#!/bin/bash

# Install Composer
if ! command -v composer &> /dev/null; then
    brew install composer
fi
