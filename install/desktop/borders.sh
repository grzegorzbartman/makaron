#!/bin/bash

MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"
source "$MAKARON_PATH/install/helpers.sh"

BORDERS_FORMULA="felixkratz/formulae/borders"
brew_trust --formula "$BORDERS_FORMULA"
install_formula_critical "$BORDERS_FORMULA" "Borders" "borders"
