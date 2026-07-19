#!/usr/bin/env bash
# Shared helpers sourced by the other wallpaper-*.sh scripts.
WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/Pictures/wallpapers}"
STATE_FILE="$HOME/.config/hypr/current_wallpaper"
THUMB_DIR="$HOME/.cache/wallpaper-thumbs"

mkdir -p "$THUMB_DIR"

list_wallpapers() {
    find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | sort
}

set_wallpaper() {
    local target="$1"
    [ -f "$target" ] || { echo "wallpaper not found: $target" >&2; return 1; }

    local prev=""
    [ -f "$STATE_FILE" ] && prev="$(cat "$STATE_FILE")"

    hyprctl hyprpaper preload "$target" >/dev/null
    for mon in $(hyprctl monitors -j | jq -r '.[].name'); do
        hyprctl hyprpaper wallpaper "${mon},${target}" >/dev/null
    done

    echo "$target" > "$STATE_FILE"

    # Free the previous image from hyprpaper's memory once it's no longer in use.
    if [ -n "$prev" ] && [ "$prev" != "$target" ]; then
        hyprctl hyprpaper unload "$prev" >/dev/null 2>&1
    fi

    notify-send -a "Wallpaper" -i "$target" "Wallpaper changed" "$(basename "$target")" -t 2500 2>/dev/null
}
