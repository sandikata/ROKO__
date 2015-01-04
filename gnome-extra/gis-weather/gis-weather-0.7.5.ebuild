# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit gnome2-utils eutils rpm
PYTHON_DEPEND="3:3.3"

DESCRIPTION=""
HOMEPAGE="http://sourceforge.net/projects/gis-weather/"
SRC_URI="mirror://sourceforge/gis-weather/${PN}-${PV}-2.noarch.rpm"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="dev-python/pygobject:3
	dev-libs/gobject-introspection[cairo]
	x11-libs/gtk+:3
	gnome-base/librsvg"
RDEPEND="${DEPEND}"

S=${WORKDIR}

src_unpack() {
	rpm_src_unpack
}

src_install() {
	cp -R "${WORKDIR}"/usr "${D}/"
}

pkg_postinst() { gtk-update-icon-cache; }
pkg_postrm() { gtk-update-icon-cache; }

