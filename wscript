_package_name = "xfce4-alsa-plugin"


def options(context):
    context.load("compiler_c gnu_dirs vala")


def configure(context):
    context.load("compiler_c gnu_dirs intltool vala")

    context.check_cfg(package="alsa", args="--libs --cflags")
    context.check_cfg(package="gdk-2.0", args="--libs --cflags")
    context.check_cfg(package="gtk+-2.0", args="--libs --cflags")
    context.check_cfg(package="libxfce4panel-1.0", args="--libs --cflags")

    context.define("PACKAGE_NAME", _package_name)
    context.define("GETTEXT_PACKAGE", _package_name)
    context.define("LOCALEDIR", context.env.LOCALEDIR)
    context.write_config_header("config.h", remove=False)


def build(context):
    context.shlib(
        target="alsa",
        packages=[
            "alsa",
            "config",
            "gdk-2.0",
            "gdkkeysyms-2.0",
            "gtk+-2.0",
            "libxfce4panel-1.0"
        ],
        vapi_dirs="src/vapi",
        uselib="ALSA GDK-2.0 GTK+-2.0 LIBXFCE4PANEL-1.0",
        source=[
            "src/alsamanager.vala",
            "src/settings.vala",
            "src/settingsdialog.vala",
            "src/volumebutton.vala",
            "src/volumepopup.vala",
            "src/xfce4-alsa-plugin.vala"
        ],
        install_binding=False,
        install_path="{}/xfce4/panel/plugins".format(context.env.LIBDIR)
    )

    context(
        appname=_package_name,
        features="intltool_po",
        podir="po"
    )

    context(
        features="intltool_in",
        podir="po",
        style="desktop",
        source="alsa.desktop.in",
        target="alsa.desktop",
        install_path="{}/xfce4/panel/plugins".format(context.env.DATADIR)
    )
