# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit rpm

DESCRIPTION="WINE@Etersoft Local, a addon for WINE@Etersoft for office application, as such as 1C:Predpryatie"
HOMEPAGE="http://etersoft.ru/product"
SRC_URI="${P%_p*}-eter${PV#*_p}gentoo.i586.tar.gz"

LICENSE="WINE@Etersoft-Local Corp.WINE@Etersoft-Local"
SLOT="0"
KEYWORDS="-* ~x86 ~amd64"
RESTRICT="fetch strip"

		 
RDEPEND=">=media-libs/freetype-2.0.0
	!app-emulation/wine
	!app-emulation/wine-etersoft-network
	!app-emulation/wine-etersoft-sql
	>=app-emulation/wine-etersoft-public-${PV%_p*}_p17
	>=dev-libs/openssl-0.9.8g
	>=app-i18n/libnatspec-0.2.4
	>=dev-libs/libusb-0.1.12
	media-fonts/corefonts"

pkg_nofetch() {
	einfo "Please download the appropriate WINE@Etersoft-Local archive ${P%_p*}-eter${PV#*_p}gentoo.i586.tar.gz"
	einfo "from ${HOMEPAGE} (requires a Etersoft subscription)"
	einfo
	einfo "Then put the file in ${DISTDIR}"
}

src_unpack () {
	unpack "${A}"
	cp -p "${FILESDIR}"/eter_acl "${WORKDIR}"/usr/bin/
}

src_install() {
	dodir /etc/init.d
	dodir /etc/wine
	cp "${FILESDIR}"/etersafe.init-1.0.9 "${D}"/etc/init.d/etersafed || die "cp usr"

	use x86 && { cp -R "${WORKDIR}"/usr "${D}" || die "cp libs"; }
	
	use amd64 && { cp -R "${WORKDIR}"/usr/lib/* "${D}"/usr/lib32/ || die "cp libs"; }
	
	cp -R "${WORKDIR}"/usr/bin "${D}"/usr/ || die "cp bins"
	cp -R "${WORKDIR}"/usr/sbin "${D}"/usr/ || die "cp sbin"
	cp -R "${WORKDIR}"/usr/share "${D}"/usr/ || die "cp share"
	cp -R "${WORKDIR}"/etc/wine/* "${D}"/etc/wine/ || die "cp /etc/wine"
	
}

pkg_postinst() {

	use x86 && { cd /usr/lib

				[ -h libcrypto.so.6 ] || ln -s libcrypto.so libcrypto.so.6
				[ -h libssl.so.6 ] || ln -s libssl.so libssl.so.6
			}

	use amd64 && { cd /usr/lib32

				[ -h libcrypto.so.6 ] || ln -s libcrypto.so libcrypto.so.6
				[ -h libssl.so.6 ] || ln -s libssl.so libssl.so.6
			}

	
	einfo "Run /usr/bin/wine to start wine as any non-root user."
	einfo "This will take care of creating an initial environment"
	einfo " and do everything else."
	einfo ""
}
