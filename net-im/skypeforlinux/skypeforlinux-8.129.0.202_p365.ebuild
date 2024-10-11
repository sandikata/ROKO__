# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg multilib-build

DESCRIPTION="Skype extracted from snap package without using snap crap."
HOMEPAGE="https://snapcraft.io/skype"
# fetch snap dl url from:
# curl -H 'Snap-Device-Series: 16' http://api.snapcraft.io/v2/snaps/info/skype
#         "url": "https://api.snapcraft.io/api/v1/snaps/download/QRDEfjn4WJYnm0FzDKwqqRZZI77awQEV_333.snap"
#      },
#      "revision": 333, => patch level (_p)
#      "version": "8.114.0.214" => version
SRC_URI="https://api.snapcraft.io/api/v1/snaps/download/QRDEfjn4WJYnm0FzDKwqqRZZI77awQEV_${PV/#*_p/}.snap -> ${P}.snap"

S="${WORKDIR}/squashfs-root/usr/share/${PN}/"

LICENSE="Skype-TOS MIT MIT-with-advertising BSD-1 BSD-2 BSD Apache-2.0 Boost-1.0 ISC CC-BY-SA-3.0 CC0-1.0 openssl ZLIB APSL-2 icu Artistic-2 LGPL-2.1"
SLOT="0"
KEYWORDS="-* ~amd64"
IUSE="system-ffmpeg system-mesa"

QA_PREBUILT="*"

BDEPEND="sys-fs/squashfs-tools[lzo]"
DEPEND="
	app-accessibility/at-spi2-core:2[${MULTILIB_USEDEP}]
	dev-libs/libayatana-appindicator
	dev-libs/nspr[${MULTILIB_USEDEP}]
	dev-libs/nss[${MULTILIB_USEDEP}]
	media-libs/alsa-lib[${MULTILIB_USEDEP}]
	media-libs/freetype:2[${MULTILIB_USEDEP}]
	media-gfx/graphite2[${MULTILIB_USEDEP}]
	net-print/cups[${MULTILIB_USEDEP}]
	x11-libs/gtk+:3[${MULTILIB_USEDEP}]
	x11-libs/libX11[${MULTILIB_USEDEP}]
	x11-libs/pango[${MULTILIB_USEDEP}]
	system-ffmpeg? ( >=media-video/ffmpeg-6[chromium] )
	system-mesa? ( media-libs/mesa[vulkan] )
"

src_unpack() {
	unsquashfs "${DISTDIR}"/${P}.snap
}

src_install() {
	dodir /opt/${PN}
	cp -a . "${ED}"/opt/${PN} || die

	if use system-ffmpeg; then
		rm "${ED}/opt/${PN}/libffmpeg.so" || die
		dosym "../../usr/$(get_libdir)/chromium/libffmpeg.so" "opt/${PN}/libffmpeg.so" || die
		elog "Using system ffmpeg. This is experimental and may lead to crashes."
	fi

	if use system-mesa; then
		rm "${ED}/opt/${PN}/libEGL.so" || die
		rm "${ED}/opt/${PN}/libGLESv2.so" || die
		rm "${ED}/opt/${PN}/libvulkan.so.1" || die
		rm "${ED}/opt/${PN}/libvk_swiftshader.so" || die
		rm "${ED}/opt/${PN}/vk_swiftshader_icd.json" || die
		elog "Using system mesa. This is experimental and may lead to crashes."
	fi

	# hack into ayatana-appindicator symlink
	dosym "../../usr/$(get_libdir)/libayatana-appindicator3.so" "opt/${PN}/libappindicator3.so" || die

	# install wrapper reading /etc/chromium/* for CHROME_FLAGS
	exeinto /opt/${PN}
	doexe "${FILESDIR}/${PN}.sh"

	# remove chrome-sandbox binary, users should use kernel namespaces
	# https://bugs.gentoo.org/692692#c18
	rm "${ED}"/opt/${PN}/chrome-sandbox || die

	dosym ../../opt/${PN}/${PN}.sh /usr/bin/${PN}

	newicon -s scalable "${FILESDIR}/${PN}.svg" ${PN}.svg
	make_desktop_entry "${EPREFIX}"/opt/${PN}/${PN}.sh "Skype" \
		${PN} "Network;Chat;InstantMessaging;" \
		"MimeType=x-scheme-handler/skype;"
}
