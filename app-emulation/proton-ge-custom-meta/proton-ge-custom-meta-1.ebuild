# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Meta package for proton-ge-custom-bin, make it easier to pull in dependencies"
HOMEPAGE="https://github.com/GloriousEggroll/proton-ge-custom"
SRC_URI=""
LICENSE="metapackage"

SLOT="0"
KEYWORDS="~amd64"
IUSE="kde gnome"

DEPEND=""

# converted and modified from AUR proton-ge-custom-bin 601fc5f2
# python-kivy is missing
RDEPEND="
	dev-lang/python-exec
	media-libs/vulkan-loader[abi_x86_32]
	virtual/libusb[abi_x86_32]
	media-libs/openal[abi_x86_32]
	x11-libs/libva[abi_x86_32]
	media-video/ffmpeg
	media-libs/speex[abi_x86_32]
	media-libs/libtheora[abi_x86_32]
	x11-libs/libvdpau[abi_x86_32]
	media-libs/gst-plugins-bad
	media-libs/gst-plugins-base[abi_x86_32]
	media-libs/libjpeg-turbo[abi_x86_32]
	dev-libs/libgudev[abi_x86_32]
	media-libs/flac[abi_x86_32]
	media-sound/mpg123[abi_x86_32]

	kde? ( kde-apps/kdialog )
	gnome? ( gnome-extra/zenity )

	app-emulation/winetricks
	virtual/wine[abi_x86_32]
	app-emulation/proton-ge-custom-bin
	games-util/steam-meta"

pkg_pretend() {
	einfo "The list of dependencies may be not complete, and some of ones listed may be not necessary. Feel free to try it on your favourite games and any issue & pull request is welcome."
}
