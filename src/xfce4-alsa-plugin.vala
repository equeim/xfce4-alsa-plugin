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
    private AlsaManager alsa;

    private class Plugin : Xfce.PanelPlugin {
        public override void @construct() {
            Intl.bindtextdomain(GETTEXT_PACKAGE, LOCALEDIR);
            Intl.textdomain(GETTEXT_PACKAGE);
            Intl.bind_textdomain_codeset(GETTEXT_PACKAGE, "UTF-8");

            alsa = new AlsaManager();

            string device, channel;
            Settings.load(out device, out channel);
            alsa.device = device;
            alsa.channel = channel;

            var button = new VolumeButton(this);
            add(button);
            add_action_widget(button);
            button.show_all();

            menu_show_configure();
            configure_plugin.connect(() => {
                var dialog = new SettingsDialog();  
                dialog.show_all();
            });
        }
    }
}

[ModuleInit]
public Type xfce_panel_module_init(TypeModule module) {
    return typeof (AlsaPlugin.Plugin);
}
