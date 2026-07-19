#!/usr/bin/env bash
# Entry point. Run as your normal user (not root) — sudo is invoked internally
# only for the steps that need it.
#
# Usage:
#   ./install.sh                # full install, asks before touching GRUB/mkinitcpio
#   SKIP_NVIDIA=1 ./install.sh  # never touch NVIDIA/GRUB/mkinitcpio/dual-session, even if a hybrid GPU is found
#   ASSUME_YES=1 ./install.sh   # don't prompt for confirmation (e.g. for scripted/CI use)
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/scripts/lib.sh"

require_arch
require_not_root

log "Hyprland dotfiles installer"
log "Repo: $DIR"

bash "$DIR/scripts/packages.sh"
bash "$DIR/scripts/nvidia.sh"
bash "$DIR/scripts/sessions.sh"
bash "$DIR/scripts/link-configs.sh"

cat <<EOF

$(printf '\033[1;32m==>\033[0m Install complete.')

Next steps:
  1. Reboot if the NVIDIA/GRUB/mkinitcpio step ran: sudo reboot
  2. At your display manager's login screen, click the session/gear icon and
     pick "Hyprland" (or "Hyprland (NVIDIA)" if you have a hybrid GPU).
  3. First login: check ~/.config/hypr/conf/monitors.conf matches your actual
     monitor(s) — see README "Customizing" for how to find the right names/modes.

See $DIR/README.md for the full keybind reference, wallpaper picker usage,
GPU offload (\`prime-run <cmd>\`), and troubleshooting.
EOF
