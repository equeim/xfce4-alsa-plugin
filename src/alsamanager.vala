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

namespace AlsaPlugin {
    private class AlsaManager {
        private Alsa.Mixer mixer;
        private Alsa.MixerElement element;
        private IOChannel[] channels;
        private uint[] watches;
        private int fd_count;

        private string _device;
        public string device {
            get { return _device; }
            set {
                for (int i = 0; i < fd_count; i++) {
                    Source.remove(watches[i]);
                    try {
                        channels[i].shutdown(false);
                    } catch (IOChannelError error) {
                        stderr.printf("%s\n", error.message);
                    }
                }

                if (mixer != null) {
                    mixer.detach(_device);
                }

                if (element != null) {
                    element.set_callback(null);
                    element = null;
                    _channel = null;
                }

                Alsa.Mixer.open(out mixer, 0);
                if (mixer.attach(value) != 0) {
                    stderr.printf("Error setting device\n");
                    return;
                }
                _device = value;
                mixer.register();
                mixer.load();

                fd_count = mixer.get_poll_descriptors_count();
                channels = new IOChannel[fd_count];
                watches = new uint[fd_count];

                var fds = new Posix.pollfd[fd_count];
                mixer.set_poll_descriptors(fds);

                for (int i = 0; i < fd_count; ++i) {
                    var channel = new IOChannel.unix_new(fds[i].fd);
                    channels[i] = channel;
                    watches[i] = channel.add_watch(IOCondition.IN | IOCondition.HUP,  
                                                   () => {
                                                       mixer.handle_events();
                                                       return true;
                                                   });
                }

                state_changed();
            }
        }

        private string _channel;
        public string channel {
            get { return _channel; }
            set {
                _channel = value;

                Alsa.SimpleElementId sid;
                Alsa.SimpleElementId.alloc(out sid);
                sid.set_name(_channel);

                element = mixer.find_selem(sid);
                if (element == null) {
                    stderr.printf("Error setting channel\n");
                } else {
                    element.set_callback(element_callback);
                    element.set_playback_volume_range(0, 100);
                    state_changed();
                }
            }
        }

        public bool configured {
            get { return (element != null); }
        }

        public bool mute {
            get {
                if (configured) {
                    if (element.has_playback_switch()) {
                        int playback_switch;
                        element.get_playback_switch(0, out playback_switch);
                        return (playback_switch == 0);
                    }
                }
                return false;
            }
            set {
                if (configured) {
                    if (element.has_playback_switch()) {
                        element.set_playback_switch_all(value ? 0 : 1);
                    } else {
                        volume = 0;
                    }
                    state_changed();
                }
            }
        }

        public long volume {
            get {
                if (configured) {
                    long volume;
                    element.get_playback_volume(0, out volume);
                    return volume;
                }
                return 0;
            }
            set {
                if (configured) {
                    element.set_playback_volume_all(value);
                    state_changed();
                }
            }
        }

        public signal void state_changed();

        public static void get_devices(out string[] ids, out string[] names) {
            var _ids = new string[] {"default"};
            var _names = new string[] {"default"};

            int device_number = -1;
            int return_code = Alsa.Card.next(ref device_number);
            while (return_code == 0 && device_number != -1) {
                Alsa.Card card;
                string device_id = "hw:" + device_number.to_string();
                Alsa.Card.open(out card, device_id);

                Alsa.CardInfo card_info;
                Alsa.CardInfo.alloc(out card_info);
                card.card_info(card_info);

                _ids += device_id;
                _names += card_info.get_name();

                return_code = Alsa.Card.next(ref device_number);
            }

            ids = (owned) _ids;
            names = (owned) _names;
        }

        public string[] get_channels() {
            var channels = new string[] { };

            var current_element = mixer.first_elem();
            Alsa.SimpleElementId sid;
            Alsa.SimpleElementId.alloc(out sid);
            for (int i = 0; i < mixer.get_count(); i++) {
                if (current_element.has_playback_volume()) {
                    current_element.get_id(sid);
                    channels += sid.get_name();
                    current_element = current_element.next();
                }
            }

            return channels;
        }

        private static int element_callback(Alsa.MixerElement element, uint mask) {
            alsa.state_changed();
            return 0;
        }
    }
}
