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

AlsaManager alsa;

public class AlsaPlugin : Xfce.PanelPlugin {
    PluginSettings plugin_settings;
    VolumeButton volume_button;

    public override void @construct() {
        Intl.bindtextdomain(GETTEXT_PACKAGE, LOCALEDIR);
        Intl.textdomain(GETTEXT_PACKAGE);
        Intl.bind_textdomain_codeset(GETTEXT_PACKAGE, "UTF-8");

        alsa = new AlsaManager();
        plugin_settings = new PluginSettings();

        bool active = true;
        try {
            alsa.set_device(plugin_settings.get_alsa_device_id());
            alsa.set_channel(plugin_settings.get_alsa_channel());
        } catch (AlsaError error) {
            active = false;
            GLib.stderr.printf("%s\n", error.message);
        }

        volume_button = new VolumeButton(this, active);
        add(volume_button);
        add_action_widget(volume_button);
        volume_button.show_all();

        configure_plugin.connect(show_settings);
        menu_show_configure();
    }

    void show_settings() {
        SettingsWindow settings_window = new SettingsWindow(volume_button, plugin_settings);
        settings_window.show_all();
    }
}

[ModuleInit]
public GLib.Type xfce_panel_module_init(GLib.TypeModule module) {
    return typeof (AlsaPlugin);
}
