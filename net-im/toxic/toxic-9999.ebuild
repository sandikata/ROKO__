# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI=5

inherit autotools eutils git-2

DESCRIPTION="CLI Frontend for Tox"
HOMEPAGE="http://wiki.tox.im/Toxic"
EGIT_REPO_URI="git://github.com/Tox/toxic
                                https://github.com/Tox/toxic"
LICENSE="GPL-3"
SLOT="0"
IUSE=""

RDEPEND="net-libs/tox
                dev-libs/check
                dev-libs/libconfig
                net-libs/tox
                media-libs/openal
                sys-libs/ncurses"

DEPEND="${RDEPEND}
                dev-libs/libconfig
                virtual/pkgconfig
                sys-devel/libtool"

src_install() {
                cd "${S}/build"
                make PREFIX="/usr"
                emake install PREFIX="/usr" DESTDIR="${D}"
}
pkg_postinst() {
                elog "DHT node list is available in /usr/share/${PN}/DHTnodes"
}

