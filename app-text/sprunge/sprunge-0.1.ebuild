# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

DESCRIPTION="Програма за прилагане на текстови файлове към http://sprunge.us/"
HOMEPAGE=""
SRC_URI="https://raw.github.com/sandikata/ROKO__/master/app-text/sprunge/files/sprunge"

LICENSE=""
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""

DEPEND=">=app-shells/bash-4.1_p9"
RDEPEND="${DEPEND}"

src_install() {
cd ${DISTDIR}
	dobin ${PN} || die
	}

pkg_postinst() {
		elog "Пример/Example -> sprunge /etc/rc.conf"
		}
