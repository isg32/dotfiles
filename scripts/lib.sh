#!/usr/bin/env bash
# Shared helpers sourced by every script in scripts/. Not meant to be run directly.

c_reset="\033[0m"; c_blue="\033[1;34m"; c_yellow="\033[1;33m"; c_red="\033[1;31m"; c_green="\033[1;32m"

log()  { printf "${c_blue}==>${c_reset} %s\n" "$*"; }
warn() { printf "${c_yellow}==> warning:${c_reset} %s\n" "$*"; }
err()  { printf "${c_red}==> error:${c_reset} %s\n" "$*" >&2; }
ok()   { printf "${c_green}==>${c_reset} %s\n" "$*"; }

confirm() {
    # confirm "question" — returns 0 (yes) / 1 (no). Auto-yes if ASSUME_YES=1.
    [ "${ASSUME_YES:-0}" = "1" ] && return 0
    local reply
    read -rp "$(printf '%s [y/N] ' "$1")" reply
    [[ "$reply" =~ ^[Yy]$ ]]
}

require_arch() {
    if [ ! -f /etc/arch-release ]; then
        err "This repo targets Arch Linux (pacman not found / no /etc/arch-release)."
        exit 1
    fi
}

require_not_root() {
    if [ "$EUID" -eq 0 ]; then
        err "Run this as your normal user, not root — it calls sudo itself where needed."
        exit 1
    fi
}

pkg_installed() { pacman -Qq "$1" &>/dev/null; }

# Prints the PCI bus id (e.g. 0000:00:02.0) of the first GPU matching a vendor
# grep pattern in `lspci`, or nothing if none found.
gpu_pci_address() {
    lspci -D | grep -Ei "$1" | grep -Ei 'vga|3d controller' | head -n1 | awk '{print $1}'
}

detect_gpus() {
    INTEL_PCI="$(gpu_pci_address 'intel')"
    NVIDIA_PCI="$(gpu_pci_address 'nvidia')"
    AMD_PCI="$(gpu_pci_address 'amd|ati')"
    HAS_HYBRID_NVIDIA=0
    if [ -n "$INTEL_PCI" ] && [ -n "$NVIDIA_PCI" ]; then
        HAS_HYBRID_NVIDIA=1
    fi
    return 0
}
