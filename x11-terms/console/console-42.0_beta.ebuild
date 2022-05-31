# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit gnome.org gnome2-utils meson xdg

DESCRIPTION="A terminal emulator for GNOME"
HOMEPAGE="https://gitlab.gnome.org/GNOME/console"

LICENSE="GPL-3+"
SLOT="0"
IUSE="debug +nautilus +sassc"
SRC_URI="https://gitlab.gnome.org/GNOME/console/-/archive/42.beta/console-42.beta.tar.bz2"

KEYWORDS="~alpha amd64 ~arm arm64 ~ia64 ~mips ~ppc ~ppc64 ~riscv ~sparc x86 ~amd64-linux ~x86-linux"

RDEPEND="
	>=dev-libs/glib-2.52:2
	gui-libs/gtk:4
	>=x11-libs/vte-0.67.0
	>=dev-libs/libpcre2-10
	>=gnome-base/dconf-0.14
	>=gnome-base/gsettings-desktop-schemas-0.1.0
	sys-apps/util-linux
	nautilus? ( >=gnome-base/nautilus-3.28.0 )
	sassc? ( dev-lang/sassc )
"
DEPEND="${RDEPEND}"

BDEPEND="
	dev-libs/libxml2:2
	dev-libs/libxslt
	dev-util/gdbus-codegen
	dev-util/glib-utils
	dev-util/itstool
	>=sys-devel/gettext-0.19.8
	>=gui-libs/libhandy-1.5
	virtual/pkgconfig
"

S="${WORKDIR}/console-42.beta"

src_configure() {
	local emesonargs=(
		$(meson_use debug devel)
		-Dtests=false
		$(meson_feature nautilus)
		$(meson_feature sassc)
	)
	meson_src_configure
}

src_install() {
	meson_src_install
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
