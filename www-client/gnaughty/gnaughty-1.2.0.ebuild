# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit gnome2 eutils

DESCRIPTION="Gnaughty is a frontend to the movies section of sublimedirectory.com (aka porn downloader)"
HOMEPAGE="http://gnaughty.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"

RDEPEND=">=net-misc/curl-7.10
	x11-libs/gtk+:2
	dev-libs/glib:2
	gnome-base/gconf:2
	gnome-base/libglade:2.0
	dev-libs/libpcre"

DEPEND="${RDEPEND}
	sys-devel/gettext
	dev-util/pkgconfig"
