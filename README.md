# hyprland-dotfiles

Hyprland configured to sit *alongside* an existing GNOME install on Arch —
GDM stays your login manager and GNOME stays installed, but you get a second
session on the login screen for a tiling Wayland setup. Wherever a GNOME app
already does the job well (Wi-Fi, Bluetooth, sound, power, file manager,
keyring, theming), this reuses it instead of reinventing it. Everything else
(bar, lock screen, notifications/quick toggles, launcher, wallpaper picker) is
configured from scratch to match.

## What you get

| Piece | Tool | Notes |
|---|---|---|
| Compositor | [Hyprland](https://hyprland.org) | |
| Status bar | waybar | Wi-Fi/Bluetooth/volume/battery modules click through to the real GNOME Settings panels |
| Lock screen | hyprlock + hypridle | Adwaita-blue styled, auto-lock/screen-off/suspend on idle |
| Notifications + quick toggles | swaync | Volume/brightness sliders, buttons for Wi-Fi/Bluetooth/Sound/Power/Displays/Wallpaper/Lock/Power-off |
| App launcher | wofi | |
| Wallpaper control | hyprpaper + a custom wofi thumbnail-grid picker | `SUPER+W` to pick, `SUPER+SHIFT+W` to cycle next, persists across reboots |
| Screenshots | hyprshot + satty | Region screenshot opens an annotate/crop UI before saving |
| Polkit agent | hyprpolkitagent | |
| Portals | xdg-desktop-portal-hyprland + -gtk | File pickers use the GTK portal (matches GNOME look), screenshare/screenshot use the Hyprland portal |
| Theming | reused from GNOME | `gsd-xsettings` propagates your existing Adwaita GTK theme/cursor/fonts (`gsettings`/`dconf`) so nothing needs restyling separately |
| GPU switching | NVIDIA PRIME (optional, auto-detected) | Two login sessions (Intel-primary / NVIDIA-primary) + `prime-run <cmd>` for per-app offload in either; `Fn+G` / waybar icon triggers a full switch |
| Power profile | power-profiles-daemon | `Fn+Q` / waybar icon cycles quiet → balanced → performance |

Apps deliberately **not** reimplemented — GNOME's own are used instead:
Settings (`gnome-control-center`), Files (`nautilus`), Terminal
(`gnome-console`), keyring (`gnome-keyring`), shutdown/logout dialog
(`gnome-session-quit`), theming (`gnome-tweaks` still works normally — it
just edits gsettings/dconf, which isn't tied to gnome-shell).

## Requirements

- Arch Linux (official repos only — **no AUR helper needed**)
- A display manager that can offer multiple Wayland sessions (GDM, SDDM, ...
  tested with GDM)
- `sudo` access

## Install

```sh
git clone <this-repo-url> ~/dev/hyprland-dotfiles   # or wherever you keep it
cd ~/dev/hyprland-dotfiles
./install.sh
```

Run it as your **normal user**, not with `sudo` — it calls `sudo` itself only
for the steps that need root (package install, GDM session files, and,
conditionally, GRUB/mkinitcpio). You'll be prompted for your password when
those run.

What it does, in order (see `scripts/`):

1. **`packages.sh`** — installs the core package list. If it detects a hybrid
   Intel+NVIDIA GPU (via `lspci`), it also installs `nvidia-open-dkms` +
   `nvidia-prime` for PRIME offload. Nothing NVIDIA-related is installed on
   non-hybrid machines.
2. **`nvidia.sh`** — only runs (and asks for confirmation first) if a hybrid
   GPU was found: adds `nvidia_drm.modeset=1` to your kernel cmdline, adds the
   nvidia modules to `mkinitcpio.conf` for early KMS, sets fine-grained
   runtime power management so the dGPU suspends when idle, and enables
   `switcheroo-control`. Every step checks first and is safe to re-run.
3. **`sessions.sh`** — registers Hyprland as a session in
   `/usr/share/wayland-sessions/`. On a hybrid GPU this creates **two**
   sessions ("Hyprland" = Intel primary, "Hyprland (NVIDIA)" = dGPU primary);
   otherwise a single plain "Hyprland" session.
4. **`link-configs.sh`** — symlinks `config/{hypr,waybar,swaync,wofi,xdg-desktop-portal}`
   from this repo into `~/.config/`. If something already lives at one of
   those paths and isn't already one of these symlinks, it's moved aside to
   `~/.config/<name>.bak-<timestamp>` first — nothing is ever silently
   overwritten.

Because your edits live in the repo (not copies in `~/.config`), `git pull`
on a new machine + `./install.sh` reproduces the same setup, and any config
tweak you make is just a normal `git commit`.

### Flags / env vars

```sh
SKIP_NVIDIA=1 ./install.sh   # never touch NVIDIA/GRUB/mkinitcpio, even on a hybrid GPU
ASSUME_YES=1 ./install.sh    # skip the "proceed with GRUB/mkinitcpio changes?" prompt
```

### After install

1. If the NVIDIA step ran, **reboot** (kernel cmdline + initramfs changed).
2. At the login screen, click the gear/session icon and pick **Hyprland**
   (or **Hyprland (NVIDIA)** on a hybrid machine).
3. Open `~/.config/hypr/conf/monitors.conf` (a symlink into this repo) and
   check it matches your actual monitor — see "Customizing" below.

## Keybinds

`$mod` is `SUPER` (the Windows/Cmd key).

| Keys | Action |
|---|---|
| `$mod + Return` | Terminal (`gnome-console`) |
| `$mod + E` | File manager (`nautilus`) |
| `$mod + B` | Browser (`firefox`) |
| `$mod + D` | App launcher (wofi) |
| `$mod + Q` | Close focused window |
| `$mod + Shift + Q` | Force-kill focused window |
| `$mod + F` | Fullscreen |
| `$mod + Shift + Space` | Toggle floating |
| `$mod + P` | Toggle pseudotile |
| `$mod + Shift + J` | Toggle split direction |
| `$mod + Shift + E` | Exit Hyprland (back to the login screen) |
| `$mod + L` | Lock screen |
| `$mod + N` | Toggle notification/quick-toggle center |
| `$mod + I` | Open GNOME Settings |
| `$mod + V` | Clipboard history (cliphist via wofi) |
| `$mod + W` | Wallpaper picker (thumbnail grid) |
| `$mod + Shift + W` | Next wallpaper |
| `Print` | Screenshot whole output → clipboard |
| `$mod + Print` | Screenshot a region → annotate (satty) → save |
| `$mod + Shift + Print` | Screenshot focused window → save |
| `$mod + arrows` | Move focus |
| `$mod + Shift + arrows` | Move window |
| `$mod + 1..0` | Switch workspace 1-10 |
| `$mod + Shift + 1..0` | Move window to workspace 1-10 |
| `$mod + scroll` | Cycle workspace |
| `$mod + drag LMB/RMB` | Move / resize window |
| Volume/brightness/media keys | Handled natively (`wpctl`, `brightnessctl`, `playerctl`) |
| Lid close | Lock immediately |
| `Fn + Q` (Lenovo hardware key, unverified — see below) | Cycle power profile: quiet → balanced → performance |
| `Fn + G` (not bound by default — see below) | Switch primary GPU (confirms, then logs out) |

Full list, and where to change any of it: `config/hypr/conf/keybinds.conf`.

## Wallpaper control

- Source directory: `~/Pictures/wallpapers` (override by exporting
  `WALLPAPER_DIR` before calling the scripts, or edit the default in
  `config/hypr/scripts/wallpaper-common.sh`).
- `$mod + W` — opens a 3-column thumbnail grid (wofi) of everything in that
  directory. Thumbnails are generated once and cached in
  `~/.cache/wallpaper-thumbs/`.
- `$mod + Shift + W` — advances to the next wallpaper (sorted order, wraps
  around).
- The current choice is written to `~/.config/hypr/current_wallpaper` and
  restored automatically on the next login.
- Click the picture icon in the waybar bar (right side) for the same picker;
  right-click it for "next".

## GPU switching (hybrid Intel+NVIDIA only)

A Wayland compositor picks its primary GPU once, at startup — there's no live
hot-swap of the whole desktop's renderer. Three ways to actually use the
second GPU, in increasing order of how much they disrupt your session:

- **Per-app offload, no session switch needed** — from either session:
  ```sh
  prime-run steam
  prime-run blender
  ```
  Runs that one process on the NVIDIA GPU while everything else keeps using
  the session's primary GPU. This is the normal day-to-day way to use the
  dGPU, and the only one that doesn't touch your running session at all.
- **Full switch via waybar icon or `Fn+G`** — `config/hypr/scripts/gpu-switch.sh`.
  Shows a wofi confirm prompt, then (if confirmed) best-effort pre-selects the
  other session via AccountsService D-Bus calls (harmless if that's not
  honored on your system — you just pick it manually instead) and logs you
  out. **Every open app closes.** At the GDM login screen, pick the other
  session and log back in — a password re-entry is unavoidable here, there's
  no way to skip GDM's authentication step from inside the old session
  without weakening login security.
- **Manual whole-session switch** — same as above but done by hand: log out,
  and at the login screen pick "Hyprland" (Intel primary, NVIDIA dGPU stays
  runtime-suspended for battery) or "Hyprland (NVIDIA)" (dGPU is the primary
  renderer for everything).

### Verifying the `Fn+Q` / `Fn+G` hardware keybinds

`config/hypr/conf/keybinds.conf` binds power-profile cycling to `XF86Launch1`
as a best guess for this hardware's `Fn+Q` (a common mapping for the
ideapad-laptop/lenovo-wmi driver's quiet/balanced/performance key), and
leaves the `Fn+G` line commented out — there's no reliable default guess for
a GPU-switch hotkey since it isn't a standard Fn-row icon on most models.
Both actions work via their waybar icons regardless of whether the hotkey is
bound correctly, so this step is optional polish, not required for either
feature to work. To find (or confirm) the right key name:

```sh
wev
```

Run it inside a Wayland session (works under your current GNOME session too,
since it queries the compositor directly), press the physical key, and read
the `sym` value it prints for the key-press event. Some vendor hotkeys are
consumed entirely by firmware/kernel WMI handling and never reach the
compositor as a normal keysym at all — if `wev` shows nothing on keypress,
that's why, and the hotkey can't be bound this way on this hardware. Once you
have the real name(s), edit the two lines in `keybinds.conf`:

```
bind = , XF86Launch1, exec, ~/.config/hypr/scripts/power-profile-cycle.sh
bind = , <REAL_KEY_NAME>, exec, ~/.config/hypr/scripts/gpu-switch.sh
```

`switcheroo-control` is also enabled, so Nautilus's right-click "Launch Using
Discrete Graphics" works too.

## Customizing

- **Monitors**: `config/hypr/conf/monitors.conf`. Log into a Hyprland session
  once, run `hyprctl monitors` in a terminal to see actual names/preferred
  modes, then edit the file to match (works for the repo's future syncs too,
  since it's not machine-specific by default — the shipped config just
  assumes a single `1920x1080@60` panel named `eDP-1`, with a `preferred,
  auto` fallback for anything else).
- **Keybinds / apps**: `config/hypr/conf/keybinds.conf` — `$terminal`,
  `$fileManager`, `$browser` at the top control which GNOME/other apps get
  used.
- **Bar modules/style**: `config/waybar/config.jsonc` + `style.css`.
- **Quick toggles**: `config/swaync/config.json` → `widget-config.buttons-grid.actions`.
- **Idle/lock timing**: `config/hypr/hypridle.conf` (defaults: lock at 5 min
  idle, screen off at 5.5 min, suspend at 15 min).
- All of the above are symlinks into this repo — edit in place, `git commit`
  when happy. No re-run of `install.sh` needed for config-only changes; only
  re-run it if you add packages or want to (re)register sessions.

## Uninstall

```sh
./scripts/uninstall.sh
```

Removes the `~/.config/*` symlinks this repo created and restores whatever
was backed up during install (`~/.config/<name>.bak-<timestamp>`). It
deliberately does **not** touch packages, GDM session files, or
GRUB/mkinitcpio/modprobe changes, since ripping those out can affect your
GNOME session too. To remove those by hand:

```sh
# packages (only if you don't want them at all — GNOME doesn't need them)
sudo pacman -Rns hyprland hypridle hyprlock hyprpaper waybar wofi swaync \
  hyprshot grim slurp satty hyprpolkitagent xdg-desktop-portal-hyprland \
  xdg-desktop-portal-gtk switcheroo-control brightnessctl playerctl \
  wl-clipboard cliphist wtype jq imagemagick qt5ct qt6ct \
  ttf-jetbrains-mono-nerd nvidia-open-dkms nvidia-utils nvidia-settings \
  nvidia-prime libva-nvidia-driver

# session entries
sudo rm -f /usr/share/wayland-sessions/hyprland*.desktop \
           /usr/local/bin/hyprland-intel-session /usr/local/bin/hyprland-nvidia-session

# NVIDIA/kernel changes — edit these back by hand, then:
#   remove "nvidia_drm.modeset=1 nvidia_drm.fbdev=1" from /etc/default/grub, then:
sudo grub-mkconfig -o /boot/grub/grub.cfg
#   remove the four nvidia_* entries from MODULES=(...) in /etc/mkinitcpio.conf, then:
sudo mkinitcpio -P
sudo rm -f /etc/modprobe.d/nvidia-pm.conf
```

## Troubleshooting

- **Session doesn't show up at login**: confirm
  `/usr/share/wayland-sessions/hyprland.desktop` exists and GDM was restarted
  (`sudo systemctl restart gdm`, or just reboot).
- **Blank/black screen on the NVIDIA session**: make sure you rebooted after
  `nvidia.sh` ran (initramfs/cmdline changes need it) — check with
  `cat /proc/cmdline | grep nvidia_drm`.
- **No sound icon changing / wrong device**: `wpctl status` to check
  WirePlumber sees the right default sink; waybar's volume module and the
  keybinds both use `wpctl` against `@DEFAULT_AUDIO_SINK@`.
- **Wofi wallpaper picker is slow the first time**: expected — it's
  generating and caching a 320×320 thumbnail per image on first run. Repeat
  opens are fast.
- **GTK apps look themed differently than under GNOME**: make sure
  `gsd-xsettings` is actually running (`pgrep -fa gsd-xsettings`); it's
  started via `config/hypr/conf/autostart.conf`.
- **Portals misbehaving (screen share picks wrong backend, file picker looks
  wrong)**: check `~/.config/xdg-desktop-portal/hyprland-portals.conf` is in
  place and `XDG_CURRENT_DESKTOP=Hyprland` is actually set in the running
  session (`echo $XDG_CURRENT_DESKTOP`).
