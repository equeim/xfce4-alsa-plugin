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

public errordomain AlsaError {
    DEVICE,
    CHANNEL
}

public class AlsaManager {
    Alsa.Mixer mixer;
    Alsa.MixerElement element;
    GLib.IOChannel[] channels;
    uint[] watches;
    int n_fds;
    string device;
    string channel;

    public bool mute {
        get {
            if (element.has_playback_switch()) {
                int playback_switch;
                element.get_playback_switch(0, out playback_switch);
                return playback_switch == 0;
            }
            return false;
        }
        set {
            if (element.has_playback_switch())
                element.set_playback_switch_all(value ? 0 : 1);
            else
                volume = 0;
        }
    }

    public long volume {
        get {
            long volume;
            element.get_playback_volume(0, out volume);
            return volume;
        }
        set {
            element.set_playback_volume_all(value);
        }
    }

    public signal void state_changed();

    bool poll_callback(GLib.IOChannel channel, GLib.IOCondition cond) {
        mixer.handle_events();
        return true;
    }

    static int element_callback(Alsa.MixerElement element, uint mask) {
        alsa.state_changed();
        return 0;
    }

    public string get_device() {
        return device;
    }
    public void set_device(string device) throws AlsaError {
        for (int i = 0; i < n_fds; i++) {
            GLib.Source.remove(watches[i]);
            try {
                channels[i].shutdown(false);
            } catch (GLib.IOChannelError error) {
                GLib.stderr.printf("%s\n", error.message);
            }
        }

        if (mixer != null)
            mixer.detach(this.device);

        if (element != null)
            element.set_callback(null);

        Alsa.Mixer.open(out mixer, 0);
        if (mixer.attach(device) != 0)
            throw new AlsaError.DEVICE("Error setting device");
        this.device = device;
        mixer.register();
        mixer.load();

        n_fds = mixer.get_poll_descriptors_count();
        channels = new GLib.IOChannel[n_fds];
        watches = new uint[n_fds];

        Posix.pollfd[] fds = new Posix.pollfd[n_fds];
        mixer.set_poll_descriptors(fds);

        for (int i = 0; i < n_fds; ++i) {
            GLib.IOChannel channel = new GLib.IOChannel.unix_new(fds[i].fd);
            channels[i] = channel;
            watches[i] = channel.add_watch(GLib.IOCondition.IN | GLib.IOCondition.HUP,  
                                           poll_callback);
        }
    }

    public string get_channel() {
        return channel;
    }
    public void set_channel(string channel) throws AlsaError {
        this.channel = channel;

        Alsa.SimpleElementId sid;
        Alsa.SimpleElementId.alloc(out sid);
        sid.set_name(this.channel);

        element = mixer.find_selem(sid);
        if (element == null) {
            throw new AlsaError.CHANNEL("Error setting channel");
        } else {
            element.set_callback(element_callback);
            element.set_playback_volume_range(0, 100);
        }
    }

    public void get_device_list(out GLib.List<string> id_list, out GLib.List<string> name_list) {
        id_list = new GLib.List<string>();
        name_list = new GLib.List<string>();

        id_list.append("default");
        name_list.append("default");

        int device_number = -1;
        int ret = Alsa.Card.next(ref device_number);
        while(ret == 0 && device_number != -1) {
            Alsa.Card card;
            string device_id = "hw:" + device_number.to_string();
            Alsa.Card.open(out card, device_id);

            Alsa.CardInfo card_info;
            Alsa.CardInfo.alloc(out card_info);
            card.card_info(card_info);

            id_list.append(device_id);
            name_list.append(card_info.get_name());

            ret = Alsa.Card.next(ref device_number);
        }
    }

    public GLib.List<string> get_channel_list() {
        GLib.List<string> list = new GLib.List<string>();

        Alsa.MixerElement current_element = mixer.first_elem();
        Alsa.SimpleElementId sid;
        Alsa.SimpleElementId.alloc(out sid);
        for (int i = 0; i < mixer.get_count(); i++) {
            if (current_element.has_playback_volume()) {
                current_element.get_id(sid);
                list.append(sid.get_name());
                current_element = current_element.next();
            }
        }

        return list;
    }
}
