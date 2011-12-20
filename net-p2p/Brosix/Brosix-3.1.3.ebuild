# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

DESCRIPTION="Свободен p2p клиент подобен на Скайп."
HOMEPAGE="http://bg.brosix.com/"
SRC_URI="ftp://calculate.linuxmaniac.net/pub/downloads/brosix-3.1.3.tar.xz"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=media-libs/alsa-lib-1.0.23
		>=media-libs/xine-lib-1.1.19"
RDEPEND="${DEPEND}"

src_install() {
	cd "${WORKDIR}"
	cp -R * "${D}/" || die "install failed"
}
