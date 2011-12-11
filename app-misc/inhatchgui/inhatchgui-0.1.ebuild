# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

DESCRIPTION="Графичен интерфейс към Inhatch VLC приставка"
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=net-p2p/inhatch-0.8
		>=media-video/vlc-1.1.10"

RDEPEND="${DEPEND}"

src_install() {
	cd "${FILESDIR}"
	dobin inhatchgui || die

	elog "За да използвате графичния интерфейс напишете в терминала 'inhatchgui'"
}


