# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit git-2 gnome2-utils distutils eutils python

PYTHON_DEPEND="2:2.7"
RESTRICT_PYTHON_ABIS="3.*"

DESCRIPTION="DockBarX is a lightweight taskbar / panel replacement for Linux"
HOMEPAGE="https://github.com/M7S/dockbarx"
EGIT_REPO_URI="git://github.com/M7S/dockbarx.git"
RESTRICT="mirror"

LICENSE="GPL3"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND="dev-python/pygobject
	dev-python/pygtk
	dev-python/gconf-python
	dev-python/imaging
	dev-python/libwnck-python
	dev-python/gnome-applets-python
	dev-python/gnome-vfs-python
	dev-libs/keybinder[python]
	dev-python/pyxdg
	dev-python/python-xlib"
RDEPEND="${DEPEND}"

pkg_setup() {
	python_set_active_version 2
	python_pkg_setup
}

#pkg_preinst() {
#	if ! use awn ; then
#	rm -rf ${ROOT}/usr/share/avant-window-navigator/applets/DockBarX/
#	rm -f ${ROOT}/usr/share/avant-window-navigator/applets/DockBarX.desktop
#}
pkg_postinst() { gtk-update-icon-cache; }
pkg_postrm() { gtk-update-icon-cache; }
