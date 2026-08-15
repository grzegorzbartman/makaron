#!/bin/bash

MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"
source "$MAKARON_PATH/install/helpers.sh"

install_formula_critical "felixkratz/formulae/borders" "Borders" "borders"
