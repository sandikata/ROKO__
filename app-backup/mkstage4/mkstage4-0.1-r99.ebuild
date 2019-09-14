# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit eutils
DESCRIPTION="A fork of Bash Utility for Creating Stage 4 Tarballs with pbzip2 support"
HOMEPAGE="https://github.com/TheChymera/mkstage4"
SRC_URI="https://github.com/TheChymera/mkstage4/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="pbzip2"

DEPEND=""
RDEPEND="app-shells/bash
	app-arch/tar
	pbzip2? ( app-arch/pbzip2 )"

src_configure() {
	epatch "${FILESDIR}"/mkstage4.patch
}

src_install() {
	newbin mkstage4.sh mkstage4
}
