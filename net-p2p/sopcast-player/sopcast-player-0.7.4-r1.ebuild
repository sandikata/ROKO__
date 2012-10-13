# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

DESCRIPTION="Плейър за p2p онлайн телевизия чрез sopcast приставка."
HOMEPAGE=""
SRC_URI="ftp://calculate-linuxmaniac.tk/pub/downloads/sopcast-player-0.7.4-r1.tar.xz"

LICENSE=""
SLOT="unstable"
KEYWORDS="~amd64"
IUSE="+totem vlc gnome-mplayer"

DEPEND=">=sys-libs/libstdc++-v3-3.3.6
		>=virtual/libstdc++-3.3
		totem? ( >=media-video/totem-2.32.0-r2  )
		gnome-mplayer? ( >=media-video/gnome-mplayer-1.0.5_beta1 )
		vlc? ( >=media-video/vlc-1.1.13 )
		"
RDEPEND="${DEPEND}"

src_install() {
	cd "${WORKDIR}"
	cp -R * "${D}/"
	elog "При проблеми с плейъра се обръщайте към sopcast@support!"
	echo
}
