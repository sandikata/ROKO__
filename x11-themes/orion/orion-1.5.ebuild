# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"

DESCRIPTION="Theme for GTK 2, GTK 3, Metacity, Openbox and Xfwm4"
HOMEPAGE="https://github.com/shimmerproject/Orion"
SRC_URI="https://github.com/shimmerproject/${PN^}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

S="${WORKDIR}"/${PN^}-${PV}

src_install() {
	insinto /usr/share/themes/${PN^}
	doins -r .
}
