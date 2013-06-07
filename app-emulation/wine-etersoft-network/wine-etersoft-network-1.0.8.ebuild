# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

MY_P="wine-etersoft-network-${PV}"
DESCRIPTION="WINE@Etersoft Network, a addon for WINE@Etersoft with enhanced Network support for office application, as such as 1C:Predpryatie"
HOMEPAGE="http://www.etersoft.ru/"
SRC_URI="${MY_P}.tbz2"

LICENSE="WINE@Etersoft-Network Corp.WINE@Etersoft-Network"
SLOT="0"
KEYWORDS="-* ~x86 ~amd64"
#IUSE="alsa arts cups dbus esd hal jack jpeg lcms ldap nas ncurses opengl oss scanner xml X"
RESTRICT="fetch strip"

		 
RDEPEND=">=media-libs/freetype-2.0.0
	!app-emulation/wine
	!app-emulation/wine-etersoft-sql
	>=app-emulation/wine-etersoft-public-${PV}
	media-fonts/corefonts "

pkg_nofetch() {
	einfo "Please download the appropriate WINE@Etersoft-Network archive (${MY_P}.tbz2)"
	einfo "from ${HOMEPAGE} (requires a Etersoft subscription)"
	einfo
	einfo "Then put the file in ${DISTDIR}"
}

src_unpack () {
	unpack "${A}"
	cp -p "${FILESDIR}"/eter_acl "${WORKDIR}"/usr/bin/
}

src_install() {
	mv "${WORKDIR}"/* "${D}" || die "mv usr"
}

pkg_postinst() {
	einfo "Run /usr/bin/wine to start wine as any non-root user."
	einfo "This will take care of creating an initial environment"
	einfo " and do everything else."
	einfo ""
}
