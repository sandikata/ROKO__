# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit autotools eutils

DESCRIPTION="File Roller integration for Nemo"
HOMEPAGE="https://github.com/linuxmint/nemo-extensions"
SRC_URI="https://github.com/linuxmint/nemo-extensions/archive/2.8.x.tar.gz"
S="${WORKDIR}/nemo-extensions-2.8.x/${PN}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

RDEPEND=""
DEPEND="app-arch/file-roller
	>=gnome-extra/nemo-2.8.0[introspection]"

src_prepare() {
	if [[ ! -e configure ]] ; then
		./autogen.sh || die
	fi
}
