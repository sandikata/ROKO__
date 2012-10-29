# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit cmake-utils nsplugins multilib git

DESCRIPTION="High performance flash player"
HOMEPAGE="https://launchpad.net/lightspark/"
#EGIT_REPO_URI="git://github.com/alexp-sssup/lightspark.git"
EGIT_REPO_URI="git://github.com/lightspark/lightspark.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="curl ffmpeg gles nsplugin profile pulseaudio rtmp sdl"

RDEPEND=">=dev-cpp/libxmlpp-2.33.1:2.6
	>=dev-libs/boost-1.42
	dev-libs/libpcre[cxx]
	media-fonts/liberation-fonts
	media-libs/libsdl
	|| (
		>=sys-devel/llvm-3
		=sys-devel/llvm-2.8*
	)
	x11-libs/cairo
	x11-libs/gtk+:2
	x11-libs/libX11
	x11-libs/pango
	curl? (
		net-misc/curl
	)
	ffmpeg? (
		virtual/ffmpeg
	)
	!gles? (
		>=media-libs/glew-1.5.3
		virtual/opengl
	)
	gles? (
		media-libs/mesa[gles2]
	)
	pulseaudio? (
		media-sound/pulseaudio
	)
	rtmp? (
		media-video/rtmpdump
	)"
DEPEND="${RDEPEND}
	amd64? ( dev-lang/nasm )
	x86? ( dev-lang/nasm )
	virtual/pkgconfig"

src_prepare() {
	# Fix gcc complaint about undefined debug variable
#	if ! use debug; then
#		epatch "${FILESDIR}"/${PN}-0.4.1-debug-defines.patch
#	fi

	# Adjust plugin permissions
	sed -i "s|FILES|PROGRAMS|" CMakeLists.txt || die

	# Adjust font paths
	sed -i "s|truetype/ttf-liberation|liberation-fonts|" src/swf.cpp || die
}

src_configure() {
	local mycmakeargs="$(cmake-utils_use nsplugin COMPILE_PLUGIN)
		-DPLUGIN_DIRECTORY=/usr/$(get_libdir)/${PN}/plugins"

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	use nsplugin && inst_plugin /usr/$(get_libdir)/${PN}/plugins/liblightsparkplugin.so
}
