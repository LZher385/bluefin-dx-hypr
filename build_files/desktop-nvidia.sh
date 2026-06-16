#!/bin/bash
set -euxo pipefail

# --- Plasma (Wayland) as fallback DE alongside Hyprland ---
# GNOME on this NVIDIA box has been unreliable to log into; Plasma serves as
# a working graphical fallback and handles screen sharing / video calls more
# reliably on NVIDIA Wayland than GNOME does. GNOME from the base image is
# left installed but no longer the primary path.
dnf5 install -y \
    plasma-desktop plasma-workspace-wayland \
    plasma-nm plasma-pa \
    kscreen kwallet-pam \
    konsole dolphin \
    xdg-desktop-portal-kde \
    sddm

# Pin the KDE portal for Plasma sessions so screen sharing routes through
# xdg-desktop-portal-kde rather than the GNOME portal that's also present.
mkdir -p /usr/share/xdg-desktop-portal
cat >/usr/share/xdg-desktop-portal/plasma-portals.conf <<'EOF'
[preferred]
default=kde
org.freedesktop.impl.portal.Secret=kde
EOF

# --- Replace GDM with SDDM ---
# GDM on this NVIDIA box leaks its DRM hardware-cursor plane to the Hyprland
# session: a "ghost" cursor stays frozen at the pixel where GDM's cursor was
# at password-Enter. The ghost is not in screenshots, so it's the hardware
# cursor plane (composited by the GPU after the framebuffer), not anything
# Hyprland renders. None of the Hyprland-side knobs cleared it
# (cursor:no_hardware_cursors, WLR_NO_HARDWARE_CURSORS, hyprctl setcursor,
# DPMS toggle, full re-login). Switching display managers avoids GDM ever
# programming that plane.
#
# fw13 keeps GDM — the leak hasn't been observed on Intel/iGPU there.
#
# SDDM session discovery picks up Hyprland and Plasma automatically from
# /usr/share/wayland-sessions/.

systemctl disable gdm.service
systemctl enable sddm.service
