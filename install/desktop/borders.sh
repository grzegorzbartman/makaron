#!/bin/bash

source "$MAKARON_PATH/install/helpers.sh"

# Install borders (CRITICAL component)
brew tap FelixKratz/formulae 2>/dev/null || true
install_formula_critical "borders" "Borders"
