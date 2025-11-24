#!/bin/bash

# Install jq
if ! command -v jq &> /dev/null; then
    brew install jq
fi

