# Copyright 2008-2012 Funtoo Technologies
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
inherit eutils

DESCRIPTION=""
HOMEPAGE="https://github.com/sandikata/"
SRC_URI="ftp://calculate.linuxmaniac.net/pub/downloads/calculate-usb-creator-0.1.tar.xz"

LICENSE=""
SLOT="stable"
KEYWORDS="amd64 x86"
IUSE="dialog +xdialog"

DEPEND="dialog? ( >=dev-util/dialog-1.1.20110707-r1 )
	xdialog? ( >=x11-misc/xdialog-2.3.1 )"
RDEPEND="${DEPEND}"

src_install() {
	cd "${WORKDIR}"
	cp -R * "${D}/"
	doicon "${FILESDIR}"/calculate-usb-creator.png
	domenu "${FILESDIR}"/calculate-usb-creator.desktop
}
