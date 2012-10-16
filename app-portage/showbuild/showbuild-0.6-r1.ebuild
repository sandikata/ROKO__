# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit prefix

DESCRIPTION="Script to follow build.log of running ebuilds"
HOMEPAGE="http://cj-overlay.googlecode.com"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86 ~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

DEPEND=""
RDEPEND="
	prefix? ( || ( <sys-apps/util-linux-2.18 sys-apps/tailf ) )
	!prefix? ( sys-apps/util-linux )
	app-shells/bash"

S="${T}"

src_prepare() {
	cp "${FILESDIR}/showbuild-${PV}" "${T}"/showbuild || die
	eprefixify "${T}"/showbuild
}

src_install () {
	dobin "${T}"/showbuild
}
