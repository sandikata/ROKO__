# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

DESCRIPTION="A Quick Application Launcher"
HOMEPAGE="http://www.ad-comp.be/index.php?category/ADesk-Bar"
SRC_URI="http://www.ad-comp.be/public/projets/ADeskBar/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-lang/python"
RDEPEND="${DEPEND}"

S=${WORKDIR}/${PN}

src_install() {
	cd ${S}
	install -d ${D}/usr/{bin,share/${PN},share/pixmaps,share/applications}
	cp -a src/* ${D}/usr/share/${PN}
	install -m 644 src/images/${PN}.png ${D}/usr/share/pixmaps/
	install -m 644 ${PN}.desktop ${D}/usr/share/applications/
	install -m 755 ${PN}.sh ${D}/usr/bin/${PN}
}
