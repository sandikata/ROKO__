# Copyright 2008-2012 Funtoo Technologies
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

DESCRIPTION="Програма за запис на работния плот."
HOMEPAGE=""
SRC_URI="ftp://calculate.linuxmaniac.net/pub/downloads/recordscreen-0.1.tar.xz"

LICENSE="GPL"
SLOT="testing"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="<=media-video/ffmpeg-0.7.8
		>=media-sound/pulseaudio-0.9.22"
RDEPEND="${DEPEND}"

src_install() {
	cd "${WORKDIR}"
	cp -R * "${D}/"
	elog "За да използвате програмата изпълнете в терминала 'recordscreen.py /Директория/file.mkv'"
}
