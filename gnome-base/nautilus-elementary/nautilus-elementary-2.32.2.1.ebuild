# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
GCONF_DEBUG="no"

inherit eutils gnome2 virtualx autotools bzr

EBZR_CACHE_DIR="nautilus-elementary-2.31+"
EBZR_REPO_URI="lp:nautilus-elementary/2.31+"

DESCRIPTION="A file manager for the GNOME desktop"
HOMEPAGE="http://www.gnome.org/projects/nautilus/"
SRC_URI="mirror://gentoo/introspection.m4.bz2"

LICENSE="GPL-2 LGPL-2 FDL-1.1"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="gnome xmp clutter-view"

RDEPEND=">=dev-libs/glib-2.25.9
	>=gnome-base/gnome-desktop-2.29.91
	>=x11-libs/pango-1.1.2
	>=x11-libs/gtk+-2.21.2
	>=dev-libs/libxml2-2.4.7
	>=media-libs/libexif-0.5.12
	>=gnome-base/gconf-2.0
	dev-libs/libunique
	dev-libs/dbus-glib
	x11-libs/libXft
	x11-libs/libXrender
	xmp? ( >=media-libs/exempi-2 )
	clutter-view? ( >=media-libs/clutter-gtk-0.8.10:0.10 )
	!gnome-base/nautilus"

DEPEND="${RDEPEND}
	>=dev-lang/perl-5
	sys-devel/gettext
	>=dev-util/pkgconfig-0.9
	>=dev-util/intltool-0.40.1
	>=dev-util/gtk-doc-1.4"

PDEPEND="gnome? ( >=x11-themes/gnome-icon-theme-1.1.91 )
	>=gnome-base/gvfs-0.1.2"

DOCS="AUTHORS ChangeLog* HACKING MAINTAINERS NEWS README THANKS TODO"

pkg_setup() {
	G2CONF="${G2CONF}
		--prefix=/usr
		--disable-static
		--disable-introspection
		--disable-update-mimedb
		--disable-packagekit
		--enable-empty-view
		--enable-gtk-doc-html=no
		$(use_enable clutter-view)
		$(use_enable xmp)"
}

src_unpack() {
		bzr_src_unpack
		gnome2_src_unpack
}

src_prepare() {
	./autogen.sh || die "autogen.sh failed"
	gnome2_src_prepare

	# Fix nautilus flipping-out with --no-desktop -- bug 266398
#	epatch "${FILESDIR}/nautilus-2.27.4-change-reg-desktop-file-with-no-desktop.patch"

}

src_test() {
	addwrite "/root/.gnome2_private"
	unset SESSION_MANAGER
	unset ORBIT_SOCKETDIR
	unset DBUS_SESSION_BUS_ADDRESS
	Xemake check || die "Test phase failed"
}

src_install() {
	gnome2_src_install
	find "${D}" -name "*.la" -delete || die "remove of la files failed"
}

pkg_postinst() {
	gnome2_pkg_postinst

	elog "nautilus can use gstreamer to preview audio files. Just make sure"
	elog "to have the necessary plugins available to play the media type you"
	elog "want to preview"
}
