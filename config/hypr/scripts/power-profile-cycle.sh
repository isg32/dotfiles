#!/usr/bin/env bash
# Cycles power-profiles-daemon between quiet -> balanced -> performance -> quiet.
set -euo pipefail

current="$(powerprofilesctl get)"
case "$current" in
    power-saver) next=balanced ;;
    balanced)    next=performance ;;
    performance) next=power-saver ;;
    *)           next=balanced ;;
esac

powerprofilesctl set "$next"

case "$next" in
    power-saver) label="Quiet" ;;
    balanced)    label="Balanced" ;;
    performance) label="Performance" ;;
esac

notify-send -a "Power Profile" -i preferences-system-power-symbolic "Power profile: ${label}" -t 2000
