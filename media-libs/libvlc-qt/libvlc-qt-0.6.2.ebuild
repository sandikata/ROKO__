# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit cmake-utils 

DESCRIPTION="VLC-Qt is a free library used to connect Qt and libvlc libraries."
HOMEPAGE="http://tano.si/en/vlc-qt"
RESTRICT="mirror"
SRC_URI="http://download.tano.si/${PN/lib/}/${PV}/${PN}_${PV}_src.tar.gz"
#EGIT_REPO_URI="git://github.com/ntadej/vlc-qt"
#EGIT_BRANCH="master"
#EGIT_COMMIT="$PV"


LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
   app-doc/doxygen
   >=x11-libs/qt-core-4.6
   media-video/vlc
"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${P}"
