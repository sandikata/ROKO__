# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Source overlay: https://github.com/BlueManCZ/edgets

EAPI=7

inherit desktop unpacker xdg-utils

DESCRIPTION="Experimental Telegram Desktop fork"
HOMEPAGE="https://github.com/kotatogram/kotatogram-desktop"

LICENSE="GPL-3"
RESTRICT="mirror strip"
SLOT="0"

SRC_URI="${HOMEPAGE}/releases/download/k${PV}/${PV}-linux.tar.xz -> ${P}.tar.xz"
KEYWORDS="~amd64"

DEPEND="sys-fs/fuse:0
	sys-apps/xdg-desktop-portal
	x11-misc/xdg-utils"

RDEPEND="${DEPEND}"

QA_PREBUILT="*"

S="${WORKDIR}/Kotatogram"

src_prepare() {
	mv "Kotatogram" "kotatogram" || die "mv failed"
	eapply_user
}

src_install() {
	exeinto "/usr/bin"
	doexe "kotatogram"

	make_desktop_entry "kotatogram" "Kotatogram Desktop" "kotatogram" "Chat;Network;InstantMessaging;Qt;" "StartupWMClass=KotatogramDesktop" /usr/share/icons/breeze/apps/48/telegram.svg
}
