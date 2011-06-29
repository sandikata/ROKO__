# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

DESCRIPTION="Meta package for the GNOME desktop, merge this package to install"
HOMEPAGE="http://www.gnome.org/"

LICENSE="as-is"
SLOT="2.0"
KEYWORDS="~alpha ~amd64 ~ia64 ~ppc64 ~sparc ~x86 ~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="+automount +indicator networkmanager +notify-osd +themes"

RDEPEND="!gnome-base/gnome

	>=dev-libs/glib-2.24.1
	>=x11-libs/gtk+-2.20.1
	>=dev-libs/atk-1.30.0
	>=x11-libs/pango-1.28.1

	>=gnome-base/orbit-2.14.18

	=x11-libs/libwnck-${PV}*
	=x11-wm/metacity-${PV}*

	>=gnome-base/gconf-2.28.0

	>=gnome-base/libbonobo-2.24.3
	>=gnome-base/libbonoboui-2.24.3
	=gnome-base/libgnome-${PV}*
	>=gnome-base/libgnomeui-2.24.3
	=gnome-base/libgnomecanvas-${PV}*
	>=gnome-base/libglade-2.6.4

	=gnome-base/gnome-settings-daemon-${PV}*
	=gnome-base/gnome-control-center-${PV}*

	=gnome-base/nautilus-${PV}*

	=gnome-base/gnome-desktop-${PV}*
	=gnome-base/gnome-session-${PV}*
	=gnome-base/gnome-panel-${PV}*

	=x11-themes/gnome-icon-theme-${PV}*
	=x11-themes/gnome-themes-${PV}*

	=x11-terms/gnome-terminal-${PV}*

	>=gnome-base/librsvg-2.26.3

	=gnome-extra/yelp-${PV}*"
RDEPEND="${RDEPEND}
	!gnome-base/gnome-light

	=app-crypt/seahorse-${PV}*
	=gnome-base/gnome-applets-${PV}*
	x11-misc/alacarte

	media-plugins/gst-plugins-meta
	=gnome-extra/gnome-media-${PV}*
	=media-video/totem-${PV}*
	=media-video/cheese-${PV}*

	=app-arch/file-roller-${PV}*
	>=gnome-extra/gconf-editor-2.28
	=app-text/evince-${PV}*
	=gnome-extra/gucharmap-${PV}*
	=gnome-extra/gnome-utils-${PV}*
	>=gnome-extra/gnome-system-monitor-2.28

	>=gnome-base/gdm-2.20
	=gnome-extra/gnome-power-manager-${PV}*
	=gnome-extra/gnome-screensaver-${PV}*

	indicator? (
		gnome-extra/indicator-me
		gnome-extra/indicator-session
		gnome-extra/indicator-sound
		net-im/indicator-messages )

	networkmanager? (
		gnome-extra/nm-applet
		net-misc/networkmanager-openvpn
		net-misc/networkmanager-pptp )

	notify-osd? ( x11-misc/notify-osd )

	themes? ( x11-themes/gnome-themes-ubuntu
		x11-themes/light-themes )"
DEPEND=""
PDEPEND=">=gnome-base/gvfs-1.6.2
	automount? ( >=gnome-base/gvfs-1.6.2[gdu] )"

S=${WORKDIR}

pkg_postinst () {
	elog "Use gnome-base/gnome for the full GNOME Desktop"
	elog "as released by the GNOME team."
}
