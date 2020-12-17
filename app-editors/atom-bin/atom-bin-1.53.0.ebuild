# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7,8} )
inherit python-any-r1 unpacker xdg-utils

DESCRIPTION="A hackable text editor for the 21st Century"
HOMEPAGE="https://atom.io/"
SRC_URI="https://github.com/atom/atom/releases/download/v${PV}/atom-amd64.deb -> ${P}.deb"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="!app-editors/atom
	${PYTHON_DEPS}
	dev-vcs/git
	x11-libs/gtk+:3
	virtual/libudev
	dev-libs/libgcrypt
	x11-libs/libnotify
	x11-libs/libXtst
	dev-libs/nss
	gnome-base/gvfs
	x11-misc/xdg-utils
	sys-libs/libcap
	x11-libs/libX11
	x11-libs/libXScrnSaver
	media-libs/alsa-lib
	x11-libs/libxkbfile
	net-misc/curl"

S="${WORKDIR}"

src_unpack() {
	unpack_deb "${P}.deb"
}

src_install() {
	mv "${S}/usr/share/doc/atom" "${S}/usr/share/doc/${PF}"
	cp -a "${S}/usr" "${D}/"
}

pkg_postinst() {
	xdg_desktop_database_update
}

pkg_postrm() {
	xdg_desktop_database_update
}
