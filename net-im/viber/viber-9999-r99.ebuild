# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
inherit eutils

DESCRIPTION="Free calls, text and picture sharing with anyone, anywhere!"
HOMEPAGE="http://www.viber.com"
SRC_URI="http://download.cdn.viber.com/cdn/desktop/Linux/viber.deb"

SLOT="0"
KEYWORDS=""
IUSE=""

RESTRICT="strip"
INSTALL_DIR="/opt"
S="${WORKDIR}"

src_unpack() {
	default_src_unpack
	unpack ./data.tar.gz
}

src_prepare() {
	epatch "${FILESDIR}"/viber.patch
}

src_install(){
	doins -r "${S}"/opt "${S}"/usr
# for creating launcher.db from user.
	fperms 777 ${INSTALL_DIR}/${PN}
#
	fperms 755 ${INSTALL_DIR}/${PN}/Viber
}

pkg_prerm(){
	[[ -e "${ROOT}usr/share/${PN}/launcher.db" ]] && rm -rf "${ROOT}usr/share/${PN}/launcher.db"
}
