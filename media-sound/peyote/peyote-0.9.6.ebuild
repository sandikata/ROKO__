# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

DESCRIPTION=""
HOMEPAGE="http://peyote.sourceforge.net/"
SRC_URI="ftp://calculate.linuxmaniac.net/pub/files/peyote_0.9.6.tar.bz2"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
DEPEND="media-libs/mutagen dev-python/pygobject dev-python/dbus-python dev-python/notify-python"
RDEPEND="${DEPEND}"

src_configure() {
	src_configure
}
src_install() {
	src_install
}
