#!/bin/bash

# AI tools
install_cask "chatgpt" "ChatGPT"
install_cask "claude" "Claude"
install_formula "gemini-cli" "Gemini CLI" "gemini"
install_cask "codex" "Codex"
install_cask "cursor" "Cursor"

# Claude Code - check binary first (npm install creates 'claude' command)
if command -v claude &>/dev/null; then
    echo "Claude Code already installed"
else
    install_cask "claude-code" "Claude Code"
fi

install_formula "anomalyco/tap/opencode" "OpenCode" "opencode"
