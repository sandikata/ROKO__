# Copyright 2026 Gentoo Authors
# Distributed under the terms of the BSD 3-Claude License

EAPI=8

PYTHON_COMPAT=( python3_{12..15} )

inherit xdg cmake python-any-r1 flag-o-matic optfeature

DESCRIPTION="Desktop Telegram client with good customization and Ghost mode"
HOMEPAGE="https://github.com/AyuGram/AyuGramDesktop"

SRC_URI="https://github.com/AyuGram/AyuGramDesktop/releases/download/v${PV}/AyuGramDesktop-${PV}-full.tar.gz -> ${P}-full.tar.gz"

S="${WORKDIR}/AyuGramDesktop-${PV}-full"

LICENSE="BSD GPL-3-with-openssl-exception LGPL-2+"
SLOT="0"
KEYWORDS="~amd64"

IUSE="dbus enchant +fonts screencast wayland webkit +X"

CDEPEND="
	!net-im/telegram-desktop-bin
	app-arch/lz4:=
	app-text/cmark-gfm:=
	dev-cpp/abseil-cpp:=
	dev-cpp/ada:=
	dev-cpp/cld3:=
	>=dev-cpp/glibmm-2.77:2.68
	dev-cpp/toomanycooks
	dev-libs/glib:2
	dev-libs/libfido2:=
	dev-libs/openssl:=
	>=dev-libs/protobuf-21.12
	dev-libs/qr-code-generator:=
	dev-libs/xxhash
	>=dev-qt/qtbase-6.5:6=[dbus?,gui,network,opengl,ssl,wayland?,widgets,X?]
	>=dev-qt/qtimageformats-6.5:6
	>=dev-qt/qtsvg-6.5:6
	kde-frameworks/kcoreaddons:6
	media-libs/libjpeg-turbo:=
	media-libs/openal
	media-libs/opus
	media-libs/rnnoise
	>=media-libs/tg_owt-0_pre20241202:=[screencast=,X=]
	>=media-video/ffmpeg-6:=[opus,vpx]
	net-libs/tdlib:=[tde2e]
	sys-apps/hwloc:=
	virtual/minizip:=
	!enchant? ( >=app-text/hunspell-1.7:= )
	enchant? ( app-text/enchant:= )
	webkit? ( wayland? (
		>=dev-qt/qtdeclarative-6.5:6
		>=dev-qt/qtwayland-6.5:6[compositor(+),qml]
	) )
	X? (
		x11-libs/libxcb:=
		x11-libs/xcb-util-keysyms
	)
"

RDEPEND="${CDEPEND}
	webkit? ( || ( net-libs/webkit-gtk:4.1 net-libs/webkit-gtk:6 ) )
"

DEPEND="${CDEPEND}
	>=dev-cpp/cppgir-2.0_p20240315
	>=dev-cpp/ms-gsl-4.1.0
	dev-cpp/expected
	dev-cpp/expected-lite
	dev-cpp/range-v3
"

BDEPEND="
	${PYTHON_DEPS}
	>=dev-build/cmake-3.16
	>=dev-cpp/cppgir-2.0_p20260226
	>=dev-libs/gobject-introspection-1.82.0-r2
	dev-qt/qtshadertools
	>=dev-util/gdbus-codegen-2.80.5-r1
	virtual/pkgconfig
	wayland? ( dev-util/wayland-scanner )
"

PATCHES=(
	"${FILESDIR}"/tdesktop-5.7.2-cstring.patch
	"${FILESDIR}"/tdesktop-5.8.3-cstdint.patch
	"${FILESDIR}"/tdesktop-5.14.3-system-cppgir.patch
)

pkg_pretend() {
	if [[ ${MERGE_TYPE} != binary ]]; then
		if has ccache ${FEATURES}; then
			ewarn "ccache does not work with ${PN} out of the box"
			ewarn "due to usage of precompiled headers"
			ewarn "check bug https://bugs.gentoo.org/715114 for more info"
			ewarn
		fi
	fi
}

