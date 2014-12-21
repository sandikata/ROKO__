# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit cmake-utils git-2

DESCRIPTION="Simple but powerful Qt5-based image viewer"
HOMEPAGE="http://photoqt.org"
#SRC_URI="http://photoqt.org/pkgs/${P}.tar.gz"
EGIT_REPO_URI="git://github.com/luspi/photoqt-dev.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"

DEPEND="dev-qt/qtmultimedia:5
		dev-qt/qtimageformats:5
		dev-qt/qtgui:5
		dev-qt/qtnetwork:5
		dev-qt/qtwidgets:5
		dev-qt/linguist:5
		dev-qt/linguist-tools:5
		dev-qt/qtsql:5
		dev-qt/qtsvg:5
		media-gfx/graphicsmagick
		media-gfx/exiv2"
RDEPEND="${DEPEND}"

pkg_postinst() {
	ewarn "This version of the photoqt is masked while Gentoo Team unmasks qt:5"
}
