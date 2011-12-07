# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

DESCRIPTION="inhatch plugin for vlc player
HOMEPAGE="http://inhatch.com/
SRC_URI="http://download721.mediafire.com/c6uim5mlorvg/h53m0qn63a030wa/inhatch-0.8-amd64.tar.bz2"

LICENSE=""
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND=">=media-video/vlc-1.1.10"
RDEPEND="${DEPEND}"

src_unpack() {
	unpack $A || die
}

pkg_postinst() {
	cd ${WORKDIR}
	cp -r * / || die
	ldconfig
}
