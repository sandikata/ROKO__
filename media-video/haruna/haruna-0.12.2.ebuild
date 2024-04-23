# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake xdg

MY_P="${PN}-v${PV}"

DESCRIPTION="Video player built with Qt/QML on top of libmpv"
HOMEPAGE="https://invent.kde.org/multimedia/haruna"
SRC_URI="https://invent.kde.org/multimedia/${PN}/-/archive/v${PV}/${MY_P}.tar.gz"

LICENSE="GPL-3"
KEYWORDS="~amd64 ~x86"
SLOT="0"

RDEPEND="dev-qt/qtconcurrent:5
	dev-qt/qtcore:5
	dev-qt/qtdbus:5
	dev-qt/qtdeclarative:5
	dev-qt/qtgui:5
	dev-qt/qtnetwork:5
	dev-qt/qtquickcontrols2:5
	dev-qt/qtwidgets:5
	dev-qt/qtx11extras:5
	dev-qt/qtxml:5
	kde-frameworks/breeze-icons:5
	kde-frameworks/kconfig:5
	kde-frameworks/kcoreaddons:5
	kde-frameworks/kfilemetadata:5
	kde-frameworks/ki18n:5
	kde-frameworks/kiconthemes:5
	kde-frameworks/kio:5
	kde-apps/kio-extras:5
	kde-frameworks/kirigami:5
	kde-frameworks/kxmlgui:5
	kde-frameworks/qqc2-desktop-style:5
	media-video/mpv[libmpv]
	net-misc/yt-dlp"
DEPEND="${RDEPEND}"
BDEPEND="kde-frameworks/extra-cmake-modules
	sys-devel/gettext"

S="${WORKDIR}/${MY_P}"

src_configure() {
	local mycmakeargs=(
		-DKDE_INSTALL_DOCBUNDLEDIR="${EPREFIX}/usr/share/help"
	)
	cmake_src_configure
}
