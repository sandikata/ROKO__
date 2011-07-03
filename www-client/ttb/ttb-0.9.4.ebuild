# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

DESCRIPTION="A browser for NOS Teletekst, a Dutch teletext service."
HOMEPAGE="http://www.djcbsoftware.nl/code/ttb/"
SRC_URI="${HOMEPAGE}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE=""

DEPEND=">=dev-lang/python-2.2.0"
RDEPEND="dev-python/pygtk
	gnome-base/libglade"

src_install() {
	exeinto /usr/bin
	doexe src/ttb
	
	insinto /usr/share/applications
	doins ttb.desktop
	
	insinto /usr/share/pixmaps
	doins images/ttb.png
	
	insinto /usr/share/ttb
	doins glade/ttb.glade
}
