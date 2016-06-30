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
    private class VolumePopup : Gtk.Window {
        private Plugin plugin;

        public VolumePopup(Plugin plugin) {
            Object(type: Gtk.WindowType.POPUP);
            this.plugin = plugin;

            var frame = new Gtk.Frame(null);
            frame.shadow_type = Gtk.ShadowType.OUT;
            add(frame);

            var scale_container = new Gtk.VBox(false, 0);
            scale_container.border_width = 2;
            frame.add(scale_container);

            var scale = new Gtk.VScale.with_range(0.0, 100.0, 3.0);
            scale.draw_value = false;
            scale.inverted = true;
            scale.set_size_request(-1, 128);
            scale.set_value(alsa.volume);

            scale.change_value.connect((scroll, new_value) => {
                alsa.volume = (long) new_value;
                return false;
            });

            alsa.state_changed.connect(() => {
                scale.set_value(alsa.volume);
            });

            scale_container.add(scale);

            show.connect(on_show);
            hide.connect(on_hide);
            button_press_event.connect(on_button_press_event);
            grab_broken_event.connect(on_grab_broken_event);
            grab_notify.connect(on_grab_notify);
            key_release_event.connect(on_key_release_event);
        }

        private void on_show() {
            Gtk.grab_add(this);
        
            if (Gdk.pointer_grab(get_window(),
                                 true,
                                 Gdk.EventMask.BUTTON_PRESS_MASK |
                                 Gdk.EventMask.BUTTON_RELEASE_MASK |
                                 Gdk.EventMask.POINTER_MOTION_MASK,
                                 null,
                                 null,
                                 Gdk.CURRENT_TIME) != Gdk.GrabStatus.SUCCESS) {

                Gtk.grab_remove(this);
                hide();
                return;
            }

            if (Gdk.keyboard_grab(get_window(),
                                 true,
                                 Gdk.CURRENT_TIME) != Gdk.GrabStatus.SUCCESS) {

                get_display().pointer_ungrab(Gdk.CURRENT_TIME);
                Gtk.grab_remove(this);
                hide();
                return;
            }

            grab_focus();
            plugin.block_autohide(true);
        }

        private void on_hide() {
            Gdk.Display display = get_display();
            display.keyboard_ungrab(Gdk.CURRENT_TIME);
            display.pointer_ungrab(Gdk.CURRENT_TIME);
            Gtk.grab_remove(this);
            plugin.block_autohide(false);
        }

        private bool on_button_press_event(Gdk.EventButton event) {
            if (event.type == Gdk.EventType.BUTTON_PRESS) {
                hide();
                return true;
            }
            return false;
        }

        private bool on_grab_broken_event() {
            if (has_grab() && !Gtk.grab_get_current().is_ancestor(this)) {
                hide();
                return true;
            }
            return false;
        }

        private void on_grab_notify(bool was_grabbed) {
            if (!was_grabbed && has_grab() && !Gtk.grab_get_current().is_ancestor(this)) {
                hide();
            }
        }

        private bool on_key_release_event(Gdk.EventKey event) {
            if (event.keyval == Gdk.KeySyms.Escape) {
                hide();
                return true;
            }
            return false; 
        }
    }
}
