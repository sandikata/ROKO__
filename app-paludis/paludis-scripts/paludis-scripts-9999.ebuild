# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"
inherit git-2

DESCRIPTION="Scripts for paludis, the other package mangler"
HOMEPAGE="http://paludis.exherbo.org/"
SRC_URI=""
EGIT_REPO_URI="git://git.exherbo.org/paludis/paludis-scripts.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="sys-apps/paludis[ruby-bindings]"

src_unpack() {
	git-2_src_unpack
}

src_install() {
	cd ${S}
	insinto /usr/share/paludis/hooks/demos
	doins *.hook
	exeinto /opt/bin
	doexe `find . -maxdepth 1 -type f ! -name *.hook`
}
