# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$
EAPI=6

DESCRIPTION="Portage terminal user interface."
HOMEPAGE="https://github.com/TyanNN/portage-tui"
SRC_URI="https://github.com/TyanNN/portage-tui/archive/${PV}.tar.gz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
RESTRICT="mirror"
RDEPEND="dev-python/pexpect
	dev-lang/python"
S="${WORKDIR}/${PN}-${PV}"

src_install(){
	dobin portage-tui
	dobin cats_parser.py
}
