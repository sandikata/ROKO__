# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit desktop gnome2-utils xdg

DESCRIPTION="Official desktop client for Telegram (binary package)"
HOMEPAGE="https://desktop.telegram.org"
MY_PV="${PV/_beta/}"
SRC_URI="
	https://github.com/telegramdesktop/tdesktop/archive/v${MY_PV}.tar.gz -> tdesktop-${MY_PV}.tar.gz
	amd64? ( https://github.com/telegramdesktop/tdesktop/releases/download/v${MY_PV}/tsetup.${MY_PV}.beta.tar.xz )
"

LICENSE="telegram"
SLOT="0"
KEYWORDS="~amd64"

QA_PREBUILT="usr/bin/telegram-desktop"

RDEPEND="
	dev-libs/glib:2
	dev-libs/gobject-introspection
	>=sys-apps/dbus-1.4.20
	x11-libs/libX11
	>=x11-libs/libxcb-1.10[xkb]
"
DEPEND=""
RESTRICT="mirror"

S="${WORKDIR}/Telegram"

src_install() {
	newbin "${S}/Telegram" telegram-desktop

	local icon_size
	for icon_size in 16 32 48 64 128 256 512; do
		newicon -s "${icon_size}" \
			"${WORKDIR}/tdesktop-${MY_PV}/Telegram/Resources/art/icon${icon_size}.png" \
			telegram-desktop.png
	done

	domenu "${WORKDIR}/tdesktop-${MY_PV}"/lib/xdg/telegramdesktop.desktop
}

pkg_preinst() {
	xdg_pkg_preinst
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_icon_cache_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_icon_cache_update
}
