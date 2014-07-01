# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit xfconf distutils eutils python vala

PYTHON_DEPEND="2:2.7"
RESTRICT_PYTHON_ABIS="3.*"

DESCRIPTION="Embed DockbarX in the xfce4-panel"
HOMEPAGE="http://xfce-look.org/content/show.php/xfce4-dockbarx-plugin+%2B+Mouse+DBX+Theme?content=157865"
SRC_URI="http://tiz.qc.to/pub/xfce4-dockbarx-plugin-${PV}.tar.bz2"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="dev-lang/vala
	x11-misc/dockbarx
	xfce-base/xfce4-panel
"
RDEPEND="${DEPEND}"

#pkg_setup() {
#	python_set_active_version 2
#	python_pkg_setup
#}

src_configure() {
	cd "${WORKDIR}"/"${PN}-${PV}"
#	./waf wscript
	./waf configure
	./waf build
}

src_install() {
	cd "${WORKDIR}"/"${PN}-${PV}"
	./waf install
}