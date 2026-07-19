hl.on("hyprland.start", function()
    -- Reused GNOME services (keeps theming/keyring/secrets consistent with the GNOME session)
    hl.exec_cmd("/usr/lib/gsd-xsettings") -- propagates Adwaita GTK theme/fonts/cursor to apps
    hl.exec_cmd("/usr/bin/gnome-keyring-daemon --start --components=secrets,ssh")
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE")

    -- Polkit auth agent (gnome-shell normally provides this; Hyprland needs its own)
    hl.exec_cmd("hyprpolkitagent")

    -- Portals (screen share/screenshot via hyprland portal, file picker via GTK portal)
    hl.exec_cmd("/usr/lib/xdg-desktop-portal-hyprland")
    hl.exec_cmd("/usr/lib/xdg-desktop-portal-gtk")
    hl.exec_cmd("/usr/lib/xdg-desktop-portal")

    -- Core UI: bar, notification/quick-toggle center, wallpaper, idle/lock daemon
    hl.exec_cmd("waybar")
    hl.exec_cmd("swaync")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("sh -c 'sleep 1 && ~/.config/hypr/scripts/wallpaper-restore.sh'")
    hl.exec_cmd("hypridle")

    -- Clipboard history (used by SUPER+V in keybinds.lua)
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- Cursor consistency for layer-shell surfaces before any client sets its own
    hl.exec_cmd("hyprctl setcursor Adwaita 24")
end)
