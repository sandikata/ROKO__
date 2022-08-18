# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop git-r3 qmake-utils

EGIT_REPO_URI="https://github.com/Audio4Linux/JDSP4Linux.git"
EGIT_SUBMODULES=(
	"src/subprojects/EELEditor"
	"src/subprojects/GraphicEQWidget"
	"src/subprojects/FlatTabWidget"
	"src/subprojects/LiquidEqualizerWidget"
)

DESCRIPTION="Open-source sound effects for PipeWire and PulseAudio"
HOMEPAGE="https://github.com/Audio4Linux/JDSP4Linux"
LICENSE="GPL-3"
KEYWORDS=""
SLOT="0"
IUSE="pipewire pulseaudio"
REQUIRED_USE="|| ( pipewire pulseaudio )"

DEPEND="
	pipewire? ( >=media-video/pipewire-0.3 )
	!pipewire? ( pulseaudio? (
		media-sound/pulseaudio
		media-libs/gstreamer
		media-libs/gst-plugins-base
	) )
	app-arch/libarchive
	>=dev-cpp/glibmm-2.4:2
	>=dev-libs/glib-2.0
	dev-qt/qtcore:5
	dev-qt/qtdbus:5
	dev-qt/qtgui:5
	dev-qt/qtnetwork:5
	dev-qt/qtsvg:5
	dev-qt/qtxml:5
"

RDEPEND="
	${DEPEND}
	!pipewire? ( pulseaudio? ( media-libs/gst-plugins-good ) )
"

BDEPEND="virtual/pkgconfig"

pkg_pretend() {
	if use pipewire && use pulseaudio; then
		ewarn "Ignoring USE=pulseaudio since PipeWire"
		ewarn "(with pipewire-pulse) support is enabled"
	fi
}

src_configure() {
	local eqmakeargs=(
		CONFIG$(usex pipewire - $(usex pulseaudio + -))=USE_PULSEAUDIO
		DEFINES$(usex elibc_musl + -)=NO_CRASH_HANDLER
	)

	eqmake5 JDSP4Linux.pro "${eqmakeargs[@]}"
}

src_install() {
	dobin "${S}/src/jamesdsp"
	newicon ${S}/resources/icons/icon.svg jamesdsp.svg
	make_desktop_entry /usr/bin/jamesdsp JamesDSP /usr/share/pixmaps/jamesdsp.svg "Audio;AudioVideo"
}
