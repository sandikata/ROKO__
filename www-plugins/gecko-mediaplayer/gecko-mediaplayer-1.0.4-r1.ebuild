# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-plugins/gecko-mediaplayer/gecko-mediaplayer-1.0.4.ebuild,v 1.2 2011/09/13 14:05:38 ssuominen Exp $

EAPI=4
inherit multilib nsplugins

_fxver=6.0

DESCRIPTION="A browser plugin that uses GNOME MPlayer"
HOMEPAGE="http://code.google.com/p/gecko-mediaplayer/"
SRC_URI="http://${PN}.googlecode.com/files/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~ppc ~ppc64 ~x86"
IUSE="curl"

RDEPEND=">=dev-libs/dbus-glib-0.92
	>=dev-libs/glib-2.26:2
	dev-libs/nspr
	>=media-video/gnome-mplayer-1.0.4[dbus]
	|| ( >=www-client/firefox-${_fxver} >=net-libs/xulrunner-1.9.2:1.9 )
	curl? ( net-misc/curl )
	"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	sys-devel/gettext"

DOCS="ChangeLog DOCS/tech/javascript.txt"

src_configure() {
	has_version ">=www-client/firefox-${_fxver}" && export PKG_CONFIG_PATH="${FILESDIR}"

	econf \
		--without-gconf \
		--with-gio \
		--with-plugin-dir=/usr/$(get_libdir)/${PLUGINS_DIR} \
		$(use_with curl libcurl)
}

src_install() {
	default
	rm -rf "${ED}"/usr/share/doc/${PN}
}
