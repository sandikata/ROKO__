# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2
inherit versionator

MY_MAJ=$(get_version_component_range 1-2)

DESCRIPTION="Equinox GTK+ Theme Engine - Based on Aurora"
HOMEPAGE="http://www.gnome-look.org/content/show.php?content=56438"
SRC_URI="http://gnome-look.org/CONTENT/content-files/121881-equinox-${PV}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86 ~x86-interix ~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

RDEPEND=">=x11-libs/gtk+-2.10:2"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

S=${WORKDIR}/equinox-${MY_MAJ}

src_unpack() {
	unpack ${A}
	cd "${WORKDIR}"
	tar -xf equinox-gtk-engine.tar.gz || die "unpack failed"
	tar -xf equinox-themes.tar.gz || die "unpack failed"
}

src_configure() {
	econf --disable-dependency-tracking --enable-animation
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog NEWS README
	insinto /usr/share/themes/
	doins -r ../Equinox* || die "doins failed"
}
