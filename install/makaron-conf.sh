#!/bin/bash

MAKARON_PATH="${MAKARON_PATH:-$HOME/.local/share/makaron}"
MAKARON_CONF_DIR="${MAKARON_CONF_DIR:-$HOME/.config/makaron}"
MAKARON_CONF="${MAKARON_CONF:-$MAKARON_CONF_DIR/makaron.conf}"
MAKARON_TEMPLATE="$MAKARON_PATH/templates/makaron.conf.default"

mkdir -p "$MAKARON_CONF_DIR"

if [ ! -f "$MAKARON_CONF" ]; then
    cp "$MAKARON_TEMPLATE" "$MAKARON_CONF"
else
    # Regenerate from the template: template drives structure and comments,
    # existing user values win, unknown user variables are kept at the end.
    _conf_tmp=$(mktemp "$MAKARON_CONF_DIR/.makaron.conf.XXXXXX") &&
    awk '
        NR == FNR {
            if ($0 ~ /^[A-Za-z_][A-Za-z0-9_]*=/) {
                key = substr($0, 1, index($0, "=") - 1)
                if (!(key in user)) order[++n] = key
                user[key] = $0
            }
            next
        }
        /^[A-Za-z_][A-Za-z0-9_]*=/ {
            key = substr($0, 1, index($0, "=") - 1)
            managed[key] = 1
            if (key in user) print user[key]; else print
            next
        }
        { print }
        END {
            for (i = 1; i <= n; i++) {
                key = order[i]
                if (key in managed) continue
                if (!header++) printf "\n# User-defined settings (not managed by Makaron)\n"
                print user[key]
            }
        }
    ' "$MAKARON_CONF" "$MAKARON_TEMPLATE" > "$_conf_tmp" &&
    mv "$_conf_tmp" "$MAKARON_CONF"
    rm -f "$_conf_tmp" 2>/dev/null
    unset _conf_tmp
fi
