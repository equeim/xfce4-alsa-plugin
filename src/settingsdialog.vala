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
    private class SettingsDialog : Gtk.Dialog {
        private string[] device_ids;
        private Gtk.ComboBoxText devices_combo_box;
        private Gtk.ComboBoxText channels_combo_box;

        public SettingsDialog() {
            icon_name = "multimedia-volume-control";
            title = _("ALSA Volume Control");

            set_size_request(320, -1);

            var close_button = new Gtk.Button.from_stock(Gtk.Stock.CLOSE);
            close_button.clicked.connect(() => close());
            add_action_widget(close_button, Gtk.ResponseType.CLOSE);
            
            var table = new Gtk.Table(2, 2, false);
            ((Gtk.Container) get_content_area()).add(table);

            table.attach(new Gtk.Label(_("Device:")),
                         0,
                         1,
                         0,
                         1,
                         Gtk.AttachOptions.SHRINK,
                         Gtk.AttachOptions.SHRINK,
                         16,
                         8);

            devices_combo_box = new Gtk.ComboBoxText();
            table.attach(devices_combo_box,
                         1,
                         2,
                         0,
                         1,
                         Gtk.AttachOptions.EXPAND | Gtk.AttachOptions.FILL,
                         Gtk.AttachOptions.SHRINK,
                         0,
                         0);

            table.attach(new Gtk.Label(_("Channel:")),
                         0,
                         1,
                         1,
                         2,
                         Gtk.AttachOptions.SHRINK,
                         Gtk.AttachOptions.SHRINK,
                         16,
                         8);

            channels_combo_box = new Gtk.ComboBoxText();
            table.attach(channels_combo_box,
                         1,
                         2,
                         1,
                         2,
                         Gtk.AttachOptions.EXPAND | Gtk.AttachOptions.FILL,
                         Gtk.AttachOptions.SHRINK,
                         0,
                         0);

            string[] device_names;
            AlsaManager.get_devices(out device_ids, out device_names);

            for (int i = 0, max = device_ids.length; i < max; i++) {
                devices_combo_box.append_text(device_names[i]);
                if (device_ids[i] == alsa.device) {
                    devices_combo_box.active = i;
                }
            }

            devices_combo_box.changed.connect(() => {
                alsa.device = device_ids[devices_combo_box.active];
                update_channels();
            });

            update_channels();

            channels_combo_box.changed.connect(() => {
                if (channels_combo_box.active != -1) {
                    alsa.channel = channels_combo_box.get_active_text();
                }
            });
        }

        ~SettingsDialog() {
            Settings.save(device_ids[devices_combo_box.active], channels_combo_box.get_active_text());
        }

        private void update_channels() {
            for (int i = 0, max = channels_combo_box.model.iter_n_children(null); i < max; i++) {
                channels_combo_box.remove(0);
            }

            string[] channels = alsa.get_channels();
            for (int i = 0, max = channels.length; i < max; i++) {
                channels_combo_box.append_text(channels[i]);
                if (channels[i] == alsa.channel) {
                    channels_combo_box.active = i;
                }
            }
        }
    }
}
