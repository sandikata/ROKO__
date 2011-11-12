# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="3"

inherit eutils distutils flag-o-matic

DESCRIPTION="A GTK-based BitTorrent client by Dmitry Konishchev"
HOMEPAGE="http://sourceforge.net/projects/flush/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~ppc"
IUSE=""

DEPEND=">=x11-libs/gtk+-2.16.6
	>=dev-cpp/gtkmm-2.16.0
	>=dev-cpp/glibmm-2.20.1	
	>=dev-cpp/libglademm-2.6.7
	>=x11-libs/libnotify-0.4.5
	
	>=sys-devel/gettext-0.17
	>=dev-libs/libconfig-1.3.2
	>=dev-libs/boost-1.35.0
	>=sys-apps/dbus-1.2.3
	
	>=net-libs/rb_libtorrent-0.14.8"
RDEPEND="${DEPEND}"

src_configure() {
	econf --disable-bundle-package \
			--enable-system-libconfig \
			--enable-system-libtorrent
}

src_compile() {
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc COPYING ChangeLog

	# Fix icon if using different icon theme in GNOME
	insinto /usr/share/pixmaps
	doins ./icons/hicolor/72x72/apps/flush.png

	ewarn
	ewarn There seems to be some incompability with older version
	ewarn configuration files. If Flush seems to be unstable or 
	ewarn too slow you can fix this with 'rm -rf ~/.flush'.
	ewarn
	ewarn WARNING: This will remove all your loaded torrent files.
	ewarn
}
