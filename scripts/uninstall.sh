#!/usr/bin/env bash
# Reverses link-configs.sh: removes the symlinks this repo created and restores
# the most recent backup for each, if one exists. Does NOT remove packages,
# GDM session entries, or GRUB/mkinitcpio/modprobe changes — those are left in
# place since removing them can affect your GNOME session too. See README for
# how to undo those manually if you want to.
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$DIR/.." && pwd)"
source "$DIR/lib.sh"

TARGETS=(hypr waybar swaync wofi xdg-desktop-portal)

for name in "${TARGETS[@]}"; do
    dst="$HOME/.config/$name"
    if [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$(readlink -f "$REPO_ROOT/config/$name")" ]; then
        rm "$dst"
        log "Removed symlink ~/.config/$name"
        latest_backup=$(ls -dt "${dst}.bak-"* 2>/dev/null | head -n1 || true)
        if [ -n "$latest_backup" ]; then
            mv "$latest_backup" "$dst"
            ok "Restored previous ~/.config/$name from $(basename "$latest_backup")"
        fi
    else
        log "$name is not one of our symlinks — leaving it alone"
    fi
done

cat <<'EOF'

Not touched (remove manually if you want them fully gone):
  - Packages installed via pacman (see README "Uninstall" section for the list)
  - /usr/share/wayland-sessions/hyprland*.desktop
  - /usr/local/bin/hyprland-*-session
  - /etc/modprobe.d/nvidia-pm.conf
  - nvidia_drm.modeset=1 in /etc/default/grub (rerun grub-mkconfig after editing)
  - nvidia modules added to /etc/mkinitcpio.conf MODULES=(...) (rerun mkinitcpio -P after editing)
EOF
