# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

EGIT_REPO_URI="https://github.com/z3ntu/${PN^^}.git"

inherit git-r3 meson

DESCRIPTION="Qt wrapper around the D-Bus API from OpenRazer"
HOMEPAGE="https://github.com/z3ntu/libopenrazer"
SRC_URI=""

LICENSE="GPL-3"
KEYWORDS=""
SLOT="0"

RDEPEND="dev-qt/qtcore:5
	dev-qt/qtdbus:5
	dev-qt/qtgui:5
	dev-qt/qtxml:5"
BDEPEND="virtual/pkgconfig"
