# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"

DESCRIPTION="GTK Theme of the Moka Project"
HOMEPAGE="https://github.com/moka-project/orchis-gtk-theme"
SRC_URI="https://github.com/moka-project/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="x11-themes/gtk-engines-murrine"

src_install() {
	insinto /usr/share/themes/
	doins -r Orchis Orchis-Dark
}
