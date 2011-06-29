# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit distutils eutils

DESCRIPTION="Storage protocol and wrapper libraries for the Ubuntu One file storage/sharing service."
HOMEPAGE="https://launchpad.net/ubuntuone-storage-protocol"
SRC_URI="http://launchpad.net/${PN}/trunk/lucid-final/+download/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-libs/protobuf[python]"
RDEPEND="${DEPEND}
	>=dev-python/oauth-1.0
	dev-python/pyopenssl
	dev-python/twisted
	dev-python/pyxdg
	virtual/python"

RESTRICT="mirror"

src_prepare() {
	epatch "${FILESDIR}"/${P}-fix_collision.patch
}
