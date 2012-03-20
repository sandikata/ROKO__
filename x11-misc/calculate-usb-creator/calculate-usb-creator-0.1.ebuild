# Copyright 2008-2012 Funtoo Technologies
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
inherit eutils

DESCRIPTION="Инструмент для создания загрузочных USB FLASH."
HOMEPAGE="https://github.com/sandikata/"
SRC_URI=""

LICENSE=""
SLOT="stable"
KEYWORDS="amd64 x86"
IUSE="bulgarian"

DEPEND=">=x11-misc/xdialog-2.3.1"
RDEPEND="${DEPEND}"

src_install() {
	cd "${FILESDIR}"

	if use bulgarian; then
	epatch calculate-usb-creator-bg.patch
	fi
	dobin calculate-usb-creator
	doicon "${FILESDIR}"/calculate-usb-creator.png
	domenu "${FILESDIR}"/calculate-usb-creator.desktop
}
