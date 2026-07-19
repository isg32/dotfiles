hl.config({
    input = {
        kb_layout = "us",
        follow_mouse = 1,
        sensitivity = 0,
        accel_profile = "adaptive",

        touchpad = {
            natural_scroll = true,
            tap_to_click = true,
            disable_while_typing = true,
            scroll_factor = 0.6,
        },
    },
})

-- Match GNOME's default "tap to click" + natural scroll already set for this user;
-- adjust here if you ever change it in gnome-tweaks/Settings and want Hyprland to match.
