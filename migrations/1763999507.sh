#!/bin/bash

# Migration: Install Claude Code
# Date: 2025-11-24

echo "Running migration: Install Claude Code..."

# Source the installation script if it exists
# Source the installation script if it exists
if [ -f "$MAKARON_PATH/install/ai/claude.sh" ]; then
    source "$MAKARON_PATH/install/ai/claude.sh"
else
    echo "⚠️  install/ai/claude.sh not found, skipping installation"
fi

if [ -f "$MAKARON_PATH/install/ai/claude-code.sh" ]; then
    source "$MAKARON_PATH/install/ai/claude-code.sh"
else
    echo "⚠️  install/ai/claude-code.sh not found, skipping installation"
fi

if [ -f "$MAKARON_PATH/install/ai/gemini-cli.sh" ]; then
    source "$MAKARON_PATH/install/ai/gemini-cli.sh"
else
    echo "⚠️  install/ai/gemini-cli.sh not found, skipping installation"
fi
