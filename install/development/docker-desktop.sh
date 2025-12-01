#!/bin/bash

# Install Docker Desktop for macOS ARM
DOCKER_APP="/Applications/Docker.app"

# Check if Docker Desktop is already installed
if [ -d "$DOCKER_APP" ]; then
    echo "Docker Desktop is already installed"
    return 0 2>/dev/null || exit 0
fi

# Use helper if available, otherwise install via brew cask
if type install_cask &>/dev/null; then
    install_cask "docker-desktop" "Docker"
else
    echo "Installing Docker Desktop..."
    brew install --cask docker-desktop || {
        echo "Warning: Failed to install Docker Desktop (continuing...)"
        return 1 2>/dev/null || exit 1
    }
fi

echo "Docker Desktop installed"
echo "Note: You may need to open Docker Desktop manually to complete the setup"
