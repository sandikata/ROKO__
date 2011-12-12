# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

DESCRIPTION="Флагове за индикатора на клавиатурната подредба в GNOME"
HOMEPAGE=""
SRC_URI="ftp://calculate.linuxmaniac.net/pub/downloads/gnomelayoutflags.tar.xz"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=gnome-extra/gconf-editor-2.32.0"
RDEPEND="${DEPEND}"

src_install() {
	cd "${WORKDIR}"
	cp -R * "${D}/" || die

	elog "За да активирате флаговете изпълнете 'gconftool-2 --type bool --set /desktop/gnome/peripherals/keyboard/indicator/showFlags true'. Ако искате да
	се върнете към стандартния вид изпълнете 'gconftool-2 --type bool --set /desktop/gnome/peripherals/keyboard/indicator/showFlags false'"
echo
}
