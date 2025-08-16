![LightPad](https://raw.githubusercontent.com/thetechstoner/lightpad/master/logo.png)

# LightPad

LightPad is a lightweight, simple, and powerful application launcher. It is also Wayland compatible.

Developed for [Twister OS](https://twisteros.com/) and in collaboration with Ubuntu Budgie (and its [BudgieLightpad Applet](https://github.com/ubuntubudgie/budgie-lightpad-applet)), with thanks to [@fossfreedom](https://github.com/fossfreedom).

Originally forked from Slingshot by the elementary team:  
[https://launchpad.net/slingshot](https://launchpad.net/slingshot)

---

## Screenshot

![Screenshot](https://raw.githubusercontent.com/thetechstoner/lightpad/master/screenshot.png)

---

## Features

- Lightweight and fast GTK+ 3 application launcher
- Wayland compatible
- Custom dynamic backgrounds (JPG/PNG)
- Application blacklist support
- Alphabetical app sorting
- Configurable grid and appearance
- Easy packaging for Arch (PKGBUILD) and Fedora (RPM)
- Open source (GPL-3.0-or-later)

---

## Installation

### 1. Install Dependencies

**Ubuntu:**
sudo apt-get install meson ninja-build libgee-0.8-dev libgnome-menu-3-dev valac libglib2.0-dev libwnck-3-dev libgtk-3-dev xterm python3 python3-wheel python3-setuptools gnome-menus libjson-glib-dev libcairo2-dev

**Fedora:**
sudo dnf install meson ninja-build libgee-devel gnome-menus-devel vala-devel glib2-devel libwnck3-devel gtk3-devel xterm python3 python3-wheel python3-setuptools gnome-menus json-glib-devel cairo-devel

**Arch Linux:**
sudo pacman -Sy meson ninja libgee gnome-menus vala glib2 gdk-pixbuf2 libwnck3 gtk3 xterm python python-wheel python-setuptools json-glib cairo

### 2. Clone and Build

git clone https://github.com/thetechstoner/lightpad.git
cd lightpad/
meson setup build --prefix=/usr
cd build
ninja

### 3. Install

sudo ninja install

### 4. (Optional) Uninstall

sudo ninja uninstall

---

## Post Install

Set a shortcut key to launch LightPad:

- Go to **System → Preferences → Hardware → Keyboard Shortcuts** and click **Add**
- **Name:** LightPad  
- **Command:** lightpad

Assign a shortcut key, such as `Ctrl+Space`.

**Note:**  
Some icon themes may lack the `application-default-icon`. Download it from [elementary_os/icons](https://github.com/elementary/icons/blob/master/apps/128/application-default-icon.svg) and run:
sudo cp application-default-icon.svg /usr/share/icons/hicolor/scalable/apps/
sudo gtk-update-icon-cache /usr/share/icons/hicolor

---

## Dynamic Background (Optional)

You can set a custom background image by placing it at:

- `$HOME/.lightpad/background.jpg`
- `$HOME/.lightpad/background.png`

JPG is prioritized if both exist.

---

## Blacklist File (Optional)

Hide applications by listing their binary names (as found in the `Exec=` line of their `.desktop` files) in:

- `$HOME/.lightpad/blacklist`

Example:
nautilus
rhythmbox
gnome-screenshot
gnome-terminal
firefox
htop
/usr/bin/gparted
/usr/bin/vlc

---

## Changelog

**Version 0.0.9**
- Fixed [issue #26](https://github.com/libredeb/lightpad/issues/26): opens in wrong monitor
- Fixed [issue #28](https://github.com/libredeb/lightpad/issues/28): can't run GNOME apps
- Fixed [issue #23](https://github.com/libredeb/lightpad/issues/23): can't exit by clicking on empty area
- Release in progress...

**Version 0.0.8**
- Arch Linux (PKG) and Fedora (RPM) packaging templates added
- Config files introduced for project constants (no more hardcoded paths)
- CSS and code cleanup
- App blacklist feature added
- Background file paths moved to `$HOME/.lightpad/`

**Version 0.0.7**
- Page indicators changed to dots, removed animations
- Searchbar CSS fixed for all screens
- Dynamic background image support
- Apps sorted alphabetically
- Added SPEC and PKGBUILD packaging
- Bug fixes

**Version 0.0.5**
- Standardized terminal app launching
- Improved postinstall script
- Removed DE detection for terminal
- Added xterm as dependency

**Version 0.0.4**
- Fixed page indicator sizing bug
- Improved page indicator and searchbar appearance

**Version 0.0.3**
- Fixed negative array index bug
- LXQT, LXDE, XFCE terminal support
- Searchbar uses CSS

**Version 0.0.2**
- Added dependency versioning
- Fixed gee assertion bug
- Fixed terminal app launching bug
- Improved netbook screen detection

**Version 0.0.1**
- Code cleanup from fork
- Improved searchbar design
- New icon in multiple resolutions
- Fixed icon fallback bug
- Terminal app support

---

## License

GPL-3.0-or-later

---

For more details, see the [source code](https://github.com/thetechstoner/lightpad).