src_prepare() {
	find -type f \( -name 'CMakeLists.txt' -o -name '*.cmake' \) \
		\! -path './cmake/external/qt/package.cmake' \
		-print0 | xargs -0 sed -i \
		-e '/pkg_check_modules(/s/[^ ]*)/REQUIRED &/' \
		-e '/find_package(/s/)/ REQUIRED)/' \
		-e '/find_library(/s/)/ REQUIRED)/' \
		-e '/find_path(/s/)/ REQUIRED)/' || die

	sed -e '/find_package(lz4 /d' \
		-i cmake/external/lz4/CMakeLists.txt || die

	sed -e '/find_package(Opus /d' \
		-i cmake/external/opus/CMakeLists.txt || die

	sed -e '/find_package(xxHash /d' \
		-i cmake/external/xxhash/CMakeLists.txt || die

	sed -e '/find_package(cmark-gfm\(-extensions\)\? /d' \
		-i cmake/external/cmark_gfm/CMakeLists.txt || die

	sed -e '/find_package(minizip /d' \
		-i cmake/external/minizip/CMakeLists.txt || die

	local keep=(
		rlottie
		libprisma
		tgcalls
		xdg-desktop-portal
		MicroTeX
	)

	for x in Telegram/ThirdParty/*; do
		has "${x##*/}" "${keep[@]}" || rm -r "${x}" || die
	done

	: > cmake/external/dispatch/CMakeLists.txt || die

	if ! use dbus; then
		sed -e '/find_package(Qt[^ ]* OPTIONAL_COMPONENTS/s/DBus *//' \
			-i cmake/external/qt/package.cmake || die
	fi

	if ! use webkit || ! use wayland; then
		sed -e 's/QT_CONFIG(wayland_compositor_quick)/0/' \
			-i Telegram/lib_webview/webview/platform/linux/webview_linux_compositor.h || die
	fi

	rm Telegram/ThirdParty/rlottie/CMakeLists.txt || die
	rm cmake/external/glib/cppgir/expected-lite/example/CMakeLists.txt || die
	rm cmake/external/glib/cppgir/expected-lite/test/CMakeLists.txt || die
	rm cmake/external/glib/cppgir/expected-lite/CMakeLists.txt || die

	cmake_src_prepare
}

src_configure() {
	export XDG_DATA_DIRS="${ESYSROOT}/usr/share"

	filter-flags -fno-delete-null-pointer-checks
	append-cppflags -DNDEBUG
	append-cxxflags -Wno-free-nonheap-object

	local no_webkit_wayland=$(use webkit && use wayland && echo no || echo yes)
	local use_webkit_wayland=$(use webkit && use wayland && echo yes || echo no)

	local mycmakeargs=(
		-DQT_VERSION_MAJOR=6
		-DCMAKE_DISABLE_PRECOMPILE_HEADERS=OFF
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt6Quick=${no_webkit_wayland}
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt6QuickWidgets=${no_webkit_wayland}
		-DCMAKE_DISABLE_FIND_PACKAGE_Qt6WaylandCompositor=${no_webkit_wayland}
		-DCMAKE_REQUIRE_FIND_PACKAGE_Qt6DBus=$(usex dbus)
		-DCMAKE_REQUIRE_FIND_PACKAGE_Qt6Quick=${use_webkit_wayland}
		-DCMAKE_REQUIRE_FIND_PACKAGE_Qt6QuickWidgets=${use_webkit_wayland}
		-DCMAKE_REQUIRE_FIND_PACKAGE_Qt6WaylandCompositor=${use_webkit_wayland}
		-DDESKTOP_APP_DISABLE_QT_PLUGINS=ON
		-DDESKTOP_APP_DISABLE_X11_INTEGRATION=$(usex !X)
		-DDESKTOP_APP_USE_ENCHANT=$(usex enchant)
		-DDESKTOP_APP_USE_PACKAGED_FONTS=$(usex !fonts)
	)

	if [[ -n ${MY_TDESKTOP_API_ID} && -n ${MY_TDESKTOP_API_HASH} ]]; then
		einfo "Found custom API credentials"
		mycmakeargs+=(
			-DTDESKTOP_API_ID="${MY_TDESKTOP_API_ID}"
			-DTDESKTOP_API_HASH="${MY_TDESKTOP_API_HASH}"
		)
	else
		mycmakeargs+=(
			-DTDESKTOP_API_ID="611335"
			-DTDESKTOP_API_HASH="d524b414d21f4d37f08684c1df41ac9c"
		)
	fi

	cmake_src_configure
}

src_compile() {
	cmake_build $("${CMAKE_BINARY}" --build "${BUILD_DIR}" -t help | sed -n '/^[^/]*_cppgir:/s/:.*//p')
	cmake_build
	cmake_build
}

pkg_postinst() {
	xdg_pkg_postinst
	if ! use X && ! use screencast; then
		ewarn "both the 'X' and 'screencast' USE flags are disabled, screen sharing won't work!"
		ewarn
	fi
	optfeature_header
	optfeature "AVIF, HEIF and JpegXL image support" kde-frameworks/kimageformats:6[avif,heif,jpegxl]
}
