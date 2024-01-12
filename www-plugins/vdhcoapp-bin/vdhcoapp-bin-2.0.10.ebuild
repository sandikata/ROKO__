# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MULTILIB_COMPAT=( abi_x86_{32,64} )
MY_PN="${PN/-bin/}"

inherit multilib-build pax-utils unpacker

DESCRIPTION="Companion application for Video DownloadHelper browser add-on"
HOMEPAGE="https://github.com/aclap-dev/vdhcoapp"
SRC_URI="
	amd64? ( https://github.com/aclap-dev/${MY_PN}/releases/download/v${PV}/vdhcoapp-${PV}-linux-x86_64.deb )
	x86? ( https://github.com/aclap-dev/${MY_PN}/releases/download/v${PV}/vdhcoapp-${PV}-linux-i686.deb )"

LICENSE="GPL-2"
KEYWORDS="-* ~amd64 ~x86"
SLOT="0"
IUSE="+abi_x86_64"
RESTRICT="bindist mirror strip"

RDEPEND="media-video/ffmpeg:=[${MULTILIB_USEDEP}]"

S="${WORKDIR}"

QA_PREBUILT="opt/vdhcoapp/vdhcoapp"

src_install() {
	local arch
	arch="$(usex amd64 "64" "32")"

	keepdir /etc/chromium/native-messaging-hosts \
		/etc/opt/chrome/native-messaging-hosts \
		/usr/lib/mozilla/native-messaging-hosts

	insinto /opt/vdhcoapp
	exeinto /opt/vdhcoapp
	doexe opt/vdhcoapp/{vdhcoapp,xdg-open}
	dodir /opt/vdhcoapp/converter/build/linux/"${arch}"
	dosym ../../../../../../usr/bin/ffmpeg \
		opt/vdhcoapp/converter/build/linux/"${arch}"/ffmpeg
	dosym ../../../../../../usr/bin/ffplay \
		opt/vdhcoapp/converter/build/linux/"${arch}"/ffplay
	dosym ../../../../../../usr/bin/ffprobe \
		opt/vdhcoapp/converter/build/linux/"${arch}"/ffprobe

	dodir /opt/bin
	dosym ../vdhcoapp/vdhcoapp \
		opt/bin/vdhcoapp

	pax-mark -m "${ED}"/opt/vdhcoapp/vdhcoapp
}

pkg_postinst() {
	/opt/bin/vdhcoapp install --system || die "install failed"
}
