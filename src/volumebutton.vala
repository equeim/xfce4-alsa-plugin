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

public class VolumeButton : Gtk.ToggleButton {
    Xfce.PanelPlugin plugin;
    Xfce.PanelImage volume_icon;
    string current_icon_name;

    public VolumePopup volume_popup { get; private set; }

    bool _plugin_active;
    public bool plugin_active {
        get {
            return _plugin_active;
        }
        set {
            _plugin_active = value;
            if (_plugin_active) {
                button_press_event.disconnect(on_button_press_event_inactive);
                button_press_event.connect(on_button_press_event);
                scroll_event.connect(on_scroll_event);

                update_button();
                volume_popup.update_scale();
            } else {
                button_press_event.disconnect(on_button_press_event);
                button_press_event.connect(on_button_press_event_inactive);
                scroll_event.disconnect(on_scroll_event);

                current_icon_name = "audio-volume-muted";
                volume_icon.set_from_source(current_icon_name);

                tooltip_text = _("Plugin is inactive");
            }
        }
    }

    public VolumeButton(Xfce.PanelPlugin plugin, bool active) {
        this.plugin = plugin;

        relief = Gtk.ReliefStyle.NONE;
        Gtk.rc_parse_string("""
            style "button" {
                GtkButton::inner-border = { 0, 0, 0, 0 }
            }
            widget_class "*<VolumeButton>" style "button"
        """);

        volume_popup = new VolumePopup(this.plugin, this, active);

        volume_icon = new Xfce.PanelImage();
        add(volume_icon);

        alsa.state_changed.connect(update_button);

        if (active)
            plugin_active = true;
        else
            plugin_active = false;
    }

    public void update_button() {
        long volume = alsa.volume;
        bool mute = alsa.mute;

        string icon_name;
        if (mute || volume == 0)
            icon_name = "audio-volume-muted";
        else if (volume <= 33)
            icon_name = "audio-volume-low";
        else if (volume <= 66)
            icon_name = "audio-volume-medium";
        else
            icon_name = "audio-volume-high";

        if (icon_name != current_icon_name) {
            current_icon_name = icon_name;
            volume_icon.set_from_source(current_icon_name);
        }

        if (mute)
            tooltip_text = "%s: %s".printf(alsa.get_channel(), _("muted"));
        else
            tooltip_text = "%s: %d%s".printf(alsa.get_channel(), (int) volume, "%");
    }

    bool on_button_press_event(Gdk.EventButton event) {
        if (event.button == 1) {
            int x, y;
            plugin.position_widget(volume_popup, this, out x, out y);
            volume_popup.move(x, y);
            volume_popup.show_all();
            Gtk.grab_add(volume_popup);
        
            if (Gdk.pointer_grab(volume_popup.get_window(),
                                 true,
                                 Gdk.EventMask.BUTTON_PRESS_MASK |
                                 Gdk.EventMask.BUTTON_RELEASE_MASK |
                                 Gdk.EventMask.POINTER_MOTION_MASK,
                                 null,
                                 null,
                                 Gdk.CURRENT_TIME) != Gdk.GrabStatus.SUCCESS) {

                Gtk.grab_remove(volume_popup);
                volume_popup.hide();
                return false;
            }

            if (Gdk.keyboard_grab(volume_popup.get_window(),
                                 true,
                                 Gdk.CURRENT_TIME) != Gdk.GrabStatus.SUCCESS) {

                volume_popup.get_display().pointer_ungrab(Gdk.CURRENT_TIME);
                Gtk.grab_remove(volume_popup);
                volume_popup.hide();
                return false;
            }

            volume_popup.grab_focus();
            plugin.block_autohide(true);
            active = true;

            return true;
        }

        if (event.button == 2) {
            alsa.mute = !alsa.mute;
            alsa.state_changed();
            return true;
        }

        return false;
    }

    bool on_button_press_event_inactive(Gdk.EventButton event) {
        if (event.button == 1)
            return true;
        return false;
    }

    bool on_scroll_event(Gdk.EventScroll event) {
        if ((event.direction == Gdk.ScrollDirection.UP && alsa.volume != 100) ||
                (event.direction == Gdk.ScrollDirection.DOWN && alsa.volume != 0)) {

            long new_volume = alsa.volume;

            if (event.direction == Gdk.ScrollDirection.UP)
                new_volume += 3;
            else
                new_volume -= 3;

            if (new_volume < 0)
                new_volume = 0;
            else if (new_volume > 100)
                new_volume = 100;

            alsa.volume = new_volume;
            alsa.state_changed();

            return true;
        }

        return false;
    }
}
