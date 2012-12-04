# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="MintMenu supports filtering, favorites, easy-uninstallation, autosession, and many other features."
SRC_URI="http://packages.linuxmint.com/pool/main/m/mintmenu/${PN}_${PV}.tar.gz
	awn? ( http://ppa.launchpad.net/neelance/awn/ubuntu/pool/main/a/awn-mintmenu/awn-${PN}_1.0-2.tar.gz )"
MINT_TRANSLATIONS="mint-translations_2011.02.01.tar.gz"
LANG_URL="http://packages.linuxmint.com/pool/main/m/mint-translations/${MINT_TRANSLATIONS}"
HOMEPAGE="http://linuxmint.com
	https://launchpad.net/~neelance/+archive/awn"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE="portato terminal awn"

LANGS="af am ar ast be ber bg bn bs ca ckb csb cs cy da de el en_AU en_CA en_GB eo es et eu fa fi fo fr gl gv"
LANGS="${LANGS} he hi hr hu hy id is it ja jv kk kn ko lt lv mk ml mr ms nb nds nl nn oc pa pl pt_BR pt ro ru"
LANGS="${LANGS} si sk sl sq sr sv ta te th tr uk ur vi zh_CN zh_HK zh_TW"

for X in ${LANGS} ; do
	IUSE="${IUSE} linguas_${X}"
	SRC_URI="${SRC_URI} linguas_${X}? ( ${LANG_URL} )"
done

RDEPEND=">=dev-lang/python-2.4.6
	<dev-lang/python-3.1.1-r1
	dev-python/pygtk
	dev-python/gnome-desktop-python
	dev-python/pyxdg
	x11-misc/alacarte
	gnome-extra/deskbar-applet
	terminal? ( x11-terms/gnome-terminal )
	portato? ( app-portage/portato )
	awn? ( gnome-extra/avant-window-navigator )"

DEPEND="${RDEPEND}
	sys-apps/sed"

S="${WORKDIR}"

src_install() {
	dobin mintmenu/usr/bin/mintmenu
	dodir /usr/lib/linuxmint/mintMenu
	insinto /usr/lib/linuxmint/mintMenu
	cp -R mintmenu/usr/lib/linuxmint/mintMenu/* ${D}usr/lib/linuxmint/mintMenu
	dodir /usr/lib/bonobo/servers
	insinto /usr/lib/bonobo/servers
	doins mintmenu/usr/lib/bonobo/servers/mintMenu.server
	dodoc mintmenu/debian/changelog mintmenu/debian/control

	[[ -f ${MINT_TRANSLATIONS} ]] && unpack ${MINT_TRANSLATIONS}
	for X in ${LANGS} ; do
	  if use linguas_${X}; then
	    dodir /usr/share/linuxmint/locale/${X}/LC_MESSAGES
	    insinto /usr/share/linuxmint/locale/${X}/LC_MESSAGES
	    doins mint-translations*/usr/share/linuxmint/locale/${X}/LC_MESSAGES/mintmenu.mo
	  fi
	done

	if use awn ; then
		mkdir -p ${D}/usr/share/avant-window-navigator/applets
		cp awn-mintmenu-1.0/mintmenu.desktop ${D}/usr/share/avant-window-navigator/applets
		mkdir -p ${D}/usr/lib/linuxmint/mintMenu
		cp awn-mintmenu-1.0/mintMenuAwn.py ${D}/usr/lib/linuxmint/mintMenu
	fi
}

pkg_preinst() {
	sed -i "s/share\/common\-licenses\/GPL/portage\/licenses\/GPL\-2/" ${D}usr/lib/linuxmint/mintMenu/mintMenu.py
	sed -i "/version.py\ mintmenu/d" ${D}usr/lib/linuxmint/mintMenu/mintMenu.py
	sed -i "s/set_version(version)/set_version(\"${PV}\")/" ${D}usr/lib/linuxmint/mintMenu/mintMenu.py
	sed -i "s/\"use_apt\",\ True/\"use_apt\",\ False/" ${D}usr/lib/linuxmint/mintMenu/plugins/applications.py
	sed -i "/activate\",\ self\.search\_mint\_tutorials\|ideas\|users\|software\|hardware)/,+1d" ${D}usr/lib/linuxmint/mintMenu/plugins/applications.py
	sed -i "s/\"show_software_manager\",\ True/\"show_software_manager\",\ False/" ${D}usr/lib/linuxmint/mintMenu/plugins/system_management.py
	if use terminal; then
	  sed -i "s/x\-terminal\-emulator/gnome\-terminal/" ${D}usr/lib/linuxmint/mintMenu/plugins/system_management.py
	else
	  sed -i "s/\"show_terminal\",\ True/\"show_terminal\",\ False/" ${D}usr/lib/linuxmint/mintMenu/plugins/system_management.py
	fi
	if use portato; then
	  sed -i "s/sbin\/synaptic/bin\/portato/" ${D}usr/lib/linuxmint/mintMenu/plugins/system_management.py
	else
	  sed -i "s/\"show_package_manager\",\ True/\"show_package_manager\",\ False/" ${D}usr/lib/linuxmint/mintMenu/plugins/system_management.py
	fi
}

