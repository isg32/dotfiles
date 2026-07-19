# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A Hyprland dotfiles/installer repo meant to run *alongside* an existing GNOME
install on Arch Linux (GDM stays the login manager; GNOME stays installed).
It's not an application — there's no build step, no test suite, no runtime
to compile. The two things that matter are: (1) the shell scripts under
`scripts/` and `install.sh` that provision a machine, and (2) the config
files under `config/` that get symlinked into `~/.config/`.

Design principle driving most decisions here: reuse a GNOME app wherever one
already does the job (Settings, Nautilus, gnome-keyring, gnome-session-quit,
GTK theming via `gsettings`/`dconf`) instead of reimplementing it; only build
custom config for what GNOME can't provide under a non-gnome-shell compositor
(bar, lock screen, notification/quick-toggle center, launcher, wallpaper
picker). Keep that split in mind before adding a new component — check if a
GNOME equivalent already covers it.

## Commands

There's no build/lint/test tooling. Validate changes like this:

```sh
# Syntax-check every shell script after editing one
for f in scripts/*.sh install.sh config/hypr/scripts/*.sh; do bash -n "$f" || echo "FAIL: $f"; done

# Validate the two JSON(-ish) configs after editing them
python3 -c "import re,json; json.loads(re.sub(r'//.*','', open('config/waybar/config.jsonc').read())); print('ok')"
python3 -c "import json; json.load(open('config/swaync/config.json')); print('ok')"
```

Running the installer (only meaningful on the target Arch machine, needs
`sudo`, installs real packages — do not run casually):

```sh
./install.sh                 # full run: packages -> nvidia.sh -> sessions.sh -> link-configs.sh
SKIP_NVIDIA=1 ./install.sh   # skip all NVIDIA/GRUB/mkinitcpio/dual-session logic
ASSUME_YES=1 ./install.sh    # don't prompt before the GRUB/mkinitcpio step
./scripts/uninstall.sh       # remove the ~/.config symlinks this repo created, restore backups
```

Individual `scripts/*.sh` files can be re-run on their own (each sources
`scripts/lib.sh` and is written to be idempotent — safe to re-run after a
partial failure).

## Architecture

**Two-layer deploy model.** `config/<name>/` in this repo is the source of
truth; `scripts/link-configs.sh` symlinks each one to `~/.config/<name>`
(backing up anything already there as `<name>.bak-<timestamp>` first, never
overwriting). Editing a file under `~/.config/hypr/...` on the target machine
*is* editing this repo directly, since it's a symlink — there's no separate
"deployed copy" to keep in sync.

**`install.sh` orchestrates four idempotent stages**, each its own script,
each safe to re-run:
1. `scripts/packages.sh` — pacman installs, official repos only (no AUR).
2. `scripts/nvidia.sh` — GRUB cmdline / mkinitcpio / modprobe changes, but
   only if a hybrid GPU is actually detected (see below) and the user
   confirms; otherwise a no-op.
3. `scripts/sessions.sh` — writes `/usr/share/wayland-sessions/*.desktop`.
   Hybrid GPU → two sessions (Intel-primary, NVIDIA-primary) with wrapper
   scripts at `/usr/local/bin/hyprland-*-session` that export different
   `AQ_DRM_DEVICES`/`LIBVA_DRIVER_NAME`/etc. before `exec Hyprland`.
   Non-hybrid → a single plain session.
4. `scripts/link-configs.sh` — the symlinking described above.

**GPU detection is dynamic, not hardcoded.** `scripts/lib.sh`'s
`detect_gpus()` greps `lspci -D` for Intel/NVIDIA VGA controllers and sets
`HAS_HYBRID_NVIDIA`. `packages.sh`, `nvidia.sh`, and `sessions.sh` all branch
on this so the same repo works unmodified on a non-hybrid machine (skips
NVIDIA packages, skips GRUB/mkinitcpio edits, registers one session instead
of two). Session wrapper scripts resolve GPUs via `/dev/dri/by-path/pci-<bus
id>-card` (stable across reboots) rather than `/dev/dri/cardN` (renumbers).

**The `set -e` gotcha that bit this repo once, don't reintroduce it:** a
function whose *last* statement is `test && action` returns non-zero exactly
when the test is false — i.e. on the normal/passing path — and that becomes
the function's own return status. Under `set -euo pipefail` (every script
here uses it), calling that function as a bare statement then aborts the
whole script silently, with no error printed. This previously broke
`require_not_root`/`detect_gpus` in `scripts/lib.sh` — `install.sh` "ran"
in milliseconds and did nothing. Always use explicit `if/then/fi` for a
guard/check that's the last thing a function does; `test && action` is only
safe mid-function where the result is discarded.

**Runtime state lives outside the repo, never commit it.** Wallpaper choice
persists to `~/.config/hypr/current_wallpaper` (a symlinked path, but the
*file itself* is real, not tracked — see `.gitignore`); thumbnail cache is
`~/.cache/wallpaper-thumbs/`. `config/hypr/scripts/wallpaper-common.sh`
holds the shared helpers (`list_wallpapers`, `set_wallpaper`) that
`wallpaper-{next,picker,restore}.sh` all source.

**waybar custom modules follow a JSON-status-script pattern**: a small
script (`power-profile-status.sh`, `gpu-status.sh`) emits
`{"text":...,"tooltip":...,"class":...}` for waybar's `"return-type": "json"`
custom modules, decoupled from the click-action script
(`power-profile-cycle.sh`, `gpu-switch.sh`). Reuse this pattern for any new
bar module that needs to reflect live state rather than a static icon.

**GPU switching is confirm-then-logout, not a live hot-swap** —
`gpu-switch.sh` exists because a Wayland compositor's primary DRM device is
fixed at process start; there is no way to change it without a new Hyprland
process, and no safe way to relaunch one for a GDM-brokered session without
going back through the login screen. It best-effort pre-selects the target
session via `org.freedesktop.Accounts` D-Bus calls (`SetSession`/
`SetSessionType`, ignored on failure) purely as UX polish, then calls
`hyprctl dispatch exit`. Don't try to make this "instant" — that would mean
either faking it (bad) or bypassing GDM auth (worse).

**Hardware Fn-key bindings can't be verified without the physical device.**
`config/hypr/conf/keybinds.conf` has a documented best-guess (`XF86Launch1`)
for one Lenovo hotkey and leaves another commented out pending the user
running `wev` and reporting the real keysym. If asked to add more
hardware-hotkey bindings, do the same: implement the action as a script +
waybar module first (always works), then add a clearly-commented guessed/
placeholder keybind rather than asserting a specific keysym works.
