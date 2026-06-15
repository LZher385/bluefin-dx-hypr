#!/bin/sh
# Pick an open window via fuzzel, focus it.

set -eu

clients=$(hyprctl clients -j)

choice=$(printf '%s' "$clients" \
    | jq -r '.[] | select(.title != "") | "\(.title) — \(.class)"' \
    | fuzzel --dmenu --prompt "󰖯  ")

[ -n "$choice" ] || exit 0

addr=$(printf '%s' "$clients" \
    | jq -r --arg t "$choice" \
        '.[] | select((.title + " — " + .class) == $t) | .address' \
    | head -n1)

[ -n "$addr" ] || exit 0
hyprctl dispatch "hl.dsp.focus({window = \"address:$addr\"})"
