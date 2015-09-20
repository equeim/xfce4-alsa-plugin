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

public class PluginSettings {
    const string GROUP_NAME = "Settings";
    const string ALSA_DEVICE_ID_KEY = "alsa_device_id";
    const string ALSA_CHANNEL_KEY = "alsa_channel";

    string config_file_directory_path;
    string config_file_path;
    GLib.KeyFile settings;

    public PluginSettings() {
        config_file_directory_path = GLib.Environment.get_user_config_dir() +
                                "/xfce4-alsa-plugin";
        config_file_path = config_file_directory_path + "/xfce4-alsa-plugin.conf";

        settings = new GLib.KeyFile();
        try {
            settings.load_from_file(config_file_path, KeyFileFlags.NONE);
        } catch (GLib.KeyFileError error) {
            GLib.stderr.printf("Error loading config file: %s\n", error.message);
        } catch (GLib.FileError error) { }
    }

    public string get_alsa_device_id() {
        try {
            return settings.get_string(GROUP_NAME, ALSA_DEVICE_ID_KEY);
        } catch (GLib.KeyFileError error) {
            return "default";
        }
    }

    public void set_alsa_device_id(string device_id) {
        settings.set_string(GROUP_NAME, ALSA_DEVICE_ID_KEY, device_id);
    }

    public string get_alsa_channel() {
        try {
            return settings.get_string(GROUP_NAME, ALSA_CHANNEL_KEY);
        } catch (GLib.KeyFileError error) {
            return "Master";
        }
    }

    public void set_alsa_channel(string channel) {
        settings.set_string(GROUP_NAME, ALSA_CHANNEL_KEY, channel);
    }

    public void save() {
        GLib.File config_file_directory = GLib.File.new_for_path(config_file_directory_path);
        if (!config_file_directory.query_exists()) {
            try {
                config_file_directory.make_directory();
            } catch (GLib.Error error) {
                GLib.stderr.printf("Error creating config file directory: %s\n", error.message);
            }
        }

        try {
            settings.save_to_file(config_file_path);
        } catch (GLib.FileError error) {
            GLib.stderr.printf("Error saving config file: %s\n", error.message);
        }
    }
}
