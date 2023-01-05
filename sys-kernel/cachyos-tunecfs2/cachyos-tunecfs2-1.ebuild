# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="CachyOS-Settings"
HOMEPAGE="https://github.com/CachyOS/CachyOS-Settings"
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="amd64"

DEPEND="sys-kernel/cachyos-sources"
RDEPEND="${DEPEND}"
BDEPEND=""

S="${FILESDIR}/"

src_install () {
	dobin "${FILESDIR}/tunecfs2"

	elog "To use cachyos tunecfs2 tweak tool run as root (example: "tunecfs2 cachy" which is default, or "tunecfs2" to see available options)"
}
