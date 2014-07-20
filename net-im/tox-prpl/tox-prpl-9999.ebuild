# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils autotools git-2

DESCRIPTION="Tox plugin for Pidgin/libpurple"
HOMEPAGE="http://tox.dhs.org/"
SRC_URI=""
EGIT_REPO_URI="https://github.com/jin-eld/tox-prpl.git"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="
	dev-libs/glib:2
	net-im/pidgin
	net-libs/tox"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_prepare() {
	eautoreconf
}

src_configure() {
	econf \
		--disable-static
}

src_install() {
	default
	prune_libtool_files --all
}
