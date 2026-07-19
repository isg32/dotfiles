#!/usr/bin/env bash
# Registers Hyprland as a session your display manager (GDM, SDDM, ...) can
# launch, alongside whatever DE you already have. On a hybrid Intel+NVIDIA
# machine it registers two sessions so you can pick which GPU is primary at
# login; otherwise it registers a single plain "Hyprland" session.
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/lib.sh"

detect_gpus

if [ "$HAS_HYBRID_NVIDIA" = "1" ] && [ "${SKIP_NVIDIA:-0}" != "1" ]; then
    log "Hybrid GPU detected — creating an Intel-primary and an NVIDIA-primary session"

    sudo tee /usr/local/bin/hyprland-intel-session >/dev/null <<'EOF'
#!/usr/bin/env bash
export LIBVA_DRIVER_NAME=i915
unset GBM_BACKEND
unset __GLX_VENDOR_LIBRARY_NAME
exec start-hyprland
EOF
    sudo chmod +x /usr/local/bin/hyprland-intel-session

    sudo tee /usr/share/wayland-sessions/hyprland.desktop >/dev/null <<'EOF'
[Desktop Entry]
Name=Hyprland
Comment=Hyprland on the Intel iGPU (NVIDIA idle, use `prime-run <cmd>` to offload)
Exec=/usr/local/bin/hyprland-intel-session
Type=Application
DesktopNames=Hyprland
EOF

    # by-path symlinks keyed on PCI bus id stay stable across reboots even if
    # /dev/dri/cardN numbering changes.
    sudo tee /usr/local/bin/hyprland-nvidia-session >/dev/null <<EOF
#!/usr/bin/env bash
NVIDIA_CARD=\$(readlink -f /dev/dri/by-path/pci-${NVIDIA_PCI}-card)
INTEL_CARD=\$(readlink -f /dev/dri/by-path/pci-${INTEL_PCI}-card)
export AQ_DRM_DEVICES="\${NVIDIA_CARD}:\${INTEL_CARD}"
export WLR_DRM_DEVICES="\${NVIDIA_CARD}:\${INTEL_CARD}"
export LIBVA_DRIVER_NAME=nvidia
export GBM_BACKEND=nvidia-drm
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export __GL_GSYNC_ALLOWED=0
export __GL_VRR_ALLOWED=0
exec start-hyprland
EOF
    sudo chmod +x /usr/local/bin/hyprland-nvidia-session

    sudo tee /usr/share/wayland-sessions/hyprland-nvidia.desktop >/dev/null <<'EOF'
[Desktop Entry]
Name=Hyprland (NVIDIA)
Comment=Hyprland with the NVIDIA GPU as primary renderer (heavier workloads, more battery use)
Exec=/usr/local/bin/hyprland-nvidia-session
Type=Application
DesktopNames=Hyprland
EOF

    ok "Created sessions: 'Hyprland' (Intel) and 'Hyprland (NVIDIA)'"
else
    log "No hybrid GPU (or NVIDIA setup skipped) — creating a single plain session"
    sudo tee /usr/share/wayland-sessions/hyprland.desktop >/dev/null <<'EOF'
[Desktop Entry]
Name=Hyprland
Comment=Hyprland compositor
Exec=start-hyprland
Type=Application
DesktopNames=Hyprland
EOF
    ok "Created session: 'Hyprland'"
fi

log "Pick it from your display manager's session/gear menu on next login."
