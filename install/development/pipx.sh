#!/bin/bash

install_formula "pipx" "pipx" "pipx"

# Ensure pipx path is configured
if command -v pipx &>/dev/null; then
    pipx ensurepath 2>/dev/null || true
fi
