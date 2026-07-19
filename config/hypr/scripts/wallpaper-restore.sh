#!/usr/bin/env bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/wallpaper-common.sh"

if [ -f "$STATE_FILE" ] && [ -f "$(cat "$STATE_FILE")" ]; then
    set_wallpaper "$(cat "$STATE_FILE")"
else
    first="$(list_wallpapers | head -n1)"
    [ -n "$first" ] && set_wallpaper "$first"
fi
