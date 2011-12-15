# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

DESCRIPTION="Видео Конвертор."
HOMEPAGE=""
SRC_URI="ftp://calculate.linuxmaniac.net/pub/downloads/vidrop-0.6.8.tar.xz"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_install() {
	cd "${WORKDIR}"
	cp -R * "${D}/" || die "install failed"

	elog "Тестова програма, използвайте на своя отговорност!"
	echo
}
