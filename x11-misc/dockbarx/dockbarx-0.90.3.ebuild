# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit  gnome2-utils distutils eutils python

PYTHON_DEPEND="2:2.7"
RESTRICT_PYTHON_ABIS="3.*"

DESCRIPTION="DockBarX is a lightweight taskbar / panel replacement for Linux"
HOMEPAGE="https://github.com/M7S/dockbarx"
#EGIT_REPO_URI="git://github.com/M7S/dockbarx.git"
RESTRICT="mirror"
SRC_URI="https://launchpad.net/dockbar/dockbarx/"${PV}"/+download/"${PN}"_"${PV}".tar.gz"

LICENSE="GPL3"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE="dockmanager"

DEPEND="dev-python/pygobject
	dev-python/pygtk
	dev-python/gconf-python
	dev-python/pillow
	dev-python/libwnck-python
	dev-python/gnome-applets-python
	dev-libs/keybinder[python]
	dev-python/pyxdg
	dev-python/python-xlib
	=x11-libs/libwnck-2.31.0
	=gnome-base/gnome-menus-2.30.5-r1
	=gnome-base/gnome-panel-2.32.1-r3
	dockmanager? ( x11-misc/dockmanager )"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${P/-/_}"

src_prepare() {
	epatch "${FILESDIR}"/image_pillow.patch
}

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
