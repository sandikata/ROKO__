# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

DESCRIPTION="Test your system's stability and performance by calculating millions of digits of Pi."
HOMEPAGE="http://systester.sourceforge.net"
SRC_URI="mirror://sourceforge/${PN}/${P}-src.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="qt4"

DEPEND="
	sys-libs/gpm
	qt4? ( dev-qt/qtgui )
"
RDEPEND="${DEPEND}"

S="${WORKDIR}"/"${P}"-src

src_configure() {
	if use qt4; then
		econf || die "configure failed"
	fi
}

src_compile() {
	if use qt4; then
		emake || die "build failed"
	fi
	cd cli
	emake || die "build failed"
}

src_install() {
	if use qt4; then
		fperms 755 systester
		dobin systester || "dobin failed"
	fi
	fperms 755 cli/systester-cli
	dobin cli/systester-cli || "dobin failed"
}
