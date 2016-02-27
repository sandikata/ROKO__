# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

DESCRIPTION=""
HOMEPAGE="http://messengerfordesktop.com/"
SRC_URI="https://github.com/Aluxian/Facebook-Messenger-Desktop/releases/download/v1.4.3/Messenger_linux64.deb"

LICENSE=""
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

S=${WORKDIR}
src_prepare(){
	unpack ${A}
        unpack ./data.tar.gz
}

src_install(){
	cp -R usr "${D}"
	cp -R opt "${D}"
}

