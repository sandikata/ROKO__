# Copyright 2014 deterenkelt
# Distributed under the terms of the GNU General Public License v3
# $Header: $

EAPI="5"
inherit eutils

SLOT="0"
DESCRIPTION="A tool for creating graphical dialogs from shell scripts. Fork of zenity."
HOMEPAGE="http://sourceforge.net/projects/yad-dialog/"
SRC_URI="http://sourceforge.net/projects/yad-dialog/files/latest/download?source=files -> ${P}.tar.xz"
LICENSE="GPL-3"
KEYWORDS="~*"
IUSE=""

RDEPEND="x11-libs/gtk+:2
		 dev-libs/glib:2"
DEPEND="${RDEPEND}
		|| ( dev-util/pkgconfig dev-util/pkgconf )
		sys-devel/gettext
		dev-util/intltool
		app-arch/xz-utils"

src_prepare() {
	epatch_user
}

src_configure() {
	econf \
		--disable-deprecated
}
