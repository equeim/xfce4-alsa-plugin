# xfce4-alsa-plugin
Simple ALSA volume control for xfce4-panel

## Installation
### Dependencies
- Vala
- Meson >= 0.37.0
- ALSA userspace library (libasound)
- libxfce4panel-1.0
- gettext >= 0.19.7

### Building
```sh
meson build
ninja -C build
ninja -C build install
```
