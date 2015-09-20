def options(context):
    context.load("compiler_c gnu_dirs vala")


def configure(context):
    context.load("compiler_c gnu_dirs intltool vala")

    context.check_cfg(package="alsa", args="--libs --cflags")
    context.check_cfg(package="libxfce4panel-1.0", args="--libs --cflags")

    context.define("GETTEXT_PACKAGE", "xfce4-alsa-plugin")
    context.define("LOCALEDIR", context.env.LOCALEDIR)
    context.write_config_header("config.h", remove=False)


def build(context):
    context.shlib(
        target="alsa",
        packages="alsa config gdkkeysyms-2.0 libxfce4panel-1.0",
        vapi_dirs="src/vapi",
        uselib="ALSA LIBXFCE4PANEL-1.0",
        source=[
            "src/alsamanager.vala",
            "src/pluginsettings.vala",
            "src/settingswindow.vala",
            "src/volumebutton.vala",
            "src/volumepopup.vala",
            "src/xfce4-alsa-plugin.vala"
        ],
        install_binding=False,
        install_path=context.env.LIBDIR + "/xfce4/panel/plugins"
    )

    context(
        appname="xfce4-alsa-plugin",
        features="intltool_po",
        podir="po"
    )

    context(
        features="intltool_in",
        podir="po",
        style="desktop",
        source="alsa.desktop.in",
        target="alsa.desktop",
        install_path=context.env.DATADIR + "/xfce4/panel/plugins",
    )
