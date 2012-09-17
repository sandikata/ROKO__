# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit rpm gnome2-utils

#SRC_URI="http://ftp.free.fr/mirrors/ftp.mandriva.com/MandrivaLinux/devel/cooker/SRPMS/main/release/${P}-1.src.rpm"
SRC_URI="http://mirror.yandex.ru/rosa/rosa2012lts/repository/SRPMS/main/release/${P}-1.src.rpm"
DESCRIPTION="ROSA icons theme. Designed for Mandriva. Based on the original icon theme Elementary by Daniel Fore (Dan Rabbit)"
HOMEPAGE="http://www.rosalab.ru"
RESTRICT="mirror"

LICENSE="GPLv2"
SLOT="0"
KEYWORDS="x86 amd64"

src_unpack() {
	rpm_src_unpack ${A}
 	mv "${WORKDIR}/rosa-${PV}" "${S}"
}

src_install() {
	dodoc AUTHORS CONTRIBUTORS

	insinto /usr/share/icons/${PN}/
	doins -r `ls -d */`
	doins index.theme
}

pkg_preinst() { gnome2_icon_savelist; }
pkg_postinst() { gnome2_icon_cache_update; }
pkg_postrm() { gnome2_icon_cache_update; }
