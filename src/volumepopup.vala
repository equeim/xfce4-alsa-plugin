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

public class VolumePopup : Gtk.Window {
    Xfce.PanelPlugin plugin;
    VolumeButton volume_button;
    Gtk.VScale volume_scale;

    public VolumePopup(Xfce.PanelPlugin plugin, VolumeButton volume_button, bool active) {
        GLib.Object(type: Gtk.WindowType.POPUP);

        this.plugin = plugin;
        this.volume_button = volume_button;

        Gtk.Frame popup_frame = new Gtk.Frame(null);
        add(popup_frame);
        popup_frame.shadow_type = Gtk.ShadowType.OUT;

        Gtk.VBox scale_container = new Gtk.VBox(false, 0);
        popup_frame.add(scale_container);
        scale_container.border_width = 2;

        volume_scale = new Gtk.VScale.with_range(0.0, 100.0, 3.0);
        scale_container.add(volume_scale);
        volume_scale.draw_value = false;
        volume_scale.inverted = true;
        volume_scale.set_size_request(-1, 128);

        button_press_event.connect(on_button_press_event);
        grab_broken_event.connect(on_grab_broken_event);
        grab_notify.connect(on_grab_notify);
        key_release_event.connect(on_key_release_event);

        volume_scale.change_value.connect(on_volume_scale_change_value);
        alsa.state_changed.connect(update_scale);

        if (active)
            update_scale();
    }

    public void update_scale() {
        volume_scale.set_value((double) alsa.volume);
    }

    bool on_button_press_event(Gdk.EventButton event) {
        if (event.type == Gdk.EventType.BUTTON_PRESS) {
            hide_popup();
            return true;
        }
        return false;
    }

    bool on_grab_broken_event() {
        if (has_grab() && !Gtk.grab_get_current().is_ancestor(this))
            hide_popup();
        return false;
    }

    void on_grab_notify(bool was_grabbed) {
        if (!was_grabbed && has_grab() && !Gtk.grab_get_current().is_ancestor(this))
            hide_popup();
    }

    bool on_key_release_event(Gdk.EventKey event) {
        if (event.keyval == Gdk.KeySyms.Escape) {
            hide_popup();
            return true;
        }
        return false; 
    }

    bool on_volume_scale_change_value(Gtk.ScrollType scroll, double new_value) {
        if (new_value < 0.0)
            new_value = 0.0;
        else if (new_value > 100.0)
            new_value = 100.0;

        if (volume_scale.get_value() != new_value) {
            alsa.volume = (long) new_value;
            volume_button.update_button();
        }

        return false;
    }

    void hide_popup() {
        Gdk.Display display = get_display();
        display.keyboard_ungrab(Gdk.CURRENT_TIME);
        display.pointer_ungrab(Gdk.CURRENT_TIME);
        Gtk.grab_remove(this);
        plugin.block_autohide(false);
        volume_button.active = false;
        hide();
    }
}

