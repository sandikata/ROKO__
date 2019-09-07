# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit qmake-utils l10n gnome2-utils xdg-utils

DESCRIPTION="GUI client for Yandex.Disk"
HOMEPAGE="https://github.com/abbat/ekstertera"
SRC_URI="https://github.com/abbat/ekstertera/archive/v${PV}.tar.gz -> ${P}.tar.gz"

KEYWORDS="~amd64 ~x86"
RESTRICT="mirror"
LICENSE="GPL-3"
SLOT="0"
IUSE=""

RDEPEND="
	dev-libs/glib:2
	dev-libs/libappindicator:2
	dev-qt/qtcore:5
	dev-qt/qtwidgets:5
	dev-qt/qtsvg:5
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:2"

DEPEND="${RDEPEND}
	virtual/pkgconfig"

DOCS=( README.md AUTHORS ChangeLog )

src_prepare() {
	#
	# (ﾉಥ益ಥ）ﾉ﻿ 
	# https://github.com/abbat/ekstertera/blob/08e42e433f2675edcfdb27cdec1010546cb788fe/build.linux.sh#L37
	$(qt5_get_bindir)/qmake -project -recursive -Wall -nopwd -o "${PN}.pro" \
		"CODEC         = UTF-8"                                             \
		"CODECFORTR    = UTF-8"                                             \
		"QT           += network core widgets"                              \
		"CONFIG       += release link_pkgconfig"                            \
		"PKGCONFIG    += glib-2.0 gtk+-2.0 gdk-pixbuf-2.0 appindicator-0.1" \
		"DEFINES      += ETERA_CUSTOM_TRAY_ICON_GTK ETERA_CUSTOM_TRAY_ICON_UNITY" \
		"INCLUDEPATH  += src"                                               \
		"TRANSLATIONS +=                                                    \
			src/translations/${PN}_en.ts                                    \
			src/translations/${PN}_fr.ts"                                   \
		src 3dparty/json || die "qmake: failed to create *.pro files"

	lupdate -no-obsolete "${PN}.pro" || die
	lrelease -compress -removeidentical "${PN}.pro" || die
	eqmake5

	mv debian/changelog ChangeLog || die

	eapply_user
}

src_install() {
	local size

	for size in 16 24 32 48 64 128 256; do
		insinto /usr/share/icons/hicolor/${size}x${size}/apps/
		newins src/icons/${PN}${size}.png ${PN}.png
	done

	insinto /usr/share/pixmaps/
	doins src/icons/${PN}.xpm

	dobin ${PN}

	make_desktop_entry \
		"${PN}"        \
		"Ekstertera"   \
		"${PN}"        \
		"Network;FileTransfer;Qt;"
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	xdg_desktop_database_update
	gnome2_icon_cache_update
}

pkg_postrm() {
	xdg_desktop_database_update
	gnome2_icon_cache_update
}
