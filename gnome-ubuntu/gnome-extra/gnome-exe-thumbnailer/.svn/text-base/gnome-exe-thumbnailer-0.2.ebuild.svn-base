# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit eutils gnome2-utils

DESCRIPTION="Windows executable thumbnailer for Gnome"
HOMEPAGE="https://launchpad.net/ubuntu/+source/gnome-exe-thumbnailer"
SRC_URI="mirror://ubuntu/pool/universe/g/${PN}/${PN}_${PV}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

# media-gfx/imagemagick
DEPEND=""
RDEPEND="
	gnome-base/gconf
	media-gfx/icoutils
	dev-lang/python"

RESTRICT="mirror"

src_prepare() {
	epatch "${FILESDIR}"/no-template.patch
}

src_install() {
	exeinto /usr/bin
	doexe gnome-exe-thumbnailer.sh

	insinto /usr/share/pixmaps
	doins "${FILESDIR}"/gnome-exe-thumbnailer-template.png

	insinto /etc/gconf/schemas
	doins gnome-exe-thumbnailer.schemas
}

pkg_preinst() {
	gnome2_gconf_savelist
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_gconf_install
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
