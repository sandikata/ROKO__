# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
GCONF_DEBUG="no"

inherit gnome2

DESCRIPTION="indicator showing user information and status"
HOMEPAGE="http://launchpad.net/indicator-me"
SRC_URI="mirror://ubuntu/pool/main/i/${PN}/${PN}_${PV}.orig.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	>=dev-libs/atk-1.29.3
	>=dev-libs/glib-2.18:2
	>=x11-libs/gtk+-2.12:2
	>=x11-libs/cairo-1.2.4
	>=x11-libs/pango-1.14.0
	>=dev-libs/dbus-glib-0.76
	>=gnome-base/gconf-2
	>=dev-libs/libindicator-0.1
	>=dev-libs/libdbusmenu-0.2.8
	>=net-libs/telepathy-glib-0.9.0
	>=x11-libs/ido-0.1.5
	gnome-extra/indicator-applet"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	dev-util/intltool"

RESTRICT="mirror"

DOCS="AUTHORS ChangeLog COPYING README"
