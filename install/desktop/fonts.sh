#!/bin/bash

# Install Nerd Fonts
# Note: font-source-code-pro-nerd-font was renamed to font-sauce-code-pro-nerd-font
brew install --cask font-fira-code-nerd-font font-hack-nerd-font font-jetbrains-mono-nerd-font font-meslo-lg-nerd-font font-sauce-code-pro-nerd-font || true

# Apple SF Pro - system typeface used for SketchyBar labels (liquid glass look)
brew install --cask font-sf-pro || true
