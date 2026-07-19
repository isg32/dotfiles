#!/usr/bin/env bash
# Little wofi-based grid UI to browse ~/Pictures/wallpapers and pick one.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/wallpaper-common.sh"

mapfile -t wallpapers < <(list_wallpapers)
if [ "${#wallpapers[@]}" -eq 0 ]; then
    notify-send "Wallpaper" "No images found in $WALLPAPER_DIR"
    exit 1
fi

declare -A path_by_index
entries=""
i=0
for path in "${wallpapers[@]}"; do
    name="$(basename "$path")"
    path_by_index["$i"]="$path"

    thumb="$THUMB_DIR/${name%.*}.png"
    if [ ! -f "$thumb" ]; then
        # `^` makes -thumbnail fill the box (cropping overflow) instead of the
        # default letterbox-with-padding behavior, which was baking visible
        # white bars into every non-square wallpaper's thumbnail.
        magick "$path" -thumbnail '480x480^' -gravity center -extent 480x480 "$thumb" 2>/dev/null
    fi

    # The label just needs to be short and unique — a long filename left a
    # residual width gap next to the image even at font-size:1px/opacity:0
    # (GTK Label sizing doesn't fully collapse based on CSS alone).
    entries+="img:${thumb}:text:${i}\n"
    i=$((i + 1))
done

selected_index=$(printf "%b" "$entries" | wofi --conf "$HOME/.config/wofi/wallpaper.conf" \
    --style "$HOME/.config/wofi/wallpaper-style.css" --dmenu)

[ -z "$selected_index" ] && exit 0

selected_path="${path_by_index[$selected_index]}"
[ -n "$selected_path" ] && set_wallpaper "$selected_path"
