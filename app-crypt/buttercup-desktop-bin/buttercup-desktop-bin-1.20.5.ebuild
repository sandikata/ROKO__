# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Source overlay: https://github.com/BlueManCZ/edgets

EAPI=7
inherit desktop unpacker xdg-utils

MY_PN="${PN/-bin/}"
UP_PN="Buttercup"

DESCRIPTION="Cross-platform, free and open-source password manager based on NodeJS."
HOMEPAGE="https://buttercup.pw"
SRC_URI="amd64? ( https://github.com/buttercup/buttercup-desktop/releases/download/v${PV}/${MY_PN}_${PV}_amd64.deb -> ${P}-amd64.deb )"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE="gnome-keyring libnotify xscreensaver xtest"

RDEPEND="app-accessibility/at-spi2-core
	app-crypt/libsecret
	dev-libs/nss
	gnome-keyring? ( gnome-base/gnome-keyring )
	libnotify? ( x11-libs/libnotify )
	media-libs/libglvnd
	media-video/ffmpeg[chromium]
	sys-apps/util-linux
	x11-libs/gtk+
	xscreensaver? ( x11-libs/libXScrnSaver )
	xtest? ( x11-libs/libXtst )
	x11-misc/xdg-utils"

S="${WORKDIR}"

QA_PREBUILT="*"

src_prepare() {
	rm "opt/${UP_PN}/"*".so"
	rm -r "opt/${UP_PN}/swiftshader"
	default
}

src_install() {
	insinto /opt/${MY_PN}
	doins -r opt/${UP_PN}/*

	exeinto /opt/${MY_PN}
	doexe opt/${UP_PN}/buttercup-desktop opt/${UP_PN}/chrome-sandbox

	if [[ $(tc-arch) = amd64 ]] ; then
		dosym "/usr/lib64/chromium/libffmpeg.so" "/opt/${MY_PN}/libffmpeg.so"
	else
		dosym "/usr/lib/chromium/libffmpeg.so" "/opt/${MY_PN}/libffmpeg.so"
	fi

	dosym /opt/${MY_PN}/${MY_PN} /usr/bin/${MY_PN}
	dosym /opt/${MY_PN}/ /usr/share/${MY_PN}

	doicon usr/share/icons/hicolor/256x256/apps/${MY_PN}.png

	make_desktop_entry ${MY_PN} ${UP_PN} ${MY_PN} "Utility;" "MimeType=x-scheme-handler/buttercup;\nStartupWMClass=${UP_PN}"
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}
