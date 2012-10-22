# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit cmake-utils eutils #versionator git 

#C_PV=$(get_version_component_range 1-2)
DESCRIPTION="Tano can play almost every multimedia file, including SD and HD IP
Television channels"
HOMEPAGE="http://tano.si/"
#EGIT_REPO_URI="git://github.com/ntadej/tano"
#EGIT_BRANCH="$C_PV"
#EGIT_COMMIT="$PV"
RESTRICT="mirror"


#SRC_URI="https://github.com/ntadej/${PN}/tarball/${PV} -> ${P}.tar.gz"
SRC_URI="mirror://sourceforge/${PN}/Tano%20Player/${PV}/${P/-/_}_src.tar.gz
	http://download.tano.si/tano/${PV/_/-}/${PN}_${PV/_/-}_src.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=media-libs/libvlc-qt-0.6.1"
RDEPEND="${DEPEND}"

#S="${WORKDIR}/${PN}-1.0~git20120503~beta1"

src_unpack() {
	unpack ${A}
	S=`dirname ${WORKDIR}/*/CMakeLists.txt`
	pwd
	cd ${S}
	pwd
}

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
