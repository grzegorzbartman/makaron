#!/bin/bash

# AI tools
install_cask "chatgpt" "ChatGPT"
install_cask "claude" "Claude"
install_formula "gemini-cli" "Gemini CLI" "gemini"
install_cask "codex" "Codex"
install_cask "cursor" "Cursor"

# Claude Code (has additional binary check)
source "$MAKARON_PATH/install/ai/claude-code.sh"
