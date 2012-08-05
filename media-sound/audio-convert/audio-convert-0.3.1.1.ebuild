# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="Convert wav, ogg, mp3, mpc, flac, ape, aac or wma files into wav, ogg, mp3, mpc, flac, ape or aac files"
HOMEPAGE="https://savannah.nongnu.org/projects/audio-convert"
SRC_URI="http://download.savannah.gnu.org/releases/audio-convert/audio-convert-0.3.1.1.tar.gz"
RESTRICT="nomirror"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=""
RDEPEND="app-shells/bash
	>=sys-apps/file-4.16
	media-video/mplayer
	gnome-extra/zenity
	sys-apps/gawk
	media-sound/lame
	media-sound/vorbis-tools
	media-libs/libid3tag
	media-sound/musepack-tools
	media-libs/flac
	media-libs/faac
	media-libs/faad2"

src_install() {
    dobin audio-convert
}
