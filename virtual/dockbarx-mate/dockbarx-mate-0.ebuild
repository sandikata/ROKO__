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
	dev-python/imaging
	dev-python/libwnck-python
	<=dev-libs/keybinder-0.2.2[python]
	dev-python/pyxdg
	dev-python/python-xlib
	mate-base/mate-conf
	dev-python/gconf-python
	dev-python/numpy
	dockmanager? ( x11-misc/dockmanager )"
RDEPEND="${DEPEND}"

