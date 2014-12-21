# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit git-2 eutils qmake-utils

DESCRIPTION="xgamma GUI program. allow user adjust color, and real-time preview etc. "
HOMEPAGE="https://github.com/dfc643/xgamma-gui"
EGIT_REPO_URI="https://github.com/dfc643/xgamma-gui.git"

LICENSE=""
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND="x11-apps/xgamma"
RDEPEND="${DEPEND}"

src_prepare() {
	epatch "${FILESDIR}"/qmake-path-fix.patch
}

src_install() {
	emake
}
