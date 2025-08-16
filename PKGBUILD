pkgname=lightpad
pkgver=0.0.8
pkgrel=1
pkgdesc="Lightweight, simple and powerful application launcher"
arch=('x86_64')
url="https://github.com/thetechstoner/lightpad"
license=('GPL3')
depends=(
  'libgee>=0.20.0'
  'gnome-menus>=3.13.0'
  'libwnck3>=3.20.0'
  'glib2>=2.50.0'
  'glibc>=2.28'
  'gtk3>=3.22.0'
  'cairo>=1.15.0'
  'gdk-pixbuf2>=2.36.0'
  'xterm'
  'json-glib>=1.6.0'
)
makedepends=(
  'meson'
  'ninja'
  'vala>=0.56.0'
)
source=(
  "$url/archive/refs/tags/v$pkgver.tar.gz"
)
sha256sums=(
  'SKIP'
)

prepare() {
  cd "$srcdir/$pkgname-$pkgver"
  rm -rf build
}

build() {
  cd "$srcdir/$pkgname-$pkgver"
  meson setup build --prefix=/usr
  meson compile -C build
}

package() {
  cd "$srcdir/$pkgname-$pkgver"
  DESTDIR="$pkgdir" meson install -C build
}
