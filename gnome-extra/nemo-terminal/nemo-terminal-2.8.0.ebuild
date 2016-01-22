# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
PYTHON_COMPAT=( python2_7 )

inherit python-single-r1 gnome2-utils

DESCRIPTION="Nemo extension to enable an embedded terminal"
HOMEPAGE="https://github.com/linuxmint/nemo-extensions"
SRC_URI="https://github.com/linuxmint/nemo-extensions/archive/2.8.x.tar.gz"
S="${WORKDIR}/nemo-extensions-2.8.x/${PN}"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND=">=gnome-extra/nemo-python-2.8.0
	x11-libs/vte:2.90
	dev-python/pyxdg[${PYTHON_USEDEP}]"

src_install() {
	default
	python_fix_shebang src/
	exeinto usr/share/nemo-python/extensions/
	doexe src/nemo_terminal.py

	insinto usr/share/glib-2.0/schemas
	doins src/org.nemo.extensions.nemo-terminal.gschema.xml

	insinto usr/share/nemo-terminal
	doins pixmap/logo_120x120.png
}

pkg_preinst() {
	gnome2_icon_savelist
	gnome2_schemas_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
	gnome2_schemas_update
}

pkg_postrm() {
	gnome2_icon_cache_update
	gnome2_schemas_update
}
