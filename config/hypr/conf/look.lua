hl.config({
    general = {
        gaps_in = 4,
        gaps_out = 8,
        border_size = 1,
        col = {
            active_border = { colors = { "rgba(3584e4ee)", "rgba(78aeedee)" }, angle = 45 }, -- GNOME/Adwaita blue
            inactive_border = "rgba(3c3c3c88)",
        },
        layout = "dwindle",
        resize_on_border = true,
        allow_tearing = false,
    },

    decoration = {
        rounding = 12,
        active_opacity = 1.0,
        inactive_opacity = 0.96,

        shadow = {
            enabled = true,
            range = 12,
            render_power = 3,
            color = "rgba(1a1a1aee)",
        },

        blur = {
            enabled = true,
            size = 6,
            passes = 2,
            vibrancy = 0.17,
        },
    },

    animations = {
        enabled = true,
    },
})

hl.curve("easeOutExpo", { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 3, bezier = "easeOutExpo", style = "popin 85%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "easeOutExpo", style = "popin 85%" })
hl.animation({ leaf = "border", enabled = true, speed = 6, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "easeOutExpo" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "easeOutExpo", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, bezier = "easeOutExpo", style = "slidevert" })

hl.config({
    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        font_family = "Adwaita Sans",
        background_color = "rgb(1e1e1e)",
    },

    -- Forces software cursor rendering. Fixes a known ghost/duplicate-cursor bug on
    -- hybrid Intel+NVIDIA laptops, where aquamarine's hardware cursor plane detection
    -- gets confused by the presence of the (unused) NVIDIA DRM node even when it isn't
    -- the primary GPU for this session.
    cursor = {
        no_hardware_cursors = true,
    },
})

-- Trackpad 3-finger workspace swipe. Replaces the removed gestures.workspace_swipe /
-- workspace_swipe_fingers hyprlang options, which have no equivalent config field
-- anymore — this is the only way to get the behavior back as of Hyprland 0.55.
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
