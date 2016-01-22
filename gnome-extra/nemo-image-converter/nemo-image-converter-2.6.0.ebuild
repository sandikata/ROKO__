# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit autotools eutils

DESCRIPTION="nemo extension to mass resize or rotate images"
HOMEPAGE="https://github.com/linuxmint/nemo-extensions"
SRC_URI="https://github.com/linuxmint/nemo-extensions/archive/2.6.x.tar.gz"
S="${WORKDIR}/nemo-extensions-2.6.x/${PN}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="gnome-base/gnome-common"
DEPEND=">=gnome-extra/nemo-2.6.0[introspection]"

src_prepare() {
	eautoreconf
}
