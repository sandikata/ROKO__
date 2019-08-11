# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_5 python3_6 )
inherit autotools eutils python-r1 mate
DESCRIPTION="Application dock for the MATE panel"
HOMEPAGE="https://github.com/robint99/mate-dock-applet"
SRC_URI="https://github.com/robint99/mate-dock-applet/archive/V${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND=">=sys-devel/automake-1.15:1.15"

RDEPEND="
	dev-python/pillow[${PYTHON_USEDEP}]
	dev-python/python-xlib[${PYTHON_USEDEP}]
	dev-python/pygobject:3[${PYTHON_USEDEP}]
	dev-python/pycairo[${PYTHON_USEDEP}]
	>=mate-base/mate-panel-1.17.0[introspection]
	x11-libs/libwnck:3[introspection]
	x11-libs/bamf
	"

src_prepare() {
	eapply_user
	eaclocal
	eautomake
	eautoreconf
}

src_configure(){
	econf --with-gtk3
}
