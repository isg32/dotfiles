-- Hyprland main config (Lua, required since 0.55 for window rules / gestures —
-- see README.md "Hyprlang -> Lua migration" for why this repo isn't hyprlang anymore).
-- Sourcing order matters: env vars first, then look/input, then autostart, then binds/rules.

require("conf/env")
require("conf/monitors")
require("conf/look")
require("conf/input")
require("conf/autostart")
require("conf/keybinds")
require("conf/windowrules")
