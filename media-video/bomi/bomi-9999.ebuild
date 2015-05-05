# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils git-r3 qmake-utils

DESCRIPTION="Powerful and easy-to-use multimedia player"
HOMEPAGE="http://bomi.github.io/"
EGIT_REPO_URI="git://github.com/xylosper/bomi.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="cdda jack pulseaudio samba systemd"

RDEPEND="dev-libs/fribidi
	dev-libs/icu
	dev-libs/libchardet
	>=dev-qt/qtcore-5.3
	>=dev-qt/qtdbus-5.3
	>=dev-qt/qtdeclarative-5.3[-gles2]
	>=dev-qt/qtgui-5.3[-gles2]
	>=dev-qt/qtnetwork-5.3
	>=dev-qt/qtopengl-5.3[-gles2]
	>=dev-qt/qtquickcontrols-5.3
	>=dev-qt/qtsql-5.3
	>=dev-qt/qtwidgets-5.3[-gles2]
	>=dev-qt/qtx11extras-5.3
	>=dev-qt/qtxml-5.3
	media-libs/alsa-lib
	>=media-video/ffmpeg-2.4
	media-libs/glew
	>=media-libs/libass-0.12.1
	media-libs/libbluray
	>=media-libs/libquvi-0.9
	media-libs/libdvdread
	media-libs/libdvdnav
	media-sound/mpg123
	x11-libs/libva
	cdda? (
		dev-libs/libcdio
		dev-libs/libcdio-paranoia )
	jack? ( media-sound/jack-audio-connection-kit )
	pulseaudio? ( media-sound/pulseaudio )
	samba? ( net-fs/samba[client] )
	systemd? ( sys-apps/systemd )
	virtual/opengl"
DEPEND="${RDEPEND}
	dev-lang/python
	media-libs/mesa
	sys-apps/sed
	>=sys-devel/gcc-4.9"

src_prepare() {
	#( cd "${S}/src/mpv"; python ./bootstrap.py )
	epatch "${FILESDIR}/gets_declaration.patch"
	sed -i -E 's#^WAFURL\ \ \ \ \ =\ "http://ftp\.waf\.io/pub/release/"\ \+\ WAFRELEASE$#WAFURL\ \ \ \ \ =\ "http://www\.freehackers\.org/~tnagy/release/"\ \+\ WAFRELEASE#' "${S}/src/mpv/bootstrap.py"
}

src_configure() {
	./configure \
		--qtsdk=/usr/$(get_libdir)/qt5 \
		--qmake=/usr/$(get_libdir)/qt5/bin/qmake \
		--prefix=/usr \
		$(use_enable cdda) \
		$(use_enable jack) \
		$(use_enable pulseaudio) \
		$(use_enable samba) \
		$(use_enable systemd) \
		|| die
}

src_install() {
	emake DEST_DIR="${D}" install
	dodoc CHANGES.txt README.md
}
