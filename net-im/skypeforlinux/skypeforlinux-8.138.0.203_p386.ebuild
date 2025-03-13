# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CHROMIUM_LANGS="af am ar bg bn ca cs da de el en-GB en-US es-419 es et fa fil fi
	fr gu he hi hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro
	ru sk sl sr sv sw ta te th tr uk ur vi zh-CN zh-TW"
MULTILIB_COMPAT=( abi_x86_64 )

inherit chromium-2 desktop multilib-build optfeature pax-utils xdg

DESCRIPTION="Instant messaging client, with support for audio and video"
HOMEPAGE="https://www.skype.com/en"
SRC_URI="https://api.snapcraft.io/api/v1/snaps/download/QRDEfjn4WJYnm0FzDKwqqRZZI77awQEV_${PV/#*_p/}.snap -> ${P}.snap"
S="${WORKDIR}/squashfs-root"

LICENSE="Skype-TOS MIT MIT-with-advertising BSD-1 BSD-2 BSD Apache-2.0 Boost-1.0 ISC CC-BY-SA-3.0 CC0-1.0 openssl ZLIB APSL-2 icu Artistic-2 LGPL-2.1"
SLOT="0"
KEYWORDS="-* ~amd64"
IUSE="+abi_x86_64 +appindicator +seccomp selinux suid"
RESTRICT="bindist mirror splitdebug"

RDEPEND="app-accessibility/at-spi2-core:2[${MULTILIB_USEDEP}]
	app-arch/bzip2:0[${MULTILIB_USEDEP}]
	dev-libs/expat:0[${MULTILIB_USEDEP}]
	dev-libs/glib:2[${MULTILIB_USEDEP}]
	dev-libs/libffi:0[${MULTILIB_USEDEP}]
	dev-libs/libpcre2:0[${MULTILIB_USEDEP}]
	dev-libs/nspr:0[${MULTILIB_USEDEP}]
	dev-libs/nss:0[${MULTILIB_USEDEP}]
	media-libs/alsa-lib:0[${MULTILIB_USEDEP}]
	media-libs/mesa:0[vulkan,${MULTILIB_USEDEP}]
	sys-apps/dbus:0[${MULTILIB_USEDEP}]
	sys-apps/util-linux[${MULTILIB_USEDEP}]
	sys-libs/zlib:0[${MULTILIB_USEDEP}]
	x11-libs/cairo:0[${MULTILIB_USEDEP}]
	x11-libs/gtk+:3[${MULTILIB_USEDEP}]
	x11-libs/libdrm:0[${MULTILIB_USEDEP}]
	x11-libs/libX11:0[${MULTILIB_USEDEP}]
	x11-libs/libXau[${MULTILIB_USEDEP}]
	x11-libs/libXdmcp[${MULTILIB_USEDEP}]
	x11-libs/libxcb:0/1.12[${MULTILIB_USEDEP}]
	x11-libs/libXcomposite:0[${MULTILIB_USEDEP}]
	x11-libs/libXdamage:0[${MULTILIB_USEDEP}]
	x11-libs/libXext:0[${MULTILIB_USEDEP}]
	x11-libs/libXfixes:0[${MULTILIB_USEDEP}]
	x11-libs/libxkbcommon:0[${MULTILIB_USEDEP}]
	x11-libs/libXrandr:0[${MULTILIB_USEDEP}]
	x11-libs/pango:0[${MULTILIB_USEDEP}]
	appindicator? ( dev-libs/libayatana-appindicator )
	selinux? ( sec-policy/selinux-skype )"
BDEPEND="sys-fs/squashfs-tools[lzo]"

QA_PREBUILT="opt/skypeforlinux/resources/app.asar.unpacked/modules/slimcore.node
	opt/skypeforlinux/resources/app.asar.unpacked/modules/sharing-indicator.node"

pkg_pretend() {
	use suid || chromium_suid_sandbox_check_kernel_config
}

src_unpack() {
	unsquashfs "${DISTDIR}/${P}".snap || die "unsquashfs failed"
}

src_prepare() {
	default
	pushd usr/share/skypeforlinux/locales || die "pushd failed"
	chromium_remove_language_paks
	popd || die "popd failed"

	# remove hardcoded path
	sed -i  -e "/Icon/s|\${SNAP}/meta/gui/skypeforlinux.png|skypeforlinux|" \
		-e '/Exec/s|skype|skypeforlinux|' \
		snap/gui/skypeforlinux{,-share}.desktop \
		|| die "sed failed for hardcoded path"
	sed -i '/Categories/s|Application;||' snap/gui/skypeforlinux.desktop \
		|| die "sed failed for skypeforlinux.desktop"

	rm usr/share/skypeforlinux/LICENSES.chromium.html \
		|| die "rm failed for licenses"

	if ! use suid ; then
		rm usr/share/skypeforlinux/chrome-sandbox || die "rm failed"
	fi

	if ! use seccomp ; then
		sed -i '/Exec/s/%U/%U --disable-seccomp-filter-sandbox/' \
			snap/gui/skypeforlinux.desktop \
			|| die "sed failed for seccomp"
	fi
}

src_install() {
	doicon -s 256 snap/gui/skypeforlinux.png
	dosym ../icons/hicolor/256x256/apps/skypeforlinux.png \
		/usr/share/pixmaps/skypeforlinux.png

	domenu snap/gui/skypeforlinux{,-share}.desktop

	insinto /opt
	doins -r usr/share/skypeforlinux
	fperms +x /opt/skypeforlinux/{chrome_crashpad_handler,skypeforlinux}
		/opt/skypeforlinux/lib{EGL,ffmpeg,GLESv2,vk_swiftshader}.so \
		/opt/skypeforlinux/libvulkan.so.1
	use suid && fperms u+s,+x /opt/skypeforlinux/chrome-sandbox

	dosym ../../opt/skypeforlinux/skypeforlinux usr/bin/skypeforlinux
	use appindicator && dosym ../../usr/"$(get_libdir)"/libayatana-appindicator3.so \
		opt/skypeforlinux/libappindicator3.so

	pax-mark -m "${ED}"/opt/skypeforlinux/skypeforlinux
	pax-mark -m "${ED}"/opt/skypeforlinux/resources/app.asar.unpacked/node_modules/slimcore/bin/slimcore.node
}

pkg_postinst() {
	optfeature "storing passwords via Secret Service API provider" virtual/secret-service
	xdg_pkg_postinst
}
