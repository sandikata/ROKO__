# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit 
EAPI=3

DESCRIPTION="Firefox Уеб Браузър. Неофициална версия без никакви добавки и
кръпки."
HOMEPAGE="http://firefox.com/"
SRC_URI=""
REL_URI="http://releases.mozilla.org/pub/mozilla.org/firefox/releases"
FTP_URI="ftp://ftp.mozilla.org/pub/firefox/releases/"

LICENSE=""
SLOT="0"
KEYWORDS="amd64"
IUSE="libnotify startup-notification wifi alsa pulseaudio"

DEPEND="
		>=sys-devel/binutils-2.16.1
		>=dev-libs/nss-3.12.9
		>=dev-libs/nspr-4.8.7
		>=dev-libs/glib-2.26
		>=media-libs/mesa-7.10
		media-libs/libpng[apng]
		dev-libs/libffi
		>=media-sound/pulseaudio-0.9.22
		=dev-lang/python-2*[sqlite]
		>=sys-devel/gcc-4.5
		"
RDEPEND="${DEPEND}"

src_unpack() {
        src_unpack
}

pkg_postinst() {
		pkg_postinst
}

