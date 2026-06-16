#!/bin/bash
set -euxo pipefail

# Base image is aurora-dx-nvidia-open, which already ships Plasma (Wayland).
# Hyprland comes from common.sh and sits alongside Plasma; the display
# manager picks up both sessions from /usr/share/wayland-sessions/.
#
# --- Replace plasmalogin (Aurora's default) with SDDM in X11 mode ---
# Aurora's default DM is plasmalogin — a Wayland-native KWin-based greeter.
# On NVIDIA it reproduces the same cursor-plane leak GDM has: the greeter
# programs the DRM hardware cursor plane, then on handoff to Hyprland the
# plane stays lit at the password-prompt pixel as a "ghost" cursor.
# Confirmed 2026-06-16 on this box (NVIDIA 610.43.02 + Hyprland 0.55.4).
#
# SDDM in X11 mode does not program the cursor plane the same way and has
# been confirmed leak-free on this hardware. We force DisplayServer=x11 so
# the sddm-wayland-plasma dep can't accidentally take over.
#
# fw13 stays on Bluefin + GDM — the leak hasn't been observed on Intel/iGPU.
dnf5 install -y sddm

mkdir -p /etc/sddm.conf.d
cat >/etc/sddm.conf.d/10-x11.conf <<'EOF'
[General]
DisplayServer=x11
EOF

# Explicit: autologin off. SDDM defaults to off, but the previous build's
# GDM had autologin enabled as the cursor-leak workaround — pin the new
# state in the build so a future tweak can't silently re-enable it.
cat >/etc/sddm.conf.d/20-no-autologin.conf <<'EOF'
[Autologin]
User=
Session=
Relogin=false
EOF

systemctl disable plasmalogin.service
systemctl enable sddm.service

# Pin the KDE portal for Plasma sessions so screen sharing routes through
# xdg-desktop-portal-kde explicitly.
mkdir -p /usr/share/xdg-desktop-portal
cat >/usr/share/xdg-desktop-portal/plasma-portals.conf <<'EOF'
[preferred]
default=kde
org.freedesktop.impl.portal.Secret=kde
EOF
