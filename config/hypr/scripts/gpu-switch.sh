#!/usr/bin/env bash
# Switches which GPU is Hyprland's primary renderer. This is NOT a live
# hot-swap — a compositor picks its primary DRM device once at startup, so
# the only real way to change it is: confirm, best-effort pre-select the
# target session so it's already highlighted at the login screen, then log
# out. You'll need to type your password again at GDM; that step can't be
# skipped without weakening login security.
set -euo pipefail

# LIBVA_DRIVER_NAME is exported by whichever session wrapper (hyprland-intel-session
# / hyprland-nvidia-session, see scripts/sessions.sh) launched this Hyprland instance,
# and inherited by everything Hyprland execs — including this script.
if [ "${LIBVA_DRIVER_NAME:-}" = "nvidia" ]; then
    current="NVIDIA"
    target_session="hyprland"
    target_label="Intel"
else
    current="Intel"
    target_session="hyprland-nvidia"
    target_label="NVIDIA"
fi

choice=$(printf "Switch to %s (log out)\nCancel" "$target_label" | wofi --dmenu --prompt "Currently: $current")
[ "$choice" != "Switch to ${target_label} (log out)" ] && exit 0

# Best-effort: pre-select the target session so it's already highlighted next
# time GDM shows the login screen. Harmless if this D-Bus call isn't permitted
# or the property isn't honored — you just pick it manually instead.
uid="$(id -u)"
busctl --system call org.freedesktop.Accounts "/org/freedesktop/Accounts/User${uid}" \
    org.freedesktop.Accounts.User SetSession s "$target_session" >/dev/null 2>&1 || true
busctl --system call org.freedesktop.Accounts "/org/freedesktop/Accounts/User${uid}" \
    org.freedesktop.Accounts.User SetSessionType s "wayland" >/dev/null 2>&1 || true

notify-send -a "GPU Switch" "Logging out to switch to ${target_label}..." -t 2000
sleep 1
hyprctl dispatch exit
