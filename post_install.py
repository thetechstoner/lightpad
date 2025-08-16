#!/usr/bin/env python3

import os
import subprocess
import sys

def main():
    # Get the prefix used for installation (default to /usr if not set)
    prefix = os.environ.get('MESON_INSTALL_PREFIX', '/usr')
    if prefix == '~/.local':
        # Expand user-local prefix
        prefix = os.path.expanduser('~/.local')
    hicolor = os.path.join(prefix, 'share', 'icons', 'hicolor')

    # Only update the icon cache if not installing to a staged root (DESTDIR)
    if not os.environ.get('DESTDIR'):
        print(f'Updating icon cache in: {hicolor}')
        if not os.path.isdir(hicolor):
            print(f"Icon directory not found: {hicolor}")
            sys.exit(0)
        try:
            ret = subprocess.call([
                'gtk-update-icon-cache', '-q', '-t', '-f', hicolor
            ])
            if ret == 0:
                print('Icon cache updated.')
            else:
                print(f'Error updating icon cache (exit code {ret}).')
        except FileNotFoundError:
            print('gtk-update-icon-cache not found. Please install gtk+3 or update icon cache manually.')
    else:
        print('DESTDIR is set, skipping icon cache update.')

if __name__ == '__main__':
    main()
