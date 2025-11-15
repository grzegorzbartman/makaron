#!/bin/bash

# Install borders
if ! command -v borders &> /dev/null; then
    brew tap FelixKratz/formulae
    brew install borders
fi
