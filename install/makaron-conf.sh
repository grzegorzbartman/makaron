#!/bin/bash

MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"
MAKARON_CONF_DIR="$HOME/.config/makaron"
MAKARON_CONF="$MAKARON_CONF_DIR/makaron.conf"
MAKARON_TEMPLATE="$MAKARON_PATH/templates/makaron.conf.default"

mkdir -p "$MAKARON_CONF_DIR"

if [ ! -f "$MAKARON_CONF" ]; then
    cp "$MAKARON_TEMPLATE" "$MAKARON_CONF"
else
    # Add missing variables from template
    while IFS= read -r line; do
        [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
        var_name="${line%%=*}"
        if ! grep -q "^${var_name}=" "$MAKARON_CONF" 2>/dev/null; then
            echo "" >> "$MAKARON_CONF"
            echo "# Added by makaron update" >> "$MAKARON_CONF"
            echo "$line" >> "$MAKARON_CONF"
        fi
    done < "$MAKARON_TEMPLATE"
fi
