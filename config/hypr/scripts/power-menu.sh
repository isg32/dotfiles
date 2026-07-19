#!/usr/bin/env bash
# gnome-session-quit doesn't work here — there's no gnome-session D-Bus service
# running under Hyprland to talk to (confirmed: "ServiceUnknown" on Shutdown call).
# This talks to systemd/logind directly instead, with a confirm step since these
# are destructive actions.
set -euo pipefail

choice=$(printf "Lock\nLog out\nSuspend\nReboot\nPower off" | wofi --dmenu --prompt "Power menu")

case "$choice" in
    "Lock") exec hyprlock ;;
    "Log out") exec hyprctl dispatch exit ;;
    "Suspend") exec systemctl suspend ;;
    "Reboot")
        [ "$(printf "Cancel\nReboot" | wofi --dmenu --prompt "Reboot now?")" = "Reboot" ] && exec systemctl reboot
        ;;
    "Power off")
        [ "$(printf "Cancel\nPower off" | wofi --dmenu --prompt "Power off now?")" = "Power off" ] && exec systemctl poweroff
        ;;
    *) exit 0 ;;
esac
