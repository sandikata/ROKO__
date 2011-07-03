# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit gnome2 eutils

DESCRIPTION="Gnaughty is a frontend to the movies section of sublimedirectory.com (aka porn downloader)"
HOMEPAGE="http://gnaughty.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="nls"

RDEPEND=">=net-misc/curl-7.10
	>=x11-libs/gtk+-2.2
	>=dev-libs/glib-2
	dev-libs/libpcre"
DEPEND="${RDEPEND}
	sys-devel/gettext"

src_unpack() {
	unpack "${A}"
	cd "${S}"
	epatch ${FILESDIR}/${P}-gconf.patch
}

src_compile() {
	econf $(use_enable nls) || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install"
	dodoc AUTHORS ChangeLog NEWS README || die "dodoc failed"
}
