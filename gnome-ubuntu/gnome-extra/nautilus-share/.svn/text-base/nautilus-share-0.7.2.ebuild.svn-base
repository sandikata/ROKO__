# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit autotools eutils gnome2

DESCRIPTION="Nautilus extension to share folder using Samba"
HOMEPAGE="http://gentoo.ovibes.net/nautilus-share"
SRC_URI="http://gentoo.ovibes.net/${PN}/${P}.tar.gz
	mirror://ubuntu/pool/main/n/${PN}/${PN}_${PV}-12build1.diff.gz"

IUSE=""
SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"

# patches from Ubuntu change the deps
# >=gnome-base/eel-2.10.0
# >=gnome-base/libglade-2.4.0
DEPEND="dev-libs/glib:2
	gnome-base/libgnomeui
	gnome-base/nautilus
	x11-libs/gtk+:2"
RDEPEND="${DEPEND}
	net-fs/samba"

RESTRICT="mirror"

DOCS="AUTHORS ChangeLog NEWS README TODO"

USERSHARES_GROUP="sambashare"

src_prepare() {
	gnome2_src_prepare

	cd "${WORKDIR}"
	epatch ${PN}_${PV}-12build1.diff
	cd "${S}"

	# patch 11 based on 02, make it alone
	sed -i -e '20d' \
		-e '15s/12/11/' -e '15s/13/12/' \
		debian/patches/11_use-gio.patch

	EPATCH_SOURCE="${S}/debian/patches" EPATCH_SUFFIX="patch" \
		EPATCH_EXCLUDE="02_install_missing_samba.patch
			99_ltmain_as-needed.patch" \
		EPATCH_FORCE="yes" epatch

	eautoreconf
}

pkg_postinst() {
	einfo
	einfo "Users who are to be allowed to use nautilus-share should be added"
	einfo "to the \"${USERSHARES_GROUP}\" group."
	einfo
	einfo "Users may need to log out and in again for the group assignment to"
	einfo "take effect and to restart Nautilus."
	einfo
}
