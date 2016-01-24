# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

DESCRIPTION=""
HOMEPAGE=""
SRC_URI="http://launchpadlibrarian.net/166585709/python-m2crypto_0.21.1-3ubuntu5_amd64.deb"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

S="${WORKDIR}"

src_prepare(){
	unpack ${A}
	unpack ./data.tar.xz
}

src_install(){
	cp -R usr "${D}"
}

