project(
  'lightpad',
  ['vala', 'c'],
  version: '0.0.8',
  meson_version: '>=0.56.0'
)

PROJECT_NAME = 'lightpad'
prefix = get_option('prefix')
libdir = join_paths(prefix, get_option('libdir'))
datadir = join_paths(prefix, get_option('datadir'))
vapi_dir = join_paths(meson.project_source_root(), 'vapi')

vala = meson.get_compiler('vala')

# Global configuration
conf = configuration_data()
conf.set_quoted('PROJECT_NAME', PROJECT_NAME)
conf.set_quoted('PACKAGE_LIBDIR', libdir)
conf.set_quoted('PACKAGE_SHAREDIR', datadir)

config_h = configure_file(
  output: 'config.h',
  configuration: conf
)

config_dep = declare_dependency(
  sources: config_h
)

config_inc_dir = include_directories('.')

lightpad_vala_args = [
  '--pkg=config',
  '--vapidir=' + vapi_dir,
  '--target-glib=2.38',
]

sources = files(
  'src/Widgets/AppItem.vala',
  'src/Widgets/FolderItem.vala',
  'src/Widgets/Searchbar.vala',
  'src/Widgets/Indicators.vala',
  'src/Widgets/CompositedWindow.vala',
  'src/Application.vala',
  'src/AppManager.vala',
  'src/BackgroundManager.vala',
  'src/GridManager.vala',
  'src/FolderManager.vala',
  'src/FolderPopupWindow.vala',
  'src/LightPadWindow.vala',
  'src/EventHandlers.vala',
  'src/DesktopEntries.vala',
  'src/Utilities.vala',
  'src/Resources.vala',
  'src/Color.vala',
  'src/Config.vala'
)

deps = [
  dependency('gio-unix-2.0', version: '>=2.56.0'),
  dependency('glib-2.0', version: '>=2.56.0'),
  dependency('gtk+-3.0', version: '>=3.22'),
  dependency('gdk-3.0', version: '>=3.22.0'),
  dependency('cairo', version: '>=1.15.0'),
  dependency('pango', version: '>=1.40.0'),
  dependency('gee-0.8', version: '>=0.20.0'),
  dependency('json-glib-1.0', version: '>=1.6.0'),
  dependency('libgnome-menu-3.0', version: '>=3.13.0'),
  meson.get_compiler('c').find_library('m', required: false)
]

executable(
  meson.project_name(),
  sources,
  dependencies: deps,
  c_args: [
    '-DGMENU_I_KNOW_THIS_IS_UNSTABLE', '-w'
  ],
  vala_args: lightpad_vala_args,
  include_directories: config_inc_dir,
  install: true
)

# Install CSS
install_data(
  'data/application.css',
  install_dir: join_paths(datadir, PROJECT_NAME)
)

# Install PNG icons
icon_sizes = ['24', '32', '48', '64', '128']
foreach size : icon_sizes
  install_data(
    join_paths('data', 'icons', 'hicolor', size + 'x' + size, 'apps', 'lightpad.png'),
    install_dir: join_paths(datadir, 'icons', 'hicolor', size + 'x' + size, 'apps')
  )
endforeach

# Install SVG scalable icon
install_data(
  join_paths('data', 'icons', 'hicolor', 'scalable', 'apps', 'lightpad.svg'),
  install_dir: join_paths(datadir, 'icons', 'hicolor', 'scalable', 'apps')
)

# Install .desktop and .appdata.xml files
install_data(
  'data/@0@.desktop'.format(meson.project_name()),
  install_dir: join_paths(datadir, 'applications')
)
install_data(
  'data/@0@.appdata.xml'.format(meson.project_name()),
  install_dir: join_paths(datadir, 'metainfo')
)

# Post-install script
meson.add_install_script('post_install.py')
