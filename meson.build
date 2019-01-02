project('xfce4-alsa-plugin', 'vala', 'c', meson_version : '>= 0.37.0')

i18n = import('i18n')

vapi_dir = join_paths(meson.current_source_dir(), 'src/vapi')

add_project_arguments('--vapidir', vapi_dir, language : 'vala')
add_project_arguments('-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()), language : 'c')
add_project_arguments('-DPACKAGE_NAME="@0@"'.format(meson.project_name()), language : 'c')
add_project_arguments('-DLOCALEDIR="@0@"'.format(join_paths(get_option('prefix'), get_option('localedir'))), language : 'c')

conf_data = configuration_data()

dependencies = [dependency('alsa'),
                meson.get_compiler('vala').find_library('gdkkeysyms-2.0', dirs : vapi_dir),
                meson.get_compiler('vala').find_library('config', dirs : vapi_dir)]

if get_option('gtk3')
    conf_data.set('api_version', '2.0')
    dependencies += [dependency('libxfce4panel-2.0', version : '>= 4.13.0'),
                     dependency('gtk+-3.0', version : '>= 3.20.0')]
    add_project_arguments('--define=GTK3', language : 'vala')
    add_project_arguments('--define=XFCE4_13', language : 'vala')
else
    conf_data.set('api_version', '1.0')
    xfce4panel = dependency('libxfce4panel-1.0')
    dependencies += xfce4panel
    if xfce4panel.version().version_compare('>= 4.13.0')
        add_project_arguments('--define=XFCE4_13', language : 'vala')
    endif
endif

configure_file(input : 'alsa.desktop.in.in',
               output : 'alsa.desktop.in',
               configuration : conf_data)

shared_library('alsa',
               sources : ['src/alsamanager.vala',
                          'src/settings.vala',
                          'src/settingsdialog.vala',
                          'src/volumebutton.vala',
                          'src/volumepopup.vala',
                          'src/xfce4-alsa-plugin.vala'],
               dependencies : dependencies,
               install_dir : join_paths(get_option('libdir'), 'xfce4/panel/plugins'),
               install : true)

i18n.merge_file(input : join_paths(meson.current_build_dir(), 'alsa.desktop.in'),
                output : 'alsa.desktop',
                type : 'desktop',
                po_dir : 'po',
                install_dir : join_paths(get_option('datadir'), 'xfce4/panel/plugins'),
                install : true)

subdir('po')
