#!/usr/bin/env bash
# Configures the open-source NVIDIA kernel modules for a Hyprland session with
# PRIME render offload. Only runs anything if a hybrid Intel+NVIDIA GPU is
# detected; safe to re-run (every step is idempotent).
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/lib.sh"

if [ "${SKIP_NVIDIA:-0}" = "1" ]; then
    log "SKIP_NVIDIA=1 — skipping NVIDIA/GRUB/mkinitcpio changes"
    exit 0
fi

detect_gpus
if [ "$HAS_HYBRID_NVIDIA" != "1" ]; then
    log "No hybrid Intel+NVIDIA GPU detected — nothing to do here"
    exit 0
fi

log "Hybrid GPU: Intel at $INTEL_PCI, NVIDIA at $NVIDIA_PCI"
warn "This step edits kernel cmdline (GRUB), mkinitcpio.conf and modprobe.d, and"
warn "requires a reboot. It only affects boot config, not your existing GNOME session."
if ! confirm "Proceed with NVIDIA/GRUB/mkinitcpio changes?"; then
    log "Skipped by user"
    exit 0
fi

log "Adding nvidia modules to mkinitcpio MODULES for early KMS"
if ! grep -q 'nvidia_drm' /etc/mkinitcpio.conf; then
    sudo sed -i '/^MODULES=/ s/^MODULES=(\(.*\))/MODULES=(\1 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
    sudo sed -i '/^MODULES=/ s/(  */(/; /^MODULES=/ s/  */ /g' /etc/mkinitcpio.conf
else
    log "mkinitcpio.conf already has nvidia_drm — skipping"
fi
sudo mkinitcpio -P

log "Enabling fine-grained NVIDIA runtime power management (dGPU suspends when idle)"
sudo tee /etc/modprobe.d/nvidia-pm.conf >/dev/null <<'EOF'
options nvidia "NVreg_DynamicPowerManagement=0x02"
options nvidia NVreg_PreserveVideoMemoryAllocations=1
EOF

log "Enabling NVIDIA suspend/resume systemd units"
sudo systemctl enable nvidia-suspend.service nvidia-hibernate.service nvidia-resume.service 2>/dev/null || true

log "Adding nvidia_drm.modeset=1 to kernel cmdline (GRUB)"
if [ -f /etc/default/grub ]; then
    if ! grep -q 'nvidia_drm.modeset=1' /etc/default/grub; then
        sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 nvidia_drm.modeset=1 nvidia_drm.fbdev=1"/' /etc/default/grub
    else
        log "GRUB cmdline already has nvidia_drm.modeset=1 — skipping"
    fi
    sudo grub-mkconfig -o /boot/grub/grub.cfg
else
    warn "/etc/default/grub not found — if you use systemd-boot/rEFInd/other, add"
    warn "  nvidia_drm.modeset=1 nvidia_drm.fbdev=1"
    warn "to your kernel cmdline manually."
fi

log "Enabling switcheroo-control (lets Nautilus etc. offer 'Launch using Discrete Graphics')"
sudo systemctl enable --now switcheroo-control.service

ok "NVIDIA setup done — a reboot is required before the new initramfs/cmdline take effect."
