# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
RESTRICT="mirror"
inherit eutils vcs-snapshot

DESCRIPTION="Plugin for FETCHCOMMAND to help organize and cleanup your DISTDIR"
HOMEPAGE="https://github.com/vaeth/trickyfetch/"
SRC_URI="http://github.com/vaeth/${PN}/tarball/release-${PV} -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+eix zsh-completion"

RDEPEND="eix? ( app-portage/eix )"

src_prepare() {
	epatch_user
}

src_install() {
	dobin bin/*
	if use zsh-completion
	then	insinto /usr/share/zsh/site-functions
			doins zsh/_*
	fi
	dodoc README
}
