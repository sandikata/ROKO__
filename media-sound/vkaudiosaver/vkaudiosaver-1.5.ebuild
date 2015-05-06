# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit eutils
DESCRIPTION=""
HOMEPAGE=""
SRC_URI="amd64? ( http://vkaudiosaver.ru/downloads/vkaudiosaver-debian-amd64 -> vkaudiosaver-debian-amd64.deb )
	x86? ( http://vkaudiosaver.ru/downloads/vkaudiosaver-debian-i386 -> vkaudiosaver-debian-i386.deb )"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-qt/qtdeclarative:4"
RDEPEND="${DEPEND}"

S="${WORKDIR}"

src_prepare(){
	unpack ${A}
	unpack ./data.tar.gz
}
src_install(){
	cp -R opt "${D}"
	dosym /opt/VkAudioSaver/vkaudiosaver /usr/bin/vkaudiosaver
}
