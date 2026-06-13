#!/bin/bash
set -euxo pipefail

KANATA_VERSION="v1.11.0"
KANATA_SHA256="d9f634afb4c7f078cc2aacf3998fd65b432d4d83296cc48a89f941525459b4e2"
WAYLE_VERSION="v0.6.0"

# --- Terra repo (provides hyprland, hyprlock, hypridle, hyprpaper, portal) ---
if ! dnf5 repolist --all | awk '{print $1}' | grep -qx terra; then
  dnf5 install -y --nogpgcheck \
    --repofrompath="terra,https://repos.fyralabs.com/terra\$releasever" \
    terra-release
fi
dnf5 makecache --refresh -y

# --- Runtime stack ---
dnf5 install -y \
  hyprland \
  xdg-desktop-portal-hyprland \
  xdg-desktop-portal-gtk \
  hyprlock \
  hypridle \
  hyprpaper \
  kitty \
  wl-clipboard \
  cliphist \
  brightnessctl \
  grim \
  slurp \
  pavucontrol \
  tmux \
  fd-find \
  fzf \
  ripgrep

# --- kanata: fetch pinned release, verify sha256, install ---
TMP="$(mktemp -d)"
curl -fsSL -o "$TMP/kanata.zip" \
  "https://github.com/jtroo/kanata/releases/download/${KANATA_VERSION}/linux-binaries-x64.zip"
echo "${KANATA_SHA256}  $TMP/kanata.zip" | sha256sum -c -
( cd "$TMP" && bsdtar -xf kanata.zip )
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
