#!/usr/bin/env bash
# Symlinks this repo's config/ subdirectories into ~/.config so Hyprland/waybar/
# swaync/wofi/xdg-desktop-portal pick them up. Anything already at the target
# that isn't already one of our symlinks gets backed up with a timestamp suffix
# instead of overwritten, so re-running this is always safe.
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$DIR/.." && pwd)"
source "$DIR/lib.sh"

TARGETS=(hypr waybar swaync wofi xdg-desktop-portal)
STAMP="$(date +%Y%m%d%H%M%S 2>/dev/null || echo backup)"

mkdir -p "$HOME/.config"

for name in "${TARGETS[@]}"; do
    src="$REPO_ROOT/config/$name"
    dst="$HOME/.config/$name"

    if [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$(readlink -f "$src")" ]; then
        log "$name already linked — skipping"
        continue
    fi

    if [ -e "$dst" ] || [ -L "$dst" ]; then
        backup="${dst}.bak-${STAMP}"
        warn "Existing ~/.config/$name found — moving it to $backup"
        mv "$dst" "$backup"
    fi

    ln -s "$src" "$dst"
    ok "Linked ~/.config/$name -> $src"
done

mkdir -p "$HOME/Pictures/wallpapers" "$HOME/Pictures/Screenshots"
chmod +x "$REPO_ROOT"/config/hypr/scripts/*.sh

ok "Config symlinks done. Wallpaper source dir: ${WALLPAPER_DIR:-$HOME/Pictures/wallpapers}"
