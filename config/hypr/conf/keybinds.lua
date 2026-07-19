local mod = "SUPER"
local terminal = "kitty"
local fileManager = "nautilus"
local browser = "firefox"
local menu = "wofi --show drun"

-- --- Core apps (reusing GNOME apps where they exist) ---
hl.bind(mod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mod .. " + D", hl.dsp.exec_cmd(menu))
hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + SHIFT + Q", hl.dsp.window.kill())
hl.bind(mod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mod .. " + SHIFT + Space", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + P", hl.dsp.window.pseudo())
hl.bind(mod .. " + SHIFT + J", hl.dsp.layout("togglesplit"))
hl.bind(mod .. " + SHIFT + E", hl.dsp.exit())

-- --- Lock / quick settings / notifications ---
hl.bind(mod .. " + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mod .. " + N", hl.dsp.exec_cmd("swaync-client -t -sw")) -- toggle notification/quick-toggle center
hl.bind(mod .. " + I", hl.dsp.exec_cmd("env XDG_CURRENT_DESKTOP=GNOME gnome-control-center")) -- full GNOME Settings app
hl.bind(mod .. " + V", hl.dsp.exec_cmd("cliphist list | wofi --dmenu | cliphist decode | wl-copy"))

-- --- Wallpaper control ---
hl.bind(mod .. " + W", hl.dsp.exec_cmd("~/.config/hypr/scripts/wallpaper-picker.sh"))
hl.bind(mod .. " + SHIFT + W", hl.dsp.exec_cmd("~/.config/hypr/scripts/wallpaper-next.sh"))

-- --- Screenshots (hyprshot; saved to ~/Pictures/Screenshots, annotate with satty) ---
hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m output --clipboard-only"))
hl.bind(mod .. " + Print", hl.dsp.exec_cmd(
    "hyprshot -m region --raw | satty --filename - --output-filename ~/Pictures/Screenshots/satty-$(date +%Y-%m-%d-%H%M%S).png"
))
hl.bind(mod .. " + SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m window -o ~/Pictures/Screenshots"))

-- --- Focus movement (arrows; SUPER+L is reserved for lock, so no vim-style hjkl) ---
hl.bind(mod .. " + left", hl.dsp.focus({ direction = "l" }))
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(mod .. " + up", hl.dsp.focus({ direction = "u" }))
hl.bind(mod .. " + down", hl.dsp.focus({ direction = "d" }))

-- --- Move window ---
hl.bind(mod .. " + SHIFT + left", hl.dsp.window.move({ direction = "l" }))
hl.bind(mod .. " + SHIFT + right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mod .. " + SHIFT + up", hl.dsp.window.move({ direction = "u" }))
hl.bind(mod .. " + SHIFT + down", hl.dsp.window.move({ direction = "d" }))

-- --- Workspaces 1-10 ---
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- --- Mouse move/resize ---
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- --- Media / volume / brightness keys ---
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- --- Laptop lid: lock immediately, suspend if lid stays closed (hypridle backs this up too) ---
hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd("hyprlock"), { locked = true })
hl.bind("switch:off:Lid Switch", hl.dsp.dpms({ action = "on" }), { locked = true })

-- --- Power profile cycle (quiet/balanced/performance) and GPU switch ---
-- These map to real hardware Fn-row keys on Lenovo Legion/IdeaPad laptops, but the
-- exact key name Wayland reports for them isn't guessable — it depends on how the
-- ideapad-laptop/lenovo-wmi kernel driver exposes it on this specific model. Verify
-- with `wev` (run `wev`, press the key, read the "sym" it prints) then fix these two
-- lines. Both actions always work via the waybar icons regardless of whether the
-- hotkey binding below is correct.
hl.bind("XF86Launch1", hl.dsp.exec_cmd("~/.config/hypr/scripts/power-profile-cycle.sh")) -- guessed Fn+Q — verify with wev
-- hl.bind("<REPLACE_ME>", hl.dsp.exec_cmd("~/.config/hypr/scripts/gpu-switch.sh"))       -- Fn+G — no safe default guess, fill in after `wev`
