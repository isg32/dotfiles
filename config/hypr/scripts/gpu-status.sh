#!/usr/bin/env bash
# Emits waybar custom-module JSON reflecting which GPU this Hyprland session
# is primary on. Set once at session start (see scripts/sessions.sh wrapper
# scripts) — doesn't change without a full logout/session switch, so waybar
# only needs to run this once ("interval": "once" in config.jsonc).
set -euo pipefail

if [ "${LIBVA_DRIVER_NAME:-}" = "nvidia" ]; then
    printf '{"text":"󰢮 NVIDIA","tooltip":"Primary GPU: NVIDIA\\nClick to switch to Intel (logs out)","class":"nvidia"}\n'
else
    printf '{"text":"󰢮 Intel","tooltip":"Primary GPU: Intel\\nClick to switch to NVIDIA (logs out)","class":"intel"}\n'
fi
