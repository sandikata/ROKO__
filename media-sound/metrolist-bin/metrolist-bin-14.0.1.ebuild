# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

DESCRIPTION="Open-source YouTube Music desktop client"
HOMEPAGE="https://github.com/MetrolistGroup/Metrolist"

MY_PN="metrolist-desktop-linux"
MY_URI="${HOMEPAGE}/releases/download/v${PV}"

SRC_URI="
	amd64? ( ${MY_URI}/${MY_PN}-x64-${PV}.AppImage )
	arm64? ( ${MY_URI}/${MY_PN}-arm64-${PV}.AppImage )
"

S="${WORKDIR}/squashfs-root"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RESTRICT="strip"

RDEPEND="
	app-crypt/libsecret
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/libglvnd
	net-libs/glib-networking
	net-libs/webkit-gtk:4.1
	sys-apps/dbus
	sys-libs/glibc
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXi
	x11-libs/libXrender
	x11-libs/libXtst
	x11-themes/hicolor-icon-theme
"

QA_PREBUILT="opt/metrolist/*"

src_unpack() {
	local arch

	case ${ARCH} in
		amd64) arch=x64 ;;
		arm64) arch=arm64 ;;
		*) die "Unsupported architecture: ${ARCH}" ;;
	esac

	local appimage="${MY_PN}-${arch}-${PV}.AppImage"

	cp "${DISTDIR}/${appimage}" "${WORKDIR}/" || die
	chmod +x "${WORKDIR}/${appimage}" || die

	"${WORKDIR}/${appimage}" --appimage-extract \
		> /dev/null || die "AppImage extraction failed"
}

src_prepare() {
	default

	sed -i \
		-e 's|^Exec=.*|Exec=metrolist %u|' \
		-e 's|^Icon=.*|Icon=metrolist|' \
		Metrolist.desktop || die

	chmod -R a+rX . || die
}

src_install() {
	dodir /opt/metrolist

	cp -a bin lib resources "${ED}/opt/metrolist/" || die

	dosym ../../opt/metrolist/bin/Metrolist \
		/usr/bin/metrolist

	newicon -s 512 Metrolist.png metrolist.png
	domenu Metrolist.desktop
}
