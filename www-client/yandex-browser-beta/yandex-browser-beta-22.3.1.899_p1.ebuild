# Copyright 1999-2022 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8
CHROMIUM_LANGS="cs de en-US es fr it ja kk pt-BR pt-PT ru tr uk uz zh-CN zh-TW"
inherit chromium-2 unpacker desktop wrapper pax-utils

RESTRICT="bindist mirror strip"

MY_PV="${PV/_p/-}"

DESCRIPTION="The web browser from Yandex"
HOMEPAGE="https://browser.yandex.ru/beta/"
LICENSE="Yandex-EULA"
SLOT="0"
SRC_URI="
	amd64? ( https://repo.yandex.ru/yandex-browser/deb/pool/main/y/yandex-browser-beta/yandex-browser-beta_${MY_PV}_amd64.deb -> ${P}.deb )
"
KEYWORDS="~amd64"

RDEPEND="
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	>=dev-libs/openssl-1.0.1:0
	gnome-base/gconf:2
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/freetype
	net-misc/curl
	net-print/cups
	sys-apps/dbus
	sys-libs/libcap
	virtual/libudev
	x11-libs/cairo
	x11-libs/gdk-pixbuf
	x11-libs/gtk+:2
	x11-libs/libX11
	x11-libs/libXScrnSaver
	x11-libs/libXcomposite
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXtst
	x11-libs/pango[X]
	x11-misc/xdg-utils
	|| (
		www-plugins/yandex-browser-ffmpeg-codecs-bin
		www-plugins/yandex-browser-ffmpeg-codecs
	)
	sys-libs/libudev-compat
"
DEPEND="
	>=dev-util/patchelf-0.9
"

QA_PREBUILT="*"
S=${WORKDIR}
YANDEX_HOME="opt/${PN/-//}"

pkg_setup() {
	chromium_suid_sandbox_check_kernel_config
}

src_unpack() {
	unpack_deb ${A}
}

src_prepare() {
	rm usr/bin/${PN} || die "Failed to remove bundled wrapper"

	rm -r etc || die "Failed to remove etc"

	rm -r "${YANDEX_HOME}/cron" || die "Failed ro remove cron hook"

	mv usr/share/doc/${PN} usr/share/doc/${PF} || die "Failed to move docdir"

	gunzip "usr/share/doc/${PF}/changelog.gz" "usr/share/man/man1/${PN}.1.gz" || die "Failed to decompress docs"

	pushd "${YANDEX_HOME}/locales" > /dev/null || die
	chromium_remove_language_paks
	popd > /dev/null || die

	default

	sed -r \
		-e 's|\[(NewWindow)|\[X-\1|g' \
		-e 's|\[(NewIncognito)|\[X-\1|g' \
		-e 's|^TargetEnvironment|X-&|g' \
		-i usr/share/applications/${PN}.desktop || die

	patchelf --remove-rpath "${S}/${YANDEX_HOME}/yandex_browser-sandbox" || die "Failed to fix library rpath (yandex_browser-sandbox)"
	patchelf --remove-rpath "${S}/${YANDEX_HOME}/yandex_browser" || die "Failed to fix library rpath (yandex_browser)"
	patchelf --remove-rpath "${S}/${YANDEX_HOME}/find_ffmpeg" || die "Failed to fix library rpath (find_ffmpeg)"
	patchelf --remove-rpath "${S}/${YANDEX_HOME}/nacl_helper" || die "Failed to fix library rpath (nacl_helper)"
}

src_install() {
	mv * "${D}" || die
	dodir /usr/$(get_libdir)/${PN}/lib
	mv "${D}"/usr/share/appdata "${D}"/usr/share/metainfo

	make_wrapper "${PN}" "./${PN}" "/${YANDEX_HOME}" "/usr/$(get_libdir)/${PN}/lib" || die "Failed to mae wrapper"

	# yandex_browser binary loads libudev.so.0 at runtime
	dosym /usr/$(get_libdir)/libudev.so.0 /usr/$(get_libdir)/${PN}/lib/libudev.so.0

	for icon in "${D}/${YANDEX_HOME}/product_logo_"*.png; do
		size="${icon##*/product_logo_}"
		size=${size%.png}
		dodir "/usr/share/icons/hicolor/${size}x${size}/apps"
		newicon -s "${size}" "$icon" "yandex-browser-beta.png"
	done

	fowners root:root "/${YANDEX_HOME}/yandex_browser-sandbox"
	fperms 4711 "/${YANDEX_HOME}/yandex_browser-sandbox"
	pax-mark m "${ED}${YANDEX_HOME}/yandex_browser-sandbox"
}
