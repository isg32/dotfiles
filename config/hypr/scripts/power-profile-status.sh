#!/usr/bin/env bash
# Emits waybar custom-module JSON reflecting the current power-profiles-daemon profile.
set -euo pipefail

current="$(powerprofilesctl get)"
case "$current" in
    power-saver) icon="󰌪"; label="Quiet" ;;
    balanced)    icon="󰊚"; label="Balanced" ;;
    performance) icon="󰓅"; label="Performance" ;;
    *)           icon="?"; label="$current" ;;
esac

printf '{"text":"%s %s","tooltip":"Power profile: %s\\nClick to cycle quiet → balanced → performance","class":"%s"}\n' \
    "$icon" "$label" "$label" "$current"
