# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils qmake-utils

DESCRIPTION="App for display info about radeon card"
HOMEPAGE="https://github.com/marazmista/radeon-profile"
SRC_URI="https://github.com/marazmista/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+daemon"

CDEPEND="dev-qt/qtcharts:5
	dev-qt/qtnetwork:5
	dev-qt/qtwidgets:5
	dev-qt/qtprintsupport:5
	x11-libs/libXrandr"
RDEPEND="${CDEPEND}
	x11-apps/mesa-progs
	x11-apps/xdriinfo
	x11-libs/libxkbcommon
	|| (
		x11-drivers/xf86-video-ati
		x11-drivers/xf86-video-amdgpu
	)
	daemon? ( x11-apps/radeon-profile-daemon )"
DEPEND="${CDEPEND}
	dev-qt/linguist-tools:5"

RESTRICT="mirror"

src_configure() {
	cd ${PN} || die
	eqmake5
}

src_compile() {
	emake -C ${PN}
}

src_install() {
	pushd ${PN} >/dev/null || die
	dobin ${PN}

	# Install icons and desktop entry
	newicon "extra/${PN}.png" ${PN}.png
	make_desktop_entry "radeon-profile" "Radeon Profile" "" \
		"System;Monitor;HardwareSettings;" "Terminal=false\nStartupNotify=false"

	popd >/dev/null || die
}
