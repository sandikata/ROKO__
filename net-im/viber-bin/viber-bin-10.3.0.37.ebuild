# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MULTILIB_COMPAT=( abi_x86_64 )
MY_PN="${PN/-bin/}"

inherit desktop multilib-build pax-utils unpacker xdg-utils

QA_PREBUILT="/opt/viber/Viber
	/opt/viber/libexec/QtWebEngineProcess
	/opt/viber/plugins/*/*.so
	/opt/viber/lib/*
	/opt/viber/qml/*"

DESCRIPTION="Free text and calls"
HOMEPAGE="http://www.viber.com"
SRC_URI="http://download.cdn.viber.com/cdn/desktop/Linux/${MY_PN}.deb"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="-* ~amd64"
IUSE="apulse pax_kernel +pulseaudio"
REQUIRED_USE="^^ ( apulse pulseaudio )"

RESTRICT="bindist mirror"

DEPEND="sys-apps/fix-gnustack"
RDEPEND="dev-libs/expat[${MULTILIB_USEDEP}]
	dev-libs/glib:2[${MULTILIB_USEDEP}]
	dev-libs/nspr[${MULTILIB_USEDEP}]
	dev-libs/nss[${MULTILIB_USEDEP}]
	dev-libs/wayland[${MULTILIB_USEDEP}]
	media-libs/alsa-lib[${MULTILIB_USEDEP}]
	media-libs/fontconfig:1.0[${MULTILIB_USEDEP}]
	media-libs/freetype:2[${MULTILIB_USEDEP}]
	media-libs/gst-plugins-base:1.0[${MULTILIB_USEDEP}]
	media-libs/gstreamer:1.0[${MULTILIB_USEDEP}]
	net-print/cups[${MULTILIB_USEDEP}]
	sys-apps/dbus[${MULTILIB_USEDEP}]
	sys-libs/zlib:0/1[${MULTILIB_USEDEP}]
	x11-libs/libdrm[${MULTILIB_USEDEP}]
	x11-libs/libICE[${MULTILIB_USEDEP}]
	x11-libs/libSM[${MULTILIB_USEDEP}]
	x11-libs/libX11[${MULTILIB_USEDEP}]
	x11-libs/libxcb:0/1.12[${MULTILIB_USEDEP}]
	x11-libs/libXcomposite[${MULTILIB_USEDEP}]
	x11-libs/libXcursor[${MULTILIB_USEDEP}]
	x11-libs/libXdamage[${MULTILIB_USEDEP}]
	x11-libs/libXext[${MULTILIB_USEDEP}]
	x11-libs/libXfixes[${MULTILIB_USEDEP}]
	x11-libs/libXi[${MULTILIB_USEDEP}]
	x11-libs/libXrandr[${MULTILIB_USEDEP}]
	x11-libs/libXrender[${MULTILIB_USEDEP}]
	x11-libs/libXScrnSaver[${MULTILIB_USEDEP}]
	x11-libs/libXtst[${MULTILIB_USEDEP}]
	x11-libs/xcb-util-image[${MULTILIB_USEDEP}]
	x11-libs/xcb-util-keysyms[${MULTILIB_USEDEP}]
	x11-libs/xcb-util-renderutil[${MULTILIB_USEDEP}]
	x11-libs/xcb-util-wm[${MULTILIB_USEDEP}]
	apulse? ( media-sound/apulse[${MULTILIB_USEDEP}] )
	pulseaudio? ( media-sound/pulseaudio[${MULTILIB_USEDEP}] )"

S="${WORKDIR}"

src_prepare() {
	default

	if use apulse ; then
		sed -i '/Exec=/s|/opt|apulse /opt|' \
			usr/share/applications/viber.desktop || die "sed failed"
	fi
}
src_install() {
	fix-gnustack -f opt/viber/lib/libQt5WebEngineCore.so.5 > /dev/null \
		|| die "removing execstack flag failed"

	newicon -s scalable usr/share/icons/hicolor/scalable/apps/Viber.svg \
		viber.svg
	for size in 16x16 24x24 32x32 48x48 64x64 96x96 128x128 256x256; do
		newicon -s "${size%%x*}" usr/share/viber/"${size}".png viber.png
	done
	dosym ../icons/hicolor/96x96/apps/viber.png \
		/usr/share/pixmaps/viber.png

	domenu usr/share/applications/viber.desktop

	insinto /opt/viber
	doins -r opt/viber/.

	if use pax_kernel; then
		pax-mark -m "${ED%/}"/opt/viber/Viber \
			"${ED%/}"/opt/viber/QtWebEngineProcess
	fi

	fperms +x /opt/viber/Viber \
		/opt/viber/libexec/QtWebEngineProcess

	dosym ../../opt/viber/Viber /usr/bin/Viber
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}
