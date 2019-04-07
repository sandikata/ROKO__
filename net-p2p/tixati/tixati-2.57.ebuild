# Copyright 2016-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

inherit desktop
inherit xdg

DESCRIPTION="Tixati is a New and Powerful P2P System"
HOMEPAGE="https://www.tixati.com"
LICENSE="tixati" # bundled in the binary, available in menu "About -> License Agreement"

SLOT="0"
src_uri_base="https://www.tixati.com/download/${P}-1.@ARCH@.manualinstall.tar.gz"
SRC_URI="
	amd64?	( ${src_uri_base//@ARCH@/x86_64} )
"

KEYWORDS="-* ~amd64"

RDEPEND="
	sys-apps/dbus:0
	dev-libs/dbus-glib:0
	dev-libs/glib:2
	x11-libs/gtk+:2
	x11-libs/pango:0
	sys-libs/zlib:0
"

RESTRICT="mirror"

S="${WORKDIR}/${A%.tar.gz}"

QA_PRESTRIPPED="/usr/bin/${PN}"

pkg_pretend() {
	ewarn ""
	ewarn "You're trying to install '${PN}'."
	ewarn "Please note that this app is not libre and is not even open-source."
	ewarn "It uses an old statically-linked version of OpenSSL (OpenSSL 1.0.0e 6 Sep 2011)."
	ewarn "Use at your own discretion, you have been warned."
	ewarn ""
}

src_install() {
	dobin	"${PN}"
	doicon	-s 48 "${PN}.png"

	# fix invalid `Categories` value
	rsed -e 's|Internet;||' -i -- "${PN}.desktop"
	domenu	"${PN}.desktop"
}
