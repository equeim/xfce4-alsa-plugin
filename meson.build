project('xfce4-alsa-plugin', 'vala', 'c', meson_version : '>= 0.37.0')

i18n = import('i18n')

vapi_dir = join_paths(meson.current_source_dir(), 'src/vapi')

add_project_arguments('--vapidir', vapi_dir, language : 'vala')
add_project_arguments('-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()), language : 'c')
add_project_arguments('-DPACKAGE_NAME="@0@"'.format(meson.project_name()), language : 'c')
add_project_arguments('-DLOCALEDIR="@0@"'.format(join_paths(get_option('prefix'), get_option('localedir'))), language : 'c')

# Suppress GCC warning about unused variables in generated code
add_project_arguments('-Wno-unused-variable', language: 'c')
add_project_arguments('-Wno-unused-value', language: 'c')
add_project_arguments('-Wno-unused-but-set-variable', language: 'c')

libxfce4panel_dep = dependency('libxfce4panel-2.0', version : '>= 4.13.0')
message(libxfce4panel_dep.version())
if libxfce4panel_dep.version().version_compare('>= 4.19.0')
    add_project_arguments('--define=XFCE_420', language : 'vala')
endif

dependencies = [dependency('alsa'),
                dependency('gtk+-3.0', version : '>= 3.20.0'),
                libxfce4panel_dep,
                meson.get_compiler('vala').find_library('config', dirs : vapi_dir)]

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

i18n.merge_file(input : 'alsa.desktop.in',
                output : 'alsa.desktop',
                type : 'desktop',
                po_dir : 'po',
                install_dir : join_paths(get_option('datadir'), 'xfce4/panel/plugins'),
                install : true)

subdir('po')
