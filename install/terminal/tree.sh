#!/bin/bash

# Install tree
if ! command -v tree &> /dev/null; then
    brew install tree
fi

