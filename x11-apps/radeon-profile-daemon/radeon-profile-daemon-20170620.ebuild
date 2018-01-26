# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit qmake-utils systemd

DESCRIPTION="Daemon for radeon-profile GUI"
HOMEPAGE="https://github.com/marazmista/radeon-profile-daemon"
SRC_URI="https://github.com/marazmista/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="x11-apps/radeon-profile"

RESTRICT="mirror"

src_configure() {
	cd ${PN} || die
	eqmake5
}

src_compile() {
	emake -C ${PN}
}

src_install(){
	dosbin ${PN}/${PN}

	newinitd "${FILESDIR}"/${PN}.initd ${PN}
	systemd_dounit "${FILESDIR}"/${PN}.service
}
