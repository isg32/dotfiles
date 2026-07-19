-- GNOME dialogs/pickers as floating, centered
hl.window_rule({ match = { class = "^(org.gnome.Calculator)$" }, float = true })
hl.window_rule({ match = { class = "^(org.gnome.Nautilus)$", title = "^(Properties|Preferences)$" }, float = true })
hl.window_rule({ match = { title = "^(Open File|Save File|File Upload|Open Folder)$" }, float = true })
hl.window_rule({ match = { class = "^(nm-connection-editor)$" }, float = true })
hl.window_rule({ match = { class = "^(blueman-manager)$" }, float = true })
hl.window_rule({ match = { class = "^(pavucontrol)$" }, float = true })
hl.window_rule({ match = { class = "^(org.gnome.Settings)$" }, float = true, center = true })

-- Polkit auth dialog
hl.window_rule({ match = { class = "^(hyprpolkitagent)$" }, float = true, center = true, pin = true })

-- wofi layer surfaces get no border/shadow duplication
hl.window_rule({ match = { class = "^(wofi)$" }, no_blur = true })

-- Picture-in-Picture (browsers) always floating + on top, bottom-right corner
hl.window_rule({
    match = { title = "^(Picture-in-Picture)$" },
    float = true,
    pin = true,
    size = { 480, 270 },
    move = { "monitor_w - 500", "monitor_h - 320" },
})
