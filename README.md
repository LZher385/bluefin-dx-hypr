# bluefin-dx-hypr

Custom [bootc](https://containers.github.io/bootc/) images built on top of
[Bluefin DX](https://projectbluefin.io/) with [Hyprland](https://hyprland.org/)
and the [Wayle](https://github.com/wayle-rs/wayle) desktop shell.

## Variants

| Image | Base | Hardware |
|---|---|---|
| `bluefin-dx-hypr-fw13` | `ghcr.io/ublue-os/bluefin-dx:stable` | Framework 13 (adds fprintd) |
| `bluefin-dx-hypr-desktop-nvidia` | `ghcr.io/ublue-os/bluefin-dx-nvidia-open:stable` | Desktop with NVIDIA |

## What's installed

- **Compositor**: Hyprland + `xdg-desktop-portal-hyprland`
- **Shell**: [Wayle](https://github.com/wayle-rs/wayle) `v0.6.0` (built from source) — bar, notifications, OSD, wallpaper, device controls
- **Idle/Lock**: `hypridle` + `hyprlock`
- **Wallpaper**: `hyprpaper` (Wayle can also drive it)
- **Terminal**: `kitty`
- **Utilities**: `wl-clipboard`, `cliphist`, `brightnessctl`, `grim`, `slurp`, `pavucontrol`, `tmux`, `fd`, `fzf`, `ripgrep`
- **Keyboard remapper**: `kanata` `v1.11.0` (binary fetched at build time, sha256 verified)

Default user configs are shipped in `/etc/skel/.config/{hypr,wayle}/`.

## Usage

Rebase an existing Bluefin/uBlue install onto an image:

```sh
sudo bootc switch ghcr.io/<your-owner>/bluefin-dx-hypr-fw13:latest
sudo systemctl reboot
```

## Build locally

```sh
podman build -f Containerfile.fw13 -t bluefin-dx-hypr-fw13:dev .
podman build -f Containerfile.desktop-nvidia -t bluefin-dx-hypr-desktop-nvidia:dev .
```

## CI

- `.github/workflows/build.yml` — daily build + push of both variants to GHCR, cosign-signed.
- `.github/workflows/build-disk.yml` — on-demand qcow2 / anaconda-iso builds per variant.

## Acknowledgements

Forked structure from the [ublue-os image-template](https://github.com/ublue-os/image-template).
