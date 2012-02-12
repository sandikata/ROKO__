# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit git-2 eutils
EAPI=3

DESCRIPTION="PNMixer is a fork of OBMixer"
HOMEPAGE="https://github.com/nicklan/pnmixer"
SRC_URI=""
EGIT_REPO_URI="git://github.com/nicklan/pnmixer.git"

LICENSE=""
SLOT="0"
KEYWORDS="**"
IUSE="alsa pulseaudio"

DEPEND="x11-libs/gtk+
alsa? ( >=media-libs/alsa-lib-1.0.24 >=media-plugins/alsa-plugins-1.0.24 >=media-sound/alsa-headers-1.0.24 >=media-sound/alsa-utils-1.0.24 )
pulseaudio? ( >=media-sound/pulseaudio-0.9.22 >=media-plugins/alsa-plugins-1.0.24[pulseaudio] )"
RDEPEND="${DEPEND}"

src_compile() {
	        eautoreconf
			./autogen.sh
			econf || die "configure failed"
			emake || die "make failed"
}

src_install() {
	einstall || die
}

