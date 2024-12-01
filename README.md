# xfce4-alsa-plugin
Simple ALSA volume control for xfce4-panel

## Installation
### Dependencies
- Vala
- Meson >= 0.37.0
- ALSA userspace library (libasound)
- gettext >= 0.19.7
- libxfce4panel-2.0 >= 4.13.0
- gtk+-3.0 >= 3.20.0

### Building
```sh
meson setup build
meson compile -C build
meson install -C build
```
