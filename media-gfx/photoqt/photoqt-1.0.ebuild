# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit cmake-utils

DESCRIPTION="Simple but powerful Qt4-based image viewer"
HOMEPAGE="http://photoqt.org"
SRC_URI="http://photoqt.org/pkgs/"${PN}"-"${PV}".tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""

DEPEND="media-gfx/exiv2
	dev-qt/qtphonon
	=media-libs/phonon-4.7.2
	media-gfx/graphicsmagick"
RDEPEND="${DEPEND}"
