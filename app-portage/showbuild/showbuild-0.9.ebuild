# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Script to follow log of running portage builds"
HOMEPAGE="http://cj-overlay.googlecode.com"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86 ~amd64-linux ~x86-linux ~x64-macos ~x86-macos"
IUSE="+tailf"

REQUIRED_USE="tailf? ( !x86-macos !x64-macos )"

DEPEND=""
RDEPEND="
	tailf? ( sys-apps/util-linux )
	!tailf? ( sys-apps/coreutils )
	sys-apps/portage
	app-shells/bash"

S="${FILESDIR}"

src_install () {
	if use tailf; then
		newbin "${P}" "${PN}"
	else
		sed 's/tailf/tail -f/g' "${P}" > "${T}/${P}" || die
		newbin "${T}/${P}" "${PN}"
	fi
}
