# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit xdg

DESCRIPTION="A cross-platform soundboard 🔊"
HOMEPAGE="https://soundux.rocks/"
SRC_URI="https://github.com/Soundux/Soundux/releases/download/${PV}/soundux-${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="pipewire"

DEPEND="dev-libs/libappindicator:3
	dev-util/pkgconf
	media-sound/pulseaudio
	pipewire? ( media-video/pipewire )
	net-libs/webkit-gtk
	sys-apps/lsb-release
	x11-libs/libwnck:3"
RDEPEND="${DEPEND}"

src_unpack() {
	default
	mv ${WORKDIR}/Soundux ${S}
}

src_compile() {
	cd ${S}
	mkdir -p build
	cd build
	cmake -GNinja -DCMAKE_BUILD_TYPE=Release ..
	ninja
}

src_install() {
	cd ${S}/build
	DESTDIR="${D}" ninja install
	mkdir -p "${D}/usr/bin"
	ln -sf "${D}/opt/soundux/soundux" "${D}/usr/bin/soundux"
}

pkg_postinst() {
	optfeature "Downloader integration" media-video/ffmpeg
	optfeature "Unmaintained downloader integration" net-misc/youtube-dl
}
