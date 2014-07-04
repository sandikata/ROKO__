# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-xfapplet-plugin/Attic/xfce4-xfapplet-plugin-0.1.0.ebuild,v 1.10 2011/11/04 23:43:25 ssuominen dead $

EAPI=5
inherit xfconf

DESCRIPTION="Panel plugin to support GNOME applets"
HOMEPAGE="http://goodies.xfce.org/projects/panel-plugins/xfce4-xfapplet-plugin"
SRC_URI="mirror://xfce/src/panel-plugins/${PN}/0.1/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND=">=x11-libs/gtk+-2.4:2
	>=xfce-base/xfce4-panel-4.8
	>=xfce-base/libxfcegui4-4.8
	>=gnome-base/orbit-2.12.5
	gnome-base/gnome-panel[bonobo]"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	dev-util/intltool"

pkg_setup() {
	DOCS=( AUTHORS ChangeLog NEWS README )
}

