# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit gnome2 eutils

DESCRIPTION="Online comic strip browser for GNOME"
HOMEPAGE="http://buoh.steve-o.org/"
SRC_URI="http://buoh.steve-o.org/downloads/${P}.tar.bz2"

IUSE=""
LICENSE="GPL-2"
KEYWORDS="x86 amd64"
EAPI="1"
SLOT="0"

RDEPEND=">=x11-libs/gtk+-2.8
	>=gnome-base/gconf-2.2
	>=gnome-base/libgnomeui-2.6
	net-libs/libsoup:2.4
	x11-libs/pango"

DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.12.0
	>=dev-util/intltool-0.29
	>=sys-devel/gettext-0.10.40"

src_unpack() {
		unpack "${A}"
		cd "${S}"

		epatch ${FILESDIR}/buoh-libsoup24.patch
}

DOCS="AUTHORS ChangeLog NEWS README TODO"
USE_DESTDIR=1
