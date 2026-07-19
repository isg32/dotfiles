-- Session identity — makes portals, GTK/Qt apps and gnome-control-center panels
-- behave as if they're running under a recognized desktop instead of "unknown".
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")

-- Cursor — matches the Adwaita/24 theme already set in GNOME (gsettings); GTK4/libadwaita
-- apps also read gsettings directly regardless of compositor, so this mainly covers
-- GTK3/Qt/other toolkits that expect the X cursor env vars.
hl.env("XCURSOR_THEME", "Adwaita")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "Adwaita")
hl.env("HYPRCURSOR_SIZE", "24")

-- Toolkit backends
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("MOZ_ENABLE_WAYLAND", "1")

-- Electron/Chromium apps (VSCode, Slack, Discord, Chrome...) — force Wayland + Ozone
hl.env("NIXOS_OZONE_WL", "1")

-- NOTE: GPU-specific vars (LIBVA_DRIVER_NAME, GBM_BACKEND, __GLX_VENDOR_LIBRARY_NAME,
-- AQ_DRM_DEVICES) are intentionally NOT set here. They differ between the "Hyprland"
-- (Intel primary) and "Hyprland (NVIDIA)" GDM sessions and are exported by each
-- session's launcher script before Hyprland starts — see scripts/sessions.sh.

hl.env("XDG_SCREENSHOTS_DIR", os.getenv("HOME") .. "/Pictures/Screenshots")
