#!/bin/bash

# Install ffmpeg
if ! command -v ffmpeg &> /dev/null; then
    brew install ffmpeg
fi

