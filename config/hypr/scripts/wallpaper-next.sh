#!/usr/bin/env bash
# Cycles to the next wallpaper in ~/Pictures/wallpapers (sorted, wraps around).
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/wallpaper-common.sh"

mapfile -t wallpapers < <(list_wallpapers)
count=${#wallpapers[@]}
[ "$count" -eq 0 ] && { notify-send "Wallpaper" "No images found in $WALLPAPER_DIR"; exit 1; }

current=""
[ -f "$STATE_FILE" ] && current="$(cat "$STATE_FILE")"

next_index=0
for i in "${!wallpapers[@]}"; do
    if [ "${wallpapers[$i]}" = "$current" ]; then
        next_index=$(( (i + 1) % count ))
        break
    fi
done

set_wallpaper "${wallpapers[$next_index]}"
