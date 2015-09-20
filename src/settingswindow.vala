/*
 * xfce4-alsa-plugin
 * Copyright (C) 2015 Alexey Rochev <equeim@gmail.com>
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

public class SettingsWindow : Gtk.Dialog {
    VolumeButton volume_button;
    PluginSettings plugin_settings;
    Gtk.ComboBoxText device_combo;
    Gtk.ComboBoxText channel_combo;
    GLib.List<string> device_id_list;
    GLib.List<string> device_name_list;
    uint n_channels;

    public SettingsWindow(VolumeButton volume_button, PluginSettings plugin_settings) {
        this.volume_button = volume_button;
        this.plugin_settings = plugin_settings;

        icon_name = "multimedia-volume-control";
        title = _("ALSA Volume Control");
        set_size_request(320, -1);

        Gtk.Button close_button = new Gtk.Button.from_stock(Gtk.Stock.CLOSE);
        close_button.clicked.connect(() => { close(); });
        add_action_widget(close_button, Gtk.ResponseType.CLOSE);

        Gtk.Table layout = new Gtk.Table(2, 2, false);
        ((Gtk.Container) get_content_area()).add(layout);

        // Device label
        layout.attach(new Gtk.Label(_("Device:")),
                      0,
                      1,
                      0,
                      1,
                      Gtk.AttachOptions.SHRINK,
                      Gtk.AttachOptions.SHRINK,
                      16,
                      8);

        // Device combo
        device_combo = new Gtk.ComboBoxText();
        layout.attach(device_combo,
                      1,
                      3,
                      0,
                      1,
                      Gtk.AttachOptions.EXPAND | Gtk.AttachOptions.FILL,
                      Gtk.AttachOptions.SHRINK,
                      0,
                      0);

        alsa.get_device_list(out device_id_list, out device_name_list);
        foreach (string device_name in device_name_list) {
            device_combo.append_text(device_name);
        }

        string current_device_id = alsa.get_device();
        int device_index = -1;
        for (int i = 0; i < device_id_list.length(); i++) {
            if (device_id_list.nth_data(i) == current_device_id) {
                device_index = i;
                break;
            }
        }
        if (device_index != -1)
            device_combo.set_active(device_index);
        device_combo.changed.connect(on_device_combo_changed);

        // Channel label
        layout.attach(new Gtk.Label(_("Channel:")),
                      0,
                      1,
                      1,
                      3,
                      Gtk.AttachOptions.SHRINK,
                      Gtk.AttachOptions.SHRINK,
                      16,
                      8);

        // Channel Combo
        channel_combo = new Gtk.ComboBoxText();
        layout.attach(channel_combo,
                      1,
                      3,
                      1,
                      3,
                      Gtk.AttachOptions.EXPAND | Gtk.AttachOptions.FILL,
                      Gtk.AttachOptions.SHRINK,
                      0,
                      0);

        GLib.List<string> channel_list = alsa.get_channel_list();
        n_channels = channel_list.length();
        foreach (string channel in channel_list) {
            channel_combo.append_text(channel);
        }

        string current_channel = alsa.get_channel();
        int channel_index = -1;
        for (int i = 0; i < channel_list.length(); i++) {
            if (channel_list.nth_data(i) == current_channel) {
                channel_index = i;
                break;
            }
        }
        if (channel_index != -1)
            channel_combo.set_active(channel_index);
        channel_combo.changed.connect(on_channel_combo_changed);
    }

    ~SettingsWindow() {
        plugin_settings.save();
    }

    void on_device_combo_changed() {
        string current_device_name = device_combo.get_active_text();
        for (int i = 0; i < device_name_list.length(); i++) {
            if (device_name_list.nth_data(i) == current_device_name) {
                string device_id = device_id_list.nth_data(i);
                if (device_id != alsa.get_device())
                    set_device(device_id);
                break;
            }
        }
    }

    void set_device(string device_id) {
        try {
            alsa.set_device(device_id);
        } catch (AlsaError error) {
            GLib.stderr.printf("%s\n", error.message);
        }

        plugin_settings.set_alsa_device_id(device_id);
        for (int i = 0; i < n_channels; i++) {
            channel_combo.remove(0);
        }

        GLib.List<string> channel_list = alsa.get_channel_list();
        n_channels = channel_list.length();
        if (channel_list.length() == 0) {
            if (volume_button.plugin_active)
                volume_button.plugin_active = false;
        } else {
            foreach (string channel in channel_list) {
                channel_combo.append_text(channel);
            }
            channel_combo.set_active(0);
        }
    }

    void on_channel_combo_changed() {
        string channel = channel_combo.get_active_text();
        if (channel != null) {
            try {
                alsa.set_channel(channel);
            } catch (AlsaError error) {
                GLib.stderr.printf("%s\n", error.message);
            }
            plugin_settings.set_alsa_channel(channel);
            if (volume_button.plugin_active)
                volume_button.update_button();
            else
                volume_button.plugin_active = true;
            volume_button.volume_popup.update_scale();
        }
    }
}
