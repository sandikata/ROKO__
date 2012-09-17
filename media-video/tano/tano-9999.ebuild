# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit cmake-utils eutils git 

DESCRIPTION="Tano can play almost every multimedia file, including SD and HD IP
Television channels"
HOMEPAGE="http://tano.si/"
EGIT_REPO_URI="git://github.com/ntadej/tano"
EGIT_BRANCH="master"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND="media-libs/libvlc-qt"
RDEPEND="${DEPEND}"

src_install()
{
	cd ${WORKDIR}/${P}_build
	emake install DESTDIR="${D}" || die "Install failed"
	cd ${S}
	dodoc NEWS README VERSION || die "dodoc failed"
	newicon data/logo/48x48/logo.png ${PN}.png
	insinto /usr/share/applications
	doins tano.desktop
}
