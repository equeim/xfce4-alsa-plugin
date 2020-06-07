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
        public Gtk.Image icon = new Gtk.Image();

        private VolumePopup volume_popup;

        public VolumeButton(Plugin plugin) {
            this.plugin = plugin;

            relief = Gtk.ReliefStyle.NONE;
            add_events(Gdk.EventMask.SCROLL_MASK);

            var cssProvider = new Gtk.CssProvider();
            try {
                cssProvider.load_from_data("""
                                           .xfce4-panel button {
                                               padding: 1px;
                                           }
                                           """);
                get_style_context().add_provider(cssProvider, Gtk.STYLE_PROVIDER_PRIORITY_USER);
            } catch (Error error) {
                stderr.printf("%s\n", error.message);
            }

            add(icon);

            volume_popup = new VolumePopup(plugin);
            volume_popup.show.connect(() => {
                this.active = true;
                position_popup();
            });
            volume_popup.hide.connect(() => { this.active = false; });

            plugin.small = true;
            plugin.size_changed.connect((size) => {
                update();
                position_popup();
                return true;
            });

            plugin.mode_changed.connect((mode) => {
					stdout.printf("mode_changed called.\n");
                update();
                position_popup();
            });

            alsa.state_changed.connect(update);
            button_press_event.connect(on_button_press_event);
            scroll_event.connect(on_scroll_event);
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

            int size = plugin.size / (int) plugin.nrows;
            set_size_request(size, size);

            icon.set_from_icon_name(icon_name, Gtk.IconSize.BUTTON);
            icon.set_pixel_size(plugin.get_icon_size());

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

        private void position_popup() {
            if (volume_popup.visible) {
                int x = 0;
                int y = 0;
                plugin.position_widget(volume_popup, this, out x, out y);
                volume_popup.move(x, y);
            }
        }

        bool on_button_press_event(Gdk.EventButton event) {
            if (event.type == Gdk.EventType.BUTTON_PRESS) {
                switch (event.button) {
                case 1:
                {
                    if (alsa.configured) {
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
                    volume += (long) plugin.volume_step;
                    if (volume > 100) {
                        volume = 100;
                    }
                } else {
                    volume -= (long) plugin.volume_step;
                    if (volume < 0) {
                        volume = 0;
                    }
                }

                alsa.volume = volume;

                return true;
            }

            return false;
        }
    }
}
