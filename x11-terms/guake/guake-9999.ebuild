# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_5 )

inherit eutils git-r3 distutils-r1

DESCRIPTION="Drop-down terminal for GTK+ desktops"
HOMEPAGE="https://github.com/Guake/guake"
# override gnome.org.eclass SRC_URI
SRC_URI=''
EGIT_REPO_URI="https://github.com/Guake/guake.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	dev-python/dbus-python[${PYTHON_USEDEP}]
	dev-python/gconf-python[python_targets_python2_7]
	dev-python/notify-python[python_targets_python2_7]
	dev-python/pygtk[python_targets_python2_7]
	dev-python/pyxdg[${PYTHON_USEDEP}]
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/vte:2.91
	dev-libs/keybinder:3
	dev-python/pipenv
"
DEPEND="
	${RDEPEND}
	dev-util/intltool
	virtual/pkgconfig
"

DOCS=( AUTHORS ChangeLog NEWS.rst README.rst )

src_prepare() {
	distutils-r1_src_prepare
}
