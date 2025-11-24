#!/bin/bash

# Migration: Install AI Tools (Retry)
# Date: 2025-11-24

if [ -z "$MAKARON_PATH" ]; then
    export MAKARON_PATH="$HOME/.local/share/makaron"
fi

echo "Running migration: Install AI Tools..."

# Install Claude
if [ -f "$MAKARON_PATH/install/ai/claude.sh" ]; then
    source "$MAKARON_PATH/install/ai/claude.sh"
else
    echo "⚠️  install/ai/claude.sh not found, skipping installation"
fi

# Install Claude Code
if [ -f "$MAKARON_PATH/install/ai/claude-code.sh" ]; then
    source "$MAKARON_PATH/install/ai/claude-code.sh"
else
    echo "⚠️  install/ai/claude-code.sh not found, skipping installation"
fi

# Install Gemini CLI
if [ -f "$MAKARON_PATH/install/ai/gemini-cli.sh" ]; then
    source "$MAKARON_PATH/install/ai/gemini-cli.sh"
else
    echo "⚠️  install/ai/gemini-cli.sh not found, skipping installation"
fi
