# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-extra/nm-applet/nm-applet-0.8.4.ebuild,v 1.11 2012/10/26 22:58:18 tetromino Exp $

EAPI="3"
GCONF_DEBUG="no"
GNOME2_LA_PUNT="yes"
GNOME_ORG_MODULE="network-manager-applet"

inherit autotools eutils gnome2

DESCRIPTION="Gnome applet for NetworkManager."
HOMEPAGE="http://projects.gnome.org/NetworkManager/"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="amd64 ppc x86"
IUSE="bluetooth"

RDEPEND=">=dev-libs/glib-2.16:2
	>=dev-libs/dbus-glib-0.88
	>=sys-apps/dbus-1.4.1
	>=x11-libs/gtk+-2.18:2
	>=gnome-base/gconf-2.20:2
	>=x11-libs/libnotify-0.4.3
	>=gnome-base/gnome-keyring-2.20
	>=sys-auth/polkit-0.96-r1

	>=net-misc/networkmanager-${PV}
	net-misc/mobile-broadband-provider-info

	bluetooth? ( >=net-wireless/gnome-bluetooth-2.27.6 )
	virtual/freedesktop-icon-theme"

DEPEND="${RDEPEND}
	>=dev-util/intltool-0.40
	virtual/pkgconfig

	gnome-base/gnome-common"
# eautoreconf needs gnome-base/gnome-common

pkg_setup () {
	G2CONF="${G2CONF}
		--disable-more-warnings
		--disable-static
		--localstatedir=/var
		$(use_with bluetooth)"

	DOCS="AUTHORS ChangeLog NEWS README"
}

src_prepare() {
	epatch "${FILESDIR}/${P}-utils-libm.patch" #430360
	eautoreconf
	gnome2_src_prepare
}
