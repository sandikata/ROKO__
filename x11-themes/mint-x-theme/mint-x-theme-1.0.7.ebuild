# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: 

EAPI="4"

DESCRIPTION="Mint-X GTK themes"
HOMEPAGE="http://packages.linuxmint.com/pool/main/m/mint-x-theme/"
SRC_URI="http://packages.linuxmint.com/pool/main/m/${PN}/${PN}_${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="x11-themes/gtk-engines-murrine
		 x11-themes/mint-x-icons"

DEPEND="${RDEPEND}"

RESTRICT="binchecks strip"

S=${WORKDIR}

src_install() {
	insinto /usr/share/themes
	doins -r mint-x-theme/usr/share/themes/Mint-X{,-Metal}
	dodoc mint-x-theme/debian/changelog  mint-x-theme/debian/copyright
}
