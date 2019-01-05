# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils unpacker

DESCRIPTION="Flash OS images to SD cards & USB drives, safely and easily."
HOMEPAGE="https://etcher.io/"
SRC_URI="https://github.com/resin-io/${PN}/releases/download/v${PV}/${PN}-electron_${PV}_amd64.deb"

LICENSE="GPL2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="dev-libs/nss
	gnome-base/gconf
	media-libs/alsa-lib
	sys-apps/lsb-release
	x11-libs/gtk+:2
	x11-libs/libXtst
	x11-libs/libnotify"
RDEPEND="${DEPEND}"

RESTRICT="mirror"

S="${WORKDIR}"

src_unpack() {
	unpack_deb ${A}
}

src_install() {
	mv * "${D}" || die
	sed -i "s/Utility/System/g" "${D}"usr/share/applications/"${PN}"-electron.desktop
	fperms 0755 /opt/Etcher/"${PN}"-electron || die
}
