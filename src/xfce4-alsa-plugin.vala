// SPDX-FileCopyrightText: 2015-2024 Alexey Rochev
//
// SPDX-License-Identifier: GPL-3.0-or-later

namespace AlsaPlugin {
    private AlsaManager alsa;

    private class Plugin : Xfce.PanelPlugin {
        internal double volume_step { get; set; }

        public override void @construct() {
            Intl.bindtextdomain(GETTEXT_PACKAGE, LOCALEDIR);
            Intl.textdomain(GETTEXT_PACKAGE);
            Intl.bind_textdomain_codeset(GETTEXT_PACKAGE, "UTF-8");

            alsa = new AlsaManager();

            string device, channel;
            double step;
            Settings.load(out device, out channel, out step);
            volume_step = step;
            alsa.device = device;
            alsa.channel = channel;

            var button = new VolumeButton(this);
            add(button);
            add_action_widget(button);
            button.show_all();

            menu_show_configure();
            configure_plugin.connect(() => {
                var dialog = new SettingsDialog(this);
                dialog.show_all();
            });
        }
    }
}

[ModuleInit]
public Type xfce_panel_module_init(TypeModule module) {
    return typeof (AlsaPlugin.Plugin);
}
