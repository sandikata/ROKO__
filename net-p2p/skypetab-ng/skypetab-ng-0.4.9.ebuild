# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

DESCRIPTION="Skype tabs for discusions"
HOMEPAGE="https://github.com/kekekeks/skypetab-ng"
SRC_URI="ftp://calculate.linuxmaniac.net/pub/downloads/skypetab-ng_0.4.9-1_all.tar.gz"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=">=net-im/skype-2.2.0.25"
RDEPEND="${DEPEND}"

src_install(){
	cd "${WORKDIR}"
	cp -R * "${D}/"
}
