# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-cdr/xfburn/xfburn-0.4.3-r1.ebuild,v 1.8 2011/05/19 22:18:17 ssuominen Exp $

EAPI=4
inherit xfconf

DESCRIPTION="GTK+ based CD and DVD burning application"
HOMEPAGE="http://goodies.xfce.org/projects/applications/xfburn"
SRC_URI="mirror://xfce/src/apps/${PN}/0.4/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ppc x86"
IUSE="dbus debug gstreamer thunar"

RDEPEND=">=dev-libs/libburn-0.4.2
	>=dev-libs/libisofs-0.6.2
	>=x11-libs/gtk+-2.10:2
	x11-themes/hicolor-icon-theme
	>=xfce-base/libxfcegui4-4.8
	>=xfce-base/exo-0.6
	dbus? ( >=dev-libs/dbus-glib-0.88 )
	gstreamer? ( media-libs/gstreamer:0.10
		>=media-libs/gst-plugins-base-0.10.20:0.10 )
	thunar? ( xfce-extra/thunar-vfs )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	dev-util/intltool
	sys-devel/gettext"

pkg_setup() {
	XFCONF=(
		$(use_enable dbus)
		$(xfconf_use_debug)
		$(use_enable gstreamer)
		--disable-hal
		$(use_enable thunar thunar-vfs)
		)

	DOCS=( AUTHORS ChangeLog NEWS README TODO )
}
