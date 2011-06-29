# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit autotools eutils gnome2

DESCRIPTION="PolicyKit policies and configurations for the GNOME desktop"
HOMEPAGE="http://hal.freedesktop.org/docs/PolicyKit"
SRC_URI="http://hal.freedesktop.org/releases/${P}.tar.bz2
	mirror://ubuntu/pool/main/p/policykit-1-gnome/policykit-1-gnome_${PV}-2ubuntu2.diff.gz"

LICENSE="LGPL-2 GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE="doc examples indicator" #introspection

RDEPEND=">=x11-libs/gtk+-2.17.1
	>=gnome-base/gconf-2.8
	>=dev-libs/dbus-glib-0.71
	>=sys-auth/polkit-0.95"
	# Not ready for tree
	#introspection? ( >=dev-libs/gobject-introspection-0.6.2 )
DEPEND="${RDEPEND}
	sys-devel/gettext
	>=dev-util/pkgconfig-0.19
	>=dev-util/intltool-0.35.0
	>=app-text/scrollkeeper-0.3.14
	gnome-base/gnome-common
	dev-util/gtk-doc-am
	indicator? ( gnome-extra/indicator-application )
	doc? ( >=dev-util/gtk-doc-1.3 )"

RESTRICT="mirror"

DOCS="AUTHORS HACKING NEWS TODO"

pkg_setup() {
	G2CONF="${G2CONF}
		--disable-introspection
		$(use_enable examples)
		$(use_enable indicator appindicator)"
		#$(use_enable introspection)"
}

src_prepare() {
	if use indicator; then
		epatch "${WORKDIR}"/policykit-1-gnome_${PV}-2ubuntu2.diff
		epatch policykit-1-gnome-${PV}/debian/patches/03-appindicator.patch
		eautoreconf
	fi

	# Fix make check, bug 298345
	epatch "${FILESDIR}/${PN}-0.95-fix-make-check.patch"

	if use doc; then
		# Fix parallel build failure, bug 293247
		epatch "${FILESDIR}/${PN}-0.95-parallel-build-failure.patch"

		gtkdocize || die "gtkdocize failed"
		eautoreconf
	fi
}
