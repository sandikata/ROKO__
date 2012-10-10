# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

DESCRIPTION="Remote Desktop Viewer"
HOMEPAGE="http://teamviewer.com/"
SRC_URI="ftp://calculate-linuxmaniac.tk/pub/downloads/teamviewer-6.0.9258-1-x86_64.pkg.tar.xz"

LICENSE=""
SLOT="stable"
KEYWORDS="amd64"
IUSE=""

DEPEND=">=x11-base/xorg-server-1.10"
RDEPEND="${DEPEND}"

src_install() {
	cd "${WORKDIR}"
	cp -R * "${D}/" || die "install failed"
}
