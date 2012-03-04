# Copyright 2008-2012 Funtoo Technologies
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

DESCRIPTION="Графичен интерфейс към програмата ddflash"
HOMEPAGE="https://github.com/sandikata/"
SRC_URI=""

LICENSE=""
SLOT="testing"
KEYWORDS="~amd64 ~x86"
IUSE="dialog xdialog"

DEPEND="dialog? ( >=dev-util/dialog-1.1.20110707-r1 )
	xdialog? ( >=x11-misc/xdialog-2.3.1 )"
RDEPEND="${DEPEND}"

pkg_postinst() {
	cd "${FILESDIR}"
	dobin ddflash-gui"
}
