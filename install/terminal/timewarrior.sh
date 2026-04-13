#!/bin/bash

_ensure_timewarrior_layout() {
    local config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/timewarrior"
    local data_dir="${XDG_DATA_HOME:-$HOME/.local/share}/timewarrior"

    mkdir -p "$config_dir/extensions" "$data_dir/data"
    touch "$config_dir/timewarrior.cfg"
}

install_formula "timewarrior" "Timewarrior" "timew"
_ensure_timewarrior_layout
