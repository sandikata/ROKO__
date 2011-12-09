# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

DESCRIPTION="inhatch plugin for vlc player"
HOMEPAGE="http://inhatch.com/"
SRC_URI="http://199.91.153.209/lcfltm089v1g/3oxkqy78kioeayv/inhatch-0.8-1-amd64.tar.bz2"

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

echo
}
