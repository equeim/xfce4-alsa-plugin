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
    namespace Settings {
        private const string GROUP_NAME = "Settings";
        private const string DEVICE_ID_KEY = "alsa_device_id";
        private const string CHANNEL_KEY = "alsa_channel";
        private const string VOLUME_STEP_KEY = "volume_step";
        private const double DEFAULT_VOLUME_STEP = 3.0;

        //private const string path = Environment.get_user_config_dir();

        private void load(out string device_id, out string channel, out double volume_step) {
            var settings = new KeyFile();

            try {
                settings.load_from_file("%s/%s/%s.conf".printf(Environment.get_user_config_dir(), PACKAGE_NAME, PACKAGE_NAME), KeyFileFlags.NONE);
            } catch (Error error) {
                if (!(error is FileError.NOENT)) {
                    stderr.printf("Error loading config file: %s\n", error.message);
                }
            }

            try {
                device_id = settings.get_string(GROUP_NAME, DEVICE_ID_KEY);
            } catch (KeyFileError error) {
                device_id = "default";
            }

            try {
                channel = settings.get_string(GROUP_NAME, CHANNEL_KEY);
            } catch (KeyFileError error) {
                channel = "Master";
            }

            try {
                volume_step = settings.get_double(GROUP_NAME, VOLUME_STEP_KEY);
            } catch (KeyFileError error) {
                volume_step = DEFAULT_VOLUME_STEP;
            }
            if (volume_step < 1.0) {
                stderr.printf("Volume step can't be less than 1, setting to %f", DEFAULT_VOLUME_STEP);
                volume_step = DEFAULT_VOLUME_STEP;
            }
        }

        private void save(string device_id, string? channel, double volume_step) {
            var settings = new KeyFile();
            settings.set_string(GROUP_NAME, DEVICE_ID_KEY, device_id);
            if (channel != null) {
                settings.set_string(GROUP_NAME, CHANNEL_KEY, channel);
            }
            settings.set_double(GROUP_NAME, VOLUME_STEP_KEY, volume_step);

            string config_directory_path = "%s/%s".printf(Environment.get_user_config_dir(), PACKAGE_NAME);
            try {
                var config_directory = File.new_for_path(config_directory_path);
                config_directory.make_directory();
            } catch (Error error) {
                if (!(error is IOError.EXISTS)) {
                    stderr.printf("Error creating config file directory: %s\n", error.message);
                    return;
                }
            }

            try {
                settings.save_to_file("%s/%s.conf".printf(config_directory_path, PACKAGE_NAME));
            } catch (FileError error) {
                stderr.printf("Error saving config file: %s\n", error.message);
            }
        }
    }

    /*private class Settings {
        

        private KeyFile settings;
        private string config_file_directory_path;
        private string config_file_path;

        public string alsa_device_id {
            get {
                try {
                    return settings.get_string(GROUP_NAME, ALSA_DEVICE_ID_KEY);
                } catch (KeyFileError error) {
                    return "default";
                }
            }
            set {
                settings.set_string(GROUP_NAME, ALSA_DEVICE_ID_KEY, id);
            }
        }

        public Settings() {
            settings = new KeyFile();

            config_file_directory_path = Environment.get_user_config_dir() + "/xfce4-alsa-plugin";
            config_file_path = config_file_directory_path + "/xfce4-alsa-plugin.conf";

            try {
                settings.load_from_file(config_file_path, KeyFileFlags.NONE);
            } catch (KeyFileError error) {
                stderr.printf("Error loading config file: %s\n", error.message);
            } catch (FileError error) { }
        }

        public string get_alsa_device_id() {
            try {
                return settings.get_string(GROUP_NAME, ALSA_DEVICE_ID_KEY);
            } catch (KeyFileError error) {
                return "default";
            }
        }

        public void set_alsa_device_id(string id) {
            settings.set_string(GROUP_NAME, ALSA_DEVICE_ID_KEY, id);
        }

        public string get_alsa_channel() {
            try {
                return settings.get_string(GROUP_NAME, ALSA_CHANNEL_KEY);
            } catch (KeyFileError error) {
                return "Master";
            }
        }

        public void set_alsa_channel(string channel) {
            settings.set_string(GROUP_NAME, ALSA_CHANNEL_KEY, channel);
        }

        public void save() {
            try {
                var config_file_directory = File.new_for_path(config_file_directory_path);
                config_file_directory.make_directory();
            } catch (Error error) {
                if (!(error is IOError.EXISTS)) {
                    stderr.printf("Error creating config file directory: %s\n", error.message);
                    return;
                }
            }

            try {
                settings.save_to_file(config_file_path);
            } catch (FileError error) {
                stderr.printf("Error saving config file: %s\n", error.message);
            }
        }
    }*/
}
