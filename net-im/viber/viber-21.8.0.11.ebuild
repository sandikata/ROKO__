# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop pax-utils unpacker xdg

DESCRIPTION="Free text and calls"
HOMEPAGE="https://www.viber.com/en/"
SRC_URI="https://download.cdn.viber.com/cdn/desktop/Linux/${PN}.deb -> ${P}.deb"

LICENSE="viber"
SLOT="0"
KEYWORDS="-* ~amd64"
IUSE="apulse +pulseaudio"
REQUIRED_USE="^^ ( apulse pulseaudio )"
RESTRICT="bindist mirror"

RDEPEND="app-arch/brotli:0
	app-arch/snappy:0
	app-arch/zstd:0
	app-crypt/libb2
	app-crypt/mit-krb5
	dev-libs/double-conversion
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/libevent:0
	dev-libs/libpcre2:0
	dev-libs/libxml2:2
	dev-libs/libxslt:0
	dev-libs/nspr
	dev-libs/nss
	dev-libs/openssl:0
	dev-libs/wayland
	media-libs/alsa-lib
	media-libs/fontconfig:1.0
	media-libs/freetype:2
	media-libs/gst-plugins-bad:1.0
	media-libs/gst-plugins-base:1.0
	media-libs/gstreamer:1.0
	media-libs/harfbuzz:0
	media-libs/lcms:2
	media-libs/libglvnd
	media-libs/libmng:0
	media-libs/libpng:0
	media-libs/libwebp:0
	media-libs/opus
	media-libs/tiff-compat:4
	net-print/cups
	sys-apps/dbus
	sys-libs/mtdev
	sys-libs/zlib:0
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/libdrm
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libxcb:0
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
	apulse? ( media-sound/apulse )
	pulseaudio? (
		media-plugins/gst-plugins-pulse
		|| ( media-sound/pulseaudio-daemon
			media-video/pipewire[sound-server] ) )
	|| ( sys-apps/systemd sys-apps/systemd-utils )"

S="${WORKDIR}"

QA_PREBUILT="opt/viber/Viber
	opt/viber/lib/libpcre2-16.so.0
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
	opt/viber/libexec/QtWebEngineProcess"

src_prepare() {
	default

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
	for size in 16 24 32 48 64 96 128 256; do
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
