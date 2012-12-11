# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="MintMenu supports filtering, favorites, easy-uninstallation, autosession, and many other features."
SRC_URI="http://packages.linuxmint.com/pool/main/m/mintmenu/${PN}_${PV}.tar.gz"
HOMEPAGE="https://www.linuxmint.com"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE=""

RDEPEND=">=dev-lang/python-2.4.6
	<dev-lang/python-3.1.1-r1
	dev-python/pygtk
	dev-python/gnome-desktop-python
	dev-python/pyxdg
	x11-misc/alacarte
	"
	

DEPEND="${RDEPEND}
	sys-apps/sed
	net-misc/wget"

src_install() {
	mkdir -p ${D}usr/lib/linuxmint
	cp -r "mintmenu/usr/lib/linuxmint/mintMenu/" "${D}usr/lib/linuxmint/" || die "mintmenu not copied"
	mkdir -p ${D}usr/bin
	cp "mintmenu/usr/bin/mintmenu" "${D}usr/bin/" || die "Bin failed"
	mkdir -p ${D}usr/lib/bonobo/servers
	cp "mintmenu/usr/lib/bonobo/servers/mintMenu.server" "${D}usr/lib/bonobo/servers/" || die "Bonobo failed"
	
	wget http://outload.net/img/gentoo.png || die "Download failed"
	cp "gentoo.png" "${D}usr/lib/linuxmint/mintMenu/" || die "Branding failed"

	dodoc mintmenu/debian/changelog mintmenu/debian/control
}

pkg_preinst() {
	sed -i "s/mintMenu.png/gentoo.png/g" ${D}usr/lib/linuxmint/mintMenu/mintMenu.py
	sed -i "s/\"applet_text\",\ \"Menu\"/\"applet_text\",\ \"Gentoo\"/g" ${D}usr/lib/linuxmint/mintMenu/mintMenu.py
	sed -i "s/\"show_software_manager\",\ True/\"show_software_manager\",\False/g" ${D}usr/lib/linuxmint/mintMenu/plugins/system_management.py
	sed -i "s/\"show_package_manager\",\ True/\"show_package_manager\",\False/g" ${D}usr/lib/linuxmint/mintMenu/plugins/system_management.py
}
