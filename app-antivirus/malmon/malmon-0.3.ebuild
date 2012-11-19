# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
inherit eutils
DESCRIPTION="Malware Monitor"
HOMEPAGE="http://sourceforge.net/projects/malmon/"
SRC_URI="http://sourceforge.net/projects/"${PN}"/files/"${PN}-${PV}".tar.gz"

LICENSE="GPL"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="dev-python/pyinotify"
RDEPEND="${DEPEND}"

src_install() {
	cd "${WORKDIR}"/v0.3/src/
	dosbin malmon.py
	dosbin malmon-scan.py
	dodir  /var/cache/malmon
	dodir  /var/cache/malmon/infected
	dodir  /etc/malmon
	cp  conf/* "${D}"/etc/malmon
	ewarn "Edit the config file /etc/malmon/malmon.conf /etc/malmon/exclude.list /etc/malmon/back.list"
	elog "Run the daemon: /usr/sbin/malmon"
}
