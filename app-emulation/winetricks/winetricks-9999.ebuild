# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/winetricks/winetricks-9999.ebuild,v 1.1 2011/03/01 02:35:56 vapier Exp $

EAPI="2"

DESCRIPTION="easy way to install DLLs needed to work around problems in Wine"
HOMEPAGE="http://code.google.com/p/winetricks/ http://wiki.winehq.org/winetricks"
SRC_URI="http://winetricks.googlecode.com/svn/trunk/src/winetricks"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

src_unpack() {
	cp "${DISTDIR}"/winetricks /usr/bin/winetricks || die
}

src_install() {
	dobin || die
}
