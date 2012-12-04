# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

DESCRIPTION=""
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"
IUSE="dockmanager"

DEPEND="dev-python/pygobject
	dev-python/pygtk
	dev-python/gconf-python
	dev-python/imaging
	dev-python/libgnome-python
	dev-python/gnome-applets-python
	dev-python/gnome-vfs-python
	dev-python/libwnck-python
	dev-libs/keybinder[python]
	dev-python/pyxdg
	dev-python/python-xlib
	dockmanager? ( x11-misc/dockmanager )"
RDEPEND="${DEPEND}"

