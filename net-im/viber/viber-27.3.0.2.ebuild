# Copyright 2026 Gentoo Authors
# Distributed under the terms of the BSD 3-Clause License

EAPI=8

CHROMIUM_LANGS="am ar bg bn ca cs da de el en-GB en-US es-419 es et fa fil fi fr
	gu he hi hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru
	sk sl sr sv sw ta te th tr uk vi zh-CN zh-TW"

inherit chromium-2 desktop pax-utils unpacker wrapper xdg

DESCRIPTION="Free text and calls"
HOMEPAGE="https://www.viber.com/en/"
SRC_URI="https://download.cdn.viber.com/cdn/desktop/Linux/${PN}.deb -> ${P}.deb"
S="${WORKDIR}"

LICENSE="viber"
SLOT="0"
KEYWORDS="-* ~amd64"
IUSE="apulse +pulseaudio"
REQUIRED_USE="^^ ( apulse pulseaudio )"
RESTRICT="bindist mirror splitdebug"

RDEPEND="
	app-arch/brotli:=
	app-arch/snappy:=
	app-arch/zstd:=
	app-crypt/libb2
	app-crypt/mit-krb5
	dev-libs/double-conversion
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/libevent:=
	dev-libs/libpcre2:=
	dev-libs/libxml2-compat:2
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
	media-libs/harfbuzz:=
	media-libs/lcms:2
	media-libs/libglvnd
	media-libs/libmng:=
	media-libs/libopenmpt
	media-libs/libpng:=
	media-libs/libtheora:=
	media-libs/libwebp:=
	media-libs/opus
	media-libs/tiff:0=[jbig]
	media-libs/xvid
	media-libs/jbigkit
	media-libs/openjpeg:2
	net-libs/libssh
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
	x11-libs/libxcb:=
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
	virtual/zlib:=
	apulse? ( media-sound/apulse )
	pulseaudio? (
		media-libs/libpulse
		media-plugins/gst-plugins-pulse
	)
	|| (
		media-video/ffmpeg-compat:7[bluray,gsm,libsoxr,opencl,theora,twolame,vdpau,zvbi]
		media-video/ffmpeg:0/59.61.61[bluray,gsm,libsoxr,opencl,theora,twolame,vdpau,zvbi]
	)
	|| ( sys-apps/systemd sys-apps/systemd-utils[udev] )
"

QA_PREBUILT="opt/viber/*"

src_prepare() {
	default
	pushd opt/viber/translations/qtwebengine_locales >/dev/null || die
	chromium_remove_language_paks
	popd >/dev/null || die

        sed -i -e 's|Exec=/opt/viber/Viber|Exec=/usr/bin/Viber|' \
                -e '/Icon/s|/usr/share/pixmaps/viber.png|viber|' \
                -e '/\[Desktop Entry\]/a StartupWMClass=ViberPC' \
                usr/share/applications/viber.desktop || die
}

src_install() {
	local size
	for size in 16 24 32 48 64 96 128 256 ; do
		newicon -s "${size}" usr/share/viber/"${size}x${size}".png viber.png
	done
	newicon -s scalable usr/share/icons/hicolor/scalable/apps/Viber.svg viber.svg

	domenu usr/share/applications/viber.desktop

	dodir /opt/viber
	cp -a opt/viber/* "${ED}/opt/viber/" || die

	pax-mark -m "${ED}/opt/viber/Viber" "${ED}/opt/viber/libexec/QtWebEngineProcess"

	local wrapper_cmd="/opt/viber/Viber"
	use apulse && wrapper_cmd="apulse /opt/viber/Viber"
	make_wrapper Viber "${wrapper_cmd}"
}
