# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

DESCRIPTION="inhatch plugin for vlc player
HOMEPAGE="http://inhatch.com/
#SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND=">=media-video/vlc-1.1.10"
RDEPEND="${DEPEND}"

src_unpack() {
	cd ${FILESDIR}/
	unpack inhatch-0.8-amd64.tar.bz2 || die
}

src_install() {
	cd ${WORKDIR}
	cp -rva * / || die
	ldconfig
}


