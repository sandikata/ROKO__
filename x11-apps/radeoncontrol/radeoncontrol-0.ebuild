# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
inherit eutils
DESCRIPTION="A tool for manage radeon cards power management with opensource 'radeon' driver"
HOMEPAGE="https://github.com/sandikata/ROKO__"
SRC_URI=""

LICENSE=""
SLOT="current"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_install() {
	dobin "${FILESDIR}"/radeoncontrol
	echo
	einfo "Supported profiles are: 'low, mid, high, auto,default'"
	einfo "Add to /etc/local.d/local.start the following line:"
	einfo "radeoncontrol profile profilename"
	echo
}
