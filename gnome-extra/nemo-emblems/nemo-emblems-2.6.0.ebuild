# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
PYTHON_COMPAT=( python2_7 )

inherit python-single-r1

DESCRIPTION="Change your folder and file emblems"
HOMEPAGE="https://github.com/linuxmint/nemo-extensions"
SRC_URI="https://github.com/linuxmint/nemo-extensions/archive/2.6.x.tar.gz"
S="${WORKDIR}/nemo-extensions-2.6.x/${PN}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND=""
RDEPEND=">=gnome-extra/nemo-python-2.6.0"

src_install() {
	default
	python_fix_shebang nemo-extension/
	exeinto usr/share/nemo-python/extensions/
	doexe nemo-extension/nemo-emblems.py
}
