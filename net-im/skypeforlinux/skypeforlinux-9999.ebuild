# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

DESCRIPTION=""
HOMEPAGE=""
SRC_URI="https://go.skype.com/skypeforlinux-64-alpha.deb"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="dev-libs/atk
	x11-libs/cairo
	net-print/cups
	sys-apps/dbus
	dev-libs/expat
	gnome-base/gconf
	gnome-base/libgnome-keyring
	"
RDEPEND="${DEPEND}"

S="${WORKDIR}"

src_prepare(){
	unpack ${A}
	unpack ./data.tar.xz
}
src_install(){
	cp -R usr "${D}"
}

