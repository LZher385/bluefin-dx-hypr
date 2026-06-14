#!/bin/bash
set -euxo pipefail

KANATA_VERSION="v1.11.0"
KANATA_SHA256="d9f634afb4c7f078cc2aacf3998fd65b432d4d83296cc48a89f941525459b4e2"
WAYLE_VERSION="v0.6.0"

# --- blacktau/hyprland COPR ---
# Fedora 44 retired the in-tree hyprland packages, so a third-party COPR is
# required. blacktau/hyprland is the only F44 COPR with a self-consistent
# stack: aquamarine 0.11 (linked against libdisplay-info.so.3, matching
# Fedora 44) plus hyprland 0.55.4, hyprgraphics 0.5.1, hyprlock 0.9.5, and
# xdg-desktop-portal-hyprland 1.3.12 — all SONAMEs satisfy each other.
# (solopasha's aquamarine still needs .so.2; omadora ships only the deps;
# eli-xciv's hyprland needs libhyprgraphics.so.1 but ships .so.4.)
FEDORA_VERSION="$(rpm -E %fedora)"
curl -fsSL \
  "https://copr.fedorainfracloud.org/coprs/blacktau/hyprland/repo/fedora-${FEDORA_VERSION}/blacktau-hyprland-fedora-${FEDORA_VERSION}.repo" \
  -o /etc/yum.repos.d/_copr_blacktau-hyprland.repo
# COPR repo files ship skip_if_unavailable=True, which makes transient CDN
# 404s during repodata fetch silently disable the repo — followed by an
# unhelpful "No match for argument: hyprland". Force the repo to fail loudly
# so the retry loop below can react.
sed -i 's/^skip_if_unavailable=True$/skip_if_unavailable=False/' \
  /etc/yum.repos.d/_copr_blacktau-hyprland.repo

# COPR metadata hashes rotate while builds are pushed; retry through the race.
for attempt in 1 2 3 4 5; do
  if dnf5 makecache --refresh -y; then
    break
  fi
  echo "dnf5 makecache attempt ${attempt} failed; retrying in 10s..."
  sleep 10
done

# --- Runtime stack ---
# Note: xdg-desktop-portal-gtk, wl-clipboard, tmux, and fzf ship in the
# bluefin-dx base image; dnf5 errors on "already installed", so they are
# intentionally omitted. hypridle/hyprpaper are also omitted because Wayle's
# `shell` subcommand provides idle and wallpaper management.
dnf5 install -y \
  hyprland \
  xdg-desktop-portal-hyprland \
  hyprlock \
  kitty \
  fuzzel \
  cliphist \
  brightnessctl \
  grim \
  slurp \
  pavucontrol \
  fd-find \
  ripgrep

# --- kanata: fetch pinned release, verify sha256, install ---
TMP="$(mktemp -d)"
curl -fsSL -o "$TMP/kanata.zip" \
  "https://github.com/jtroo/kanata/releases/download/${KANATA_VERSION}/linux-binaries-x64.zip"
echo "${KANATA_SHA256}  $TMP/kanata.zip" | sha256sum -c -
( cd "$TMP" && unzip -q kanata.zip )
KANATA_BIN="$(find "$TMP" -maxdepth 3 -type f -name 'kanata*' ! -name '*.zip' -executable -print -quit \
  || find "$TMP" -maxdepth 3 -type f -name 'kanata*' ! -name '*.zip' -print -quit)"
install -m0755 "$KANATA_BIN" /usr/bin/kanata
rm -rf "$TMP"

groupadd --system uinput || true
cat >/etc/udev/rules.d/99-input.rules <<'EOF'
KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
EOF
echo uinput >/etc/modules-load.d/uinput.conf

# --- Wayle: build from source, install to /usr, strip toolchain in same layer ---
dnf5 install -y \
  git cmake pkgconf-pkg-config clang gcc \
  gtk4-devel gtk4-layer-shell-devel gtksourceview5-devel \
  pulseaudio-libs-devel fftw-devel pipewire-devel systemd-devel \
  rust cargo

WAYLE_SRC="$(mktemp -d)"
git clone --depth 1 --branch "${WAYLE_VERSION}" https://github.com/wayle-rs/wayle "$WAYLE_SRC"
(
  cd "$WAYLE_SRC"
  CARGO_HOME="$WAYLE_SRC/.cargo" cargo install --locked --root /usr --path wayle
  CARGO_HOME="$WAYLE_SRC/.cargo" cargo install --locked --root /usr --path crates/wayle-settings
)
rm -rf "$WAYLE_SRC"

dnf5 remove -y \
  rust cargo clang \
  gtk4-devel gtk4-layer-shell-devel gtksourceview5-devel \
  pulseaudio-libs-devel fftw-devel pipewire-devel systemd-devel \
  cmake pkgconf-pkg-config
dnf5 autoremove -y || true

# --- Ship default skel configs ---
if [ -d /ctx/skel ]; then
  cp -a /ctx/skel/. /etc/skel/
fi
