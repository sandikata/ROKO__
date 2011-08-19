# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

inherit autotools eutils

DESCRIPTION="A drop down, quake-like terminal emulator"
HOMEPAGE="http://stjerm-terminal.googlecode.com/files/"
SRC_URI="http://stjerm-terminal.googlecode.com/files/${P}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="amd64 x86"
SLOT="0"
IUSE=""

DEPEND="x11-libs/vte
	dev-util/pkgconfig
	>x11-libs/gtk+-2.6"

src_unpack() {
	unpack ${A} ; cd ${S}
	eaclocal  || die "aclocal failed"
	eautoheader || die "autoheader failed"
	eautoconf || die "autoconf faild"
	eautomake || die "automake failed"

}

src_compile() {
	econf --prefix=/usr/ || die "configure faild"
	emake || die "make failed"
}


src_install() {
	make DESTDIR="${D}" install || die "make install failed"
}
