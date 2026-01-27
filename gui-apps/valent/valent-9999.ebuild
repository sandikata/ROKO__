# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson vala gnome2-utils git-r3

DESCRIPTION="Modern KDE Connect implementation for GNOME"
HOMEPAGE="https://github.com/andyholmes/valent"
EGIT_REPO_URI="https://github.com/andyholmes/valent.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""

IUSE=""

DEPEND="
	dev-libs/glib:2
	dev-libs/libpeas[vala]
	dev-libs/libphonenumber
	>=dev-lang/vala-0.56
"
RDEPEND="${DEPEND}"
BDEPEND="
	dev-build/meson
	dev-build/ninja
	virtual/pkgconfig
"

src_prepare() {
	default
	vala_setup
}

src_configure() {
	export CC=gcc
	export LD=ld.bfd
	export VAPIGEN=vapigen-0.56
	export LC_ALL=C

	meson_src_configure
}

src_compile() {
	meson_src_compile
}

src_install() {
	meson_src_install
}

pkg_postinst() {
	gnome2_schemas_update
}

pkg_postrm() {
	gnome2_schemas_update
}

