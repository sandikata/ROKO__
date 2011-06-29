# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit gnome2-utils

DESCRIPTION="Ubuntu One helps you store, sync and share stuff."
HOMEPAGE="https://launchpad.net/ubuntuone-client"
SRC_URI="http://launchpad.net/${PN}/trunk/${PV}/+download/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-libs/dbus-glib
	gnome-base/nautilus
	virtual/python"
RDEPEND="${DEPEND}
	dev-python/configglue
	dev-python/dbus-python
	dev-python/gnome-keyring-python
	dev-python/httplib2
	dev-python/notify-python
	>=dev-python/oauth-1.0
	>=dev-python/pygtk-2.10
	dev-python/pyinotify
	dev-python/pyxdg
	dev-python/simplejson
	dev-python/twisted-names
	dev-python/twisted-web
	>=dev-python/ubuntuone-storage-protocol-1.1.3
	x11-misc/xdg-utils"

RESTRICT="primaryuri"

src_install() {
	emake DESTDIR="${D}" install || die "Install failed"

	# Delete some files that are only useful on Ubuntu
	rm -rf "${D}"etc/apport "${D}"usr/share/apport

	dodoc README || die
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
