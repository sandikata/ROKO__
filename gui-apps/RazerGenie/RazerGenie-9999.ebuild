# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

EGIT_REPO_URI="https://github.com/z3ntu/${PN}.git"

inherit git-r3 meson

DESCRIPTION="Razer devices configurator"
HOMEPAGE="https://github.com/z3ntu/RazerGenie"
SRC_URI=""

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""

RDEPEND="dev-libs/libopenrazer
	dev-qt/qtcore:5
	dev-qt/qtdbus:5
	dev-qt/qtnetwork:5
	dev-qt/qtgui:5
	dev-qt/qtwidgets:5"
BDEPEND="dev-qt/linguist-tools:5
	virtual/pkgconfig"
