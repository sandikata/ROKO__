# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CHROMIUM_LANGS="am ar bg bn ca cs da de el en-GB en-US es-419 es et fa fil fi fr
	gu he hi hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru
	sk sl sr sv sw ta te th tr uk vi zh-CN zh-TW"
MULTILIB_COMPAT=( abi_x86_64 )

inherit chromium-2 desktop multilib-build pax-utils unpacker xdg

DESCRIPTION="Free text and calls"
HOMEPAGE="https://www.viber.com/en/"
SRC_URI="https://download.cdn.viber.com/cdn/desktop/Linux/${PN}.deb -> ${P}.deb"
S="${WORKDIR}"

LICENSE="viber"
SLOT="0"
KEYWORDS="-* ~amd64"
IUSE="+abi_x86_64 apulse +pulseaudio"
REQUIRED_USE="^^ ( apulse pulseaudio )"
RESTRICT="bindist mirror splitdebug"

RDEPEND="app-arch/brotli
	app-arch/snappy
	app-arch/zstd
	app-crypt/libb2
	app-crypt/mit-krb5
	dev-libs/double-conversion
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/libevent
	dev-libs/libpcre2
	dev-libs/libxml2
	dev-libs/libxslt
	dev-libs/nspr
	dev-libs/nss
	dev-libs/wayland
	media-libs/alsa-lib
	media-libs/fontconfig:1.0
	media-libs/freetype:2
	media-libs/gst-plugins-bad:1.0
	media-libs/gst-plugins-base:1.0
	media-libs/gstreamer:1.0
	media-libs/harfbuzz
	media-libs/lcms:2
	media-libs/libglvnd
	media-libs/libmng
	media-libs/libopenmpt
	media-libs/libpng
	media-libs/libtheora-compat
	media-libs/libwebp
	media-libs/opus
	media-libs/tiff-compat:4
	media-sound/wavpack
	net-print/cups
	sys-apps/dbus
	sys-libs/mtdev
	sys-process/numactl
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/libdrm
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libxkbcommon
	x11-libs/libxkbfile
	x11-libs/libXrandr
	x11-libs/libXScrnSaver
	x11-libs/libxshmfence
	x11-libs/libXtst
	x11-libs/pango
	x11-libs/tslib
	x11-libs/xcb-util-cursor
	x11-libs/xcb-util-image
	x11-libs/xcb-util-keysyms
	x11-libs/xcb-util-renderutil
	x11-libs/xcb-util-wm
	virtual/zlib
	apulse? ( media-sound/apulse )
	pulseaudio? (
		media-libs/libpulse
		media-plugins/gst-plugins-pulse )
	|| ( media-video/ffmpeg-compat:4[bluray,gsm,libsoxr,opencl,theora,twolame,vdpau,zvbi,${MULTILIB_USEDEP}] )
	|| ( sys-apps/systemd sys-apps/systemd-utils[udev,${MULTILIB_USEDEP}] )"

QA_PREBUILT="opt/viber/Viber
	opt/viber/lib/libpcre2-16.so.0
	opt/viber/lib/libxcb-cursor.so.0
	opt/viber/lib/libdouble-conversion.so.3
	opt/viber/lib/libicudata.so.66
	opt/viber/lib/libwebp.so.6
	opt/viber/lib/libjpeg.so.8
	opt/viber/lib/libssl.so.1.1
	opt/viber/lib/libXdamage.so.1
	opt/viber/lib/libminizip.so.1
	opt/viber/lib/libb2.so.1
	opt/viber/lib/libpng16.so.16
	opt/viber/lib/libre2.so.5
	opt/viber/lib/libcrypto.so.1.1
	opt/viber/lib/libicui18n.so.66
	opt/viber/lib/libicuuc.so.66
	opt/viber/lib/libXcomposite.so.1
	opt/viber/libexec/QtWebEngineProcess
	opt/viber/lib/libswscale.so.5
	opt/viber/lib/libx264.so.155
	opt/viber/lib/libx265.so.179
	opt/viber/lib/libavcodec.so.58
	opt/viber/lib/libchromaprint.so.1
	opt/viber/lib/libswresample.so.3
	opt/viber/lib/libavutil.so.56
	opt/viber/lib/libavformat.so.58
	opt/viber/lib/libshine.so.3
	opt/viber/lib/libaom.so.0
	opt/viber/lib/libcodec2.so.0.9
	opt/viber/lib/libssh-gcrypt.so.4
	opt/viber/lib/libvpx.so.6
	opt/viber/lib/libbz2.so.1.0
	opt/viber/lib/libgme.so.0"

src_prepare() {
	default
	pushd opt/viber/translations/qtwebengine_locales || die "pushd failed"
	chromium_remove_language_paks
	popd || die "popd failed"

	if use apulse ; then
		sed -i '/Exec=/s|/opt|apulse /opt|' \
			usr/share/applications/viber.desktop || die "sed failed"
	fi

	# remove hardcoded path
	sed -i '/Icon/s|/usr/share/pixmaps/viber.png|viber|' \
		usr/share/applications/viber.desktop \
		|| die "sed failed for viber.desktop"
}

src_install() {
	newicon -s scalable usr/share/icons/hicolor/scalable/apps/Viber.svg \
		viber.svg
	for size in 16 24 32 48 64 96 128 256 ; do
		newicon -s "${size}" usr/share/viber/"${size}x${size}".png viber.png
	done
	dosym ../icons/hicolor/256x256/apps/viber.png \
		/usr/share/pixmaps/viber.png

	domenu usr/share/applications/viber.desktop

	insinto /opt/viber
	doins -r opt/viber/.

	pax-mark -m "${ED}"/opt/viber/Viber "${ED}"/opt/viber/QtWebEngineProcess

	fperms +x /opt/viber/Viber /opt/viber/libexec/QtWebEngineProcess
	dosym ../../opt/viber/Viber /usr/bin/Viber
}
