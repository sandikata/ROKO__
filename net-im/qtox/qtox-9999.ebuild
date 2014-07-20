# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils git-2

DESCRIPTION="qTox"
HOMEPAGE="https://github.com/tux3/qtox"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE=""

EGIT_REPO_URI="git://github.com/tux3/qtox.git"

DEPEND="
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtmultimedia:5
	dev-qt/qtconcurrent:5
	net-libs/tox[av]"

RDEPEND="
	${DEPEND}
	media-plugins/gst-plugins-meta:0.10[opus,vpx,v4l]"

src_configure() {
	/usr/lib64/qt5/bin/qmake
}

src_install() {
	dobin "${S}/qtox" || die "qTox not found!"
	doicon -s scalable "${FILESDIR}"/tox.svg
	make_desktop_entry "qtox" "qTox" "/usr/share/icons/hicolor/scalable/apps/tox.svg" "Network"
}
