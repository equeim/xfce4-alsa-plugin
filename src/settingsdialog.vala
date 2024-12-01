// SPDX-FileCopyrightText: 2015-2024 Alexey Rochev
//
// SPDX-License-Identifier: GPL-3.0-or-later

namespace AlsaPlugin {
    private class SettingsDialog : Gtk.Dialog {
        private string[] device_ids;
        private Gtk.ComboBoxText devices_combo_box;
        private Gtk.ComboBoxText channels_combo_box;

        public SettingsDialog(Plugin plugin) {
            icon_name = "multimedia-volume-control";
            title = _("ALSA Volume Control");

            var close_button = new Gtk.Button.from_icon_name("window-close");
            close_button.label = _("Close");
            close_button.clicked.connect(() => close());
            add_action_widget(close_button, Gtk.ResponseType.CLOSE);

            var devices_label = new Gtk.Label(_("Device:"));
            devices_combo_box = new Gtk.ComboBoxText();
            var channels_label = new Gtk.Label(_("Channel:"));
            channels_combo_box = new Gtk.ComboBoxText();
            var step_label = new Gtk.Label(_("Volume step:"));
            var step_spin_button = new Gtk.SpinButton.with_range(1.0, 25.0, 1.0);
            step_spin_button.set_value(plugin.volume_step);

            devices_combo_box.hexpand = true;
            devices_combo_box.margin = 8;
            devices_combo_box.margin_top = 0;
            channels_combo_box.hexpand = true;
            channels_combo_box.margin = 8;
            channels_combo_box.margin_top = 0;

            var grid = new Gtk.Grid();
            grid.margin_bottom = 16;

            Gtk.Box content_area = (Gtk.Box) get_content_area();
            content_area.add(grid);

            devices_label.margin_start = 16;
            devices_label.margin_end = 16;
            grid.attach(devices_label, 0, 0);
            grid.attach(devices_combo_box, 1, 0);

            channels_label.margin_start = 16;
            channels_label.margin_end = 16;
            grid.attach(channels_label, 0, 1);
            grid.attach(channels_combo_box, 1, 1);

            step_label.margin_start = 16;
            step_label.margin_end = 16;
            grid.attach(step_label, 0, 2);
            step_spin_button.margin_start = 8;
            step_spin_button.margin_end = 8;
            grid.attach(step_spin_button, 1, 2);

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

            step_spin_button.value_changed.connect(() => {
                plugin.volume_step = step_spin_button.value;
            });

            response.connect((response_id) => {
                Settings.save(device_ids[devices_combo_box.active], channels_combo_box.get_active_text(), step_spin_button.value);
            });
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
            if (channels_combo_box.active == -1) {
                channels_combo_box.active = 0;
            }
        }
    }
}
