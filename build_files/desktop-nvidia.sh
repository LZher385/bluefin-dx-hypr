#!/bin/bash
set -euxo pipefail

# --- Replace GDM with greetd + tuigreet ---
# GDM on this NVIDIA box leaks its DRM hardware-cursor plane to the Hyprland
# session: a "ghost" cursor stays frozen at the pixel where GDM's cursor was
# at password-Enter. The ghost is not in screenshots, so it's the hardware
# cursor plane (composited by the GPU after the framebuffer), not anything
# Hyprland renders. None of the Hyprland-side knobs cleared it
# (cursor:no_hardware_cursors, WLR_NO_HARDWARE_CURSORS, hyprctl setcursor,
# DPMS toggle, full re-login). Switching greeters avoids GDM ever programming
# that plane.
#
# fw13 keeps GDM — the leak hasn't been observed on Intel/iGPU there.

dnf5 install -y greetd greetd-tuigreet

# Greetd config — tuigreet on tty1 with session/user memory so subsequent
# logins are effectively single-field (password only).
mkdir -p /etc/greetd
cat >/etc/greetd/config.toml <<'EOF'
[terminal]
vt = 1

[default_session]
command = "tuigreet --time --remember --remember-user-session --asterisks --greeting 'Welcome'"
user = "greeter"
EOF

# PAM stack — mirror GDM's gnome-keyring auto-unlock lines, otherwise apps
# that use the keyring (browsers' saved passwords, GNOME Online Accounts,
# SSH passphrases) will prompt for a manual unlock once per session.
# Leading `-` tolerates the module being absent (same convention GDM uses).
cat >/etc/pam.d/greetd <<'EOF'
auth       substack     login
-auth      optional     pam_gnome_keyring.so
account    include      login
password   substack     login
-password  optional     pam_gnome_keyring.so use_authtok
session    include      login
-session   optional     pam_gnome_keyring.so auto_start
EOF

# Bake the DM switch into the image. /etc/systemd/system symlinks persist
# across bootc updates, so the user doesn't have to flip this post-rebase.
systemctl disable gdm.service
systemctl enable greetd.service
