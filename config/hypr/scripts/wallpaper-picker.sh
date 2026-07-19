#!/usr/bin/env bash
# Little wofi-based grid UI to browse ~/Pictures/wallpapers and pick one.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/wallpaper-common.sh"

mapfile -t wallpapers < <(list_wallpapers)
if [ "${#wallpapers[@]}" -eq 0 ]; then
    notify-send "Wallpaper" "No images found in $WALLPAPER_DIR"
    exit 1
fi

declare -A path_by_name
entries=""
for path in "${wallpapers[@]}"; do
    name="$(basename "$path")"
    path_by_name["$name"]="$path"

    thumb="$THUMB_DIR/${name%.*}.png"
    if [ ! -f "$thumb" ]; then
        magick "$path" -thumbnail 480x480 -gravity center -extent 480x480 "$thumb" 2>/dev/null
    fi

    entries+="img:${thumb}:text:${name}\n"
done

selected_name=$(printf "%b" "$entries" | wofi --conf "$HOME/.config/wofi/wallpaper.conf" \
    --style "$HOME/.config/wofi/wallpaper-style.css" --dmenu)

[ -z "$selected_name" ] && exit 0

selected_path="${path_by_name[$selected_name]}"
[ -n "$selected_path" ] && set_wallpaper "$selected_path"
