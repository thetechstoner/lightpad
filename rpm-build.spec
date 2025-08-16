Name:           lightpad
Version:        0.0.8
Release:        1%{?dist}
Summary:        Lightweight, simple and powerful application launcher

License:        GPL-3.0-or-later
URL:            https://github.com/thetechstoner/lightpad
Source0:        %{name}-%{version}.tar.gz

BuildRequires:  meson
BuildRequires:  ninja-build
BuildRequires:  vala
BuildRequires:  libgee-devel >= 0.20.0
BuildRequires:  gnome-menus-devel >= 3.13.0
BuildRequires:  libwnck3-devel >= 3.20.0
BuildRequires:  glib2-devel >= 2.50.0
BuildRequires:  gtk3-devel >= 3.22.0
BuildRequires:  cairo-devel >= 1.15.0
BuildRequires:  gdk-pixbuf2-devel >= 2.36.0
BuildRequires:  json-glib-devel >= 1.6.0
BuildRequires:  python3

Requires:       glibc
Requires:       cairo
Requires:       gdk-pixbuf2
Requires:       libgee
Requires:       glib2
Requires:       gnome-menus
Requires:       gtk3
Requires:       libwnck3
Requires:       xterm
Requires:       json-glib

%description
LightPad is a lightweight, simple and powerful application launcher.
Written in GTK+ 3.0. It is also Wayland compatible.

%prep
%autosetup

%build
%meson
%meson_build

%install
%meson_install

%files
%license LICENSE
%doc README.md
%{_bindir}/lightpad
%{_datadir}/applications/lightpad.desktop
%{_datadir}/icons/hicolor/24x24/apps/lightpad.png
%{_datadir}/icons/hicolor/32x32/apps/lightpad.png
%{_datadir}/icons/hicolor/48x48/apps/lightpad.png
%{_datadir}/icons/hicolor/64x64/apps/lightpad.png
%{_datadir}/icons/hicolor/128x128/apps/lightpad.png
%{_datadir}/icons/hicolor/scalable/apps/lightpad.svg
%{_datadir}/lightpad/application.css
%{_datadir}/metainfo/lightpad.appdata.xml

%changelog
- Update to 0.0.8
- Modernize spec for Meson, dependencies, and file list
