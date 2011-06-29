# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
GCONF_DEBUG="no"

inherit gnome2

DESCRIPTION="GNOME panel applet to display readings from hardware sensors"
HOMEPAGE="http://sensors-applet.sourceforge.net/"
SRC_URI="mirror://sourceforge/sensors-applet/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+dbus hddtemp libnotify lm_sensors video_cards_fglrx video_cards_nvidia"

RDEPEND="
	>=dev-libs/glib-2.14
	>=x11-libs/gtk+-2.14
	>=gnome-base/gnome-panel-2
	>=gnome-base/libgnome-2.8
	>=gnome-base/libgnomeui-2.8
	>=x11-libs/cairo-1.0.4
	hddtemp? (
		dbus? (
			>=dev-libs/dbus-glib-0.80
			>=dev-libs/libatasmart-0.16 )
		!dbus? ( >=app-admin/hddtemp-0.3_beta13 ) )
	libnotify? ( >=x11-libs/libnotify-0.4.0 )
	lm_sensors? ( sys-apps/lm_sensors )
	video_cards_fglrx? ( x11-drivers/ati-drivers )
	video_cards_nvidia? ( || (
		>=x11-drivers/nvidia-drivers-100.14.09
		media-video/nvidia-settings
	) )"

DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.12
	>=app-text/scrollkeeper-0.3.14
	>=app-text/gnome-doc-utils-0.3.2
	dev-util/intltool"
# Requires libxslt only for use by gnome-doc-utils

PDEPEND="hddtemp? ( dbus? ( sys-fs/udisks ) )"

DOCS="AUTHORS ChangeLog NEWS README TODO"

pkg_setup() {
	G2CONF="${G2CONF}
		--disable-scrollkeeper
		--disable-static
		$(use_enable dbus devicekit)
		$(use_enable libnotify)
		$(use_with lm_sensors libsensors)
		$(use_with video_cards_fglrx aticonfig)
		$(use_with video_cards_nvidia nvidia)"

	if use hddtemp; then
		G2CONF="${G2CONF} $(use_enable dbus devicekit)"
	else
		G2CONF="${G2CONF} --disable-devicekit"
	fi
}

src_install() {
	gnome2_src_install

	find "${D}" -name "*.la" -delete || die "failed to delete *.la"
}
