# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

DESCRIPTION=""
HOMEPAGE=""
SRC_URI="ftp://calculate.linuxmaniac.net/pub/downloads/mounty-0.1.3.tar.xz"

LICENSE=""
SLOT="unstable"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=x11-misc/notify-osd-0.9.32
		>=sys-fs/fuseiso-20070708"
RDEPEND="${DEPEND}"

src_install() {
	cd "${WORKDIR}"
	cp -R * "${D}/" || die "install failed"
}
