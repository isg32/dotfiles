#!/usr/bin/env bash
# Installs every package this repo's configs assume — official repos only, no AUR.
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/lib.sh"

CORE_PACKAGES=(
    hyprland hypridle hyprlock hyprpaper
    waybar wofi swaync kitty
    hyprshot grim slurp satty
    hyprpolkitagent xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
    switcheroo-control brightnessctl playerctl
    wl-clipboard cliphist wtype jq imagemagick wev
    qt5ct qt6ct
    ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji
)

NVIDIA_PACKAGES=(
    linux-headers nvidia-open-dkms nvidia-utils nvidia-settings nvidia-prime libva-nvidia-driver
)

log "Installing core Hyprland ecosystem packages"
sudo pacman -S --needed "${CORE_PACKAGES[@]}"

if [ "${SKIP_NVIDIA:-0}" != "1" ]; then
    source "$DIR/lib.sh"
    detect_gpus
    if [ "$HAS_HYBRID_NVIDIA" = "1" ]; then
        log "Hybrid Intel+NVIDIA GPU detected (Intel: $INTEL_PCI, NVIDIA: $NVIDIA_PCI)"
        log "Installing nvidia-open-dkms + PRIME offload packages"
        sudo pacman -S --needed "${NVIDIA_PACKAGES[@]}"
    else
        log "No hybrid Intel+NVIDIA GPU detected — skipping NVIDIA packages"
    fi
else
    log "SKIP_NVIDIA=1 — skipping NVIDIA packages"
fi

ok "Package installation done"
