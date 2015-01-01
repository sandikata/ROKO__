# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
ETYPE="sources"
K_SECURITY_UNSUPPORTED="1"
K_DEBLOB_AVAILABLE=0
EXTRAVERSION="-lto"

inherit kernel-2 eutils git-2

detect_version

DESCRIPTION="kernel sources with LTO support"
HOMEPAGE="http://halobates.de/"
EGIT_BRANCH="lto-3.16"
EGIT_REPO_URI="https://github.com/andikleen/linux-misc.git"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"
IUSE="bfs cpu-optimization reiser4 uksm"

src_prepare() {
	use bfs && epatch "${FILESDIR}/${PN}-${PV}-sched-bfs.patch"
	use reiser4 && epatch "${FILESDIR}/${PN}-${PV}-reiser4.patch"
	use uksm && epatch "${FILESDIR}/${PN}-${PV}-uksm.patch"
	use cpu-optimization && epatch "${FILESDIR}/${PN}-${PV}-cpu-optimization-for-gcc.patch"
	sed -i 's/rc7/lto/g' Makefile || die "couldn't change extraversion"
}

pkg_postinst() {
	kernel-2_pkg_postinst
	ewarn "After assemble you have to run emerge @module-rebuild"
}

pkg_postrm() {
	kernel-2_pkg_postrm
}

