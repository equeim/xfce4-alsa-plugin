// SPDX-FileCopyrightText: 2015-2024 Alexey Rochev
//
// SPDX-License-Identifier: GPL-3.0-or-later

namespace AlsaPlugin {
    private class VolumePopup : Gtk.Window {
        private Plugin plugin;
        private Gtk.Box scale_container;
        private Gtk.Scale scale;
#if !XFCE_420
        private Gdk.Seat seat = null;
#endif

        public VolumePopup(Plugin plugin) {
#if XFCE_420
            Object(type: Gtk.WindowType.TOPLEVEL);
#else
            Object(type: Gtk.WindowType.POPUP);
#endif
            this.plugin = plugin;

            var frame = new Gtk.Frame(null);
            frame.shadow_type = Gtk.ShadowType.OUT;
            add(frame);

            scale_container = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            scale_container.border_width = 2;
            scale_container.button_press_event.connect(() => { return true; });
            frame.add(scale_container);

            setup_scale();

            frame.show_all();

            alsa.state_changed.connect(() => {
                scale.set_value(alsa.volume);
            });

            plugin.notify["volume-step"].connect((s, p) => {
                reset_scale();
            });

#if !XFCE_420
            show.connect(on_show);
            hide.connect(on_hide);
            button_press_event.connect(on_button_press_event);
            grab_broken_event.connect(on_grab_broken_event);
            grab_notify.connect(on_grab_notify);
            key_release_event.connect(on_key_release_event);
#endif
        }

        private void setup_scale() {
            scale = new Gtk.Scale.with_range(Gtk.Orientation.VERTICAL, 0.0, 100.0, plugin.volume_step);
            scale.draw_value = false;
            scale.inverted = true;
            scale.set_size_request(-1, 128);
            scale.set_value(alsa.volume);

            scale.change_value.connect((scroll, new_value) => {
                alsa.volume = (long) new_value;
                return false;
            });

            scale_container.add(scale);
        }

        private void reset_scale() {
            scale_container.remove(scale);
            scale = null;
            setup_scale();
            scale.show();
        }

#if !XFCE_420
        private void on_show() {
            if (seat != null) {
                seat.ungrab();
                plugin.block_autohide(false);
            }
            seat = null;
            var device = Gtk.get_current_event_device();
            if (device == null) {
                seat = get_display().get_default_seat();
            } else {
                seat = device.seat;
            }

            if (seat.grab(get_window(),
                          Gdk.SeatCapabilities.ALL,
                          true,
                          null,
                          null,
                          null) != Gdk.GrabStatus.SUCCESS) {
                seat = null;
                hide();
                return;
            }
            plugin.block_autohide(true);
        }

        private void on_hide() {
            if (seat != null) {
                seat.ungrab();
                seat = null;
            }
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
            if (event.keyval == Gdk.Key.Escape) {
                hide();
                return true;
            }
            return false; 
        }
#endif
    }
}
