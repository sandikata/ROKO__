# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: 

EAPI="4"

inherit gnome2-utils

DESCRIPTION="Mint-X Icon themes"
HOMEPAGE="http://packages.linuxmint.com/pool/main/m/mint-x-icons/"
SRC_URI="http://packages.linuxmint.com/pool/main/m/${PN}/${PN}_${PV}.tar.gz
		 branding? ( http://www.mail-archive.com/tango-artists@lists.freedesktop.org/msg00043/tango-gentoo-v1.1.tar.gz )"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="branding"

RDEPEND=""

RESTRICT="binchecks strip"

S=${WORKDIR}

src_prepare() {
	# Removing symlink to not existing file
	for i in 16 22 24 32 48; do
		rm "${S}"/${PN}/usr/share/icons/Mint-X/apps/${i}/internet-mail.png
	done
	rm "${S}"/${PN}/usr/share/icons/Mint-X/apps/scalable/internet-mail.svg
	# Fixing files that makes gtk-icon-cache-update to crash
	rm "${S}/${PN}/usr/share/icons/Mint-X/apps/scalable/cairo-dock -o.svg"
	cd "${S}"/${PN}/usr/share/icons/Mint-X/apps/scalable/
	mv "cairo-dock -c.svg" "cairo-dock.svg"
	# Installing gentoo logos
	if use branding; then
    	for i in 16 22 24 32 48; do
        	cp "${WORKDIR}"/tango-gentoo-v1.1/${i}x${i}/gentoo.png \
            "${S}"/${PN}/usr/share/icons/Mint-X/places/${i}/start-here.png \
			|| die "Copying gentoo logos failed"
        done
        for i in 22 24; do
        	cp "${WORKDIR}"/tango-gentoo-v1.1/${i}x${i}/gentoo.png \
            "${S}"/${PN}/usr/share/icons/Mint-X-Dark/places/${i}/start-here-gentoo.png \
			|| die "Copying gentoo logos failed"
			rm "${S}"/${PN}/usr/share/icons/Mint-X-Dark/places/${i}/start-here.png
			cd "${S}"/${PN}/usr/share/icons/Mint-X-Dark/places/${i}/
			ln -s start-here-gentoo.png start-here.png
        done
	fi
}

src_install() {
	insinto /usr/share/icons
	doins -r mint-x-icons/usr/share/icons/Mint-X{,-Dark}
	insinto /usr/share/pixmaps
	doins -r mint-x-icons/usr/share/pixmaps/pidgin
	dodoc mint-x-icons/debian/changelog  mint-x-icons/debian/copyright
}

pkg_preinst() { gnome2_icon_savelist; }
pkg_postinst() { gnome2_icon_cache_update; }
pkg_postrm() { gnome2_icon_cache_update; }
