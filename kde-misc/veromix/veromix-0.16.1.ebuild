# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

PYTHON_DEPEND="2"
inherit python kde4-base

MY_P="$(version_format_string '2012-02-20_$1.$2.$3')_veromix.plasmoid"
DESCRIPTION="A Pulseaudio volume control written in python"
HOMEPAGE="http://code.google.com/p/veromix-plasmoid"
SRC_URI="http://${PN}-plasmoid.googlecode.com/files/${MY_P} -> ${P}.zip"

LICENSE="GPL-3"
SLOT="4"
KEYWORDS="~amd64 ~x86"
IUSE=""
S="${WORKDIR}"

RESTRICT="test"

pkg_setup() {
	python_set_active_version 2
	python_pkg_setup
	kde4-base_pkg_setup
}

src_configure() {
	:
}

src_compile() {
	:
}

src_install() {
	kde4-base_src_install
	mv ${ED}usr/share/kde4/apps/ ${ED}usr/share/apps
}

pkg_postinst() {
	python_mod_optimize /usr/share/apps/plasma/plasmoids/${PN}-plasmoid/contents/code
}

pkg_postrm() {
	python_mod_cleanup /usr/share/apps/plasma/plasmoids/${PN}-plasmoid/contents/code
}

