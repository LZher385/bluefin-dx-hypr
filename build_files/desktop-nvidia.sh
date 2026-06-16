#!/bin/bash
set -euxo pipefail

# Base image is aurora-dx-nvidia-open, which already ships Plasma (Wayland)
# and SDDM as defaults — no DE install, no DM swap needed. Hyprland from
# common.sh sits alongside Plasma; SDDM auto-discovers both from
# /usr/share/wayland-sessions/.
#
# History note: this image previously rebased from bluefin-dx-nvidia-open,
# where GDM leaked its DRM hardware-cursor plane into the Hyprland session
# (a "ghost" cursor frozen at the password-prompt pixel on NVIDIA). Moving
# to Aurora drops GDM entirely, sidestepping the leak. The fw13 build stays
# on Bluefin since the leak hasn't been observed on Intel/iGPU.
#
# Pin the KDE portal for Plasma sessions so screen sharing routes through
# xdg-desktop-portal-kde explicitly (Aurora sets this, but make it
# load-bearing in our build).
mkdir -p /usr/share/xdg-desktop-portal
cat >/usr/share/xdg-desktop-portal/plasma-portals.conf <<'EOF'
[preferred]
default=kde
org.freedesktop.impl.portal.Secret=kde
EOF
