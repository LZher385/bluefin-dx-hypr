#!/bin/sh
# Pick a file from user content dirs via fuzzel, open with xdg-open.
# fd's defaults skip .gitignored entries and hidden files.

set -eu

# Deep-scan standard XDG content dirs; cap Downloads at depth 2 since extracted
# archives (icon themes, npm tarballs, etc.) explode the file count.
deep_dirs="$HOME/Documents $HOME/Desktop $HOME/Pictures $HOME/Music $HOME/Videos"
shallow_dirs="$HOME/Downloads"

filter_existing() {
    for d in $1; do
        [ -d "$d" ] && printf '%s\n' "$d"
    done
}

deep=$(filter_existing "$deep_dirs")
shallow=$(filter_existing "$shallow_dirs")
[ -n "$deep$shallow" ] || exit 0

EXCLUDES="--exclude node_modules --exclude target --exclude .venv \
--exclude dist --exclude build --exclude __pycache__"

# shellcheck disable=SC2086
choice=$({
        [ -n "$deep" ]    && fd --type f --follow --max-depth 8 $EXCLUDES . $deep    2>/dev/null
        [ -n "$shallow" ] && fd --type f --follow --max-depth 2 $EXCLUDES . $shallow 2>/dev/null
    } \
    | sed "s|^$HOME/|~/|" \
    | fuzzel --dmenu --prompt "  ")

[ -n "$choice" ] || exit 0
path=$(printf '%s' "$choice" | sed "s|^~/|$HOME/|")
setsid xdg-open "$path" >/dev/null 2>&1 &
