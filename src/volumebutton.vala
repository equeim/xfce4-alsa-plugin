/*
 * xfce4-alsa-plugin
 * Copyright (C) 2015-2016 Alexey Rochev <equeim@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace AlsaPlugin {
    private class VolumeButton : Gtk.ToggleButton {
        private Plugin plugin;
        private Xfce.PanelImage icon;
        private string current_icon;

        private VolumePopup volume_popup;

        public VolumeButton(Plugin plugin) {
            this.plugin = plugin;

            relief = Gtk.ReliefStyle.NONE;
            Gtk.rc_parse_string("""
                                style "button-style"
                                {
                                    GtkButton::inner-border = {0, 0, 0, 0}
                                }
                                widget_class "*<AlsaPluginVolumeButton>" style "button-style"
                                """);

            icon = new Xfce.PanelImage();
            add(icon);

            volume_popup = new VolumePopup(plugin);
            volume_popup.show.connect(() => { this.active = true; });
            volume_popup.hide.connect(() => { this.active = false; });

            alsa.state_changed.connect(update);
            button_press_event.connect(on_button_press_event);
            scroll_event.connect(on_scroll_event);

            update();
        }

        private void update() {
            long volume = alsa.volume;
            bool mute = alsa.mute;

            string icon_name;
            if (mute || volume == 0) {
                icon_name = "audio-volume-muted";
            } else if (volume <= 33) {
                icon_name = "audio-volume-low";
            } else if (volume <= 66) {
                icon_name = "audio-volume-medium";
            } else {
                icon_name = "audio-volume-high";
            }

            if (icon_name != current_icon) {
                current_icon = icon_name;
                icon.set_from_source(icon_name);
            }

            if (alsa.configured) {
                if (mute) {
                    tooltip_text = "%s: %s".printf(alsa.channel, _("muted"));
                } else {
                    tooltip_text = "%s: %d%s".printf(alsa.channel, (int) volume, "%");
                }
            } else {
                tooltip_text = _("Volume control is not configured");
            }
        }

        bool on_button_press_event(Gdk.EventButton event) {
            if (event.type == Gdk.EventType.BUTTON_PRESS) {
                switch (event.button) {
                case 1:
                {
                    if (alsa.configured) {
                        int x, y;
                        plugin.position_widget(volume_popup, this, out x, out y);
                        volume_popup.move(x, y);
                        volume_popup.show_all();
                    }
                    return true;
                }
                case 2:
                    alsa.mute = !alsa.mute;
                    return true;
                }
            }

            return false;
        }

        bool on_scroll_event(Gdk.EventScroll event) {
            long volume = alsa.volume;
            if ((event.direction == Gdk.ScrollDirection.UP && volume < 100) ||
                    (event.direction == Gdk.ScrollDirection.DOWN && volume > 0)) {

                if (event.direction == Gdk.ScrollDirection.UP) {
                    if (volume >= 97) {
                        volume = 100;
                    } else {
                        volume += 3;
                    }
                } else {
                    if (volume <= 3) {
                        volume = 0;
                    } else {
                        volume -= 3;
                    }
                }

                alsa.volume = volume;

                return true;
            }

            return false;
        }
    }
}
