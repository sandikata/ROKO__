# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{8..11} )

inherit meson python-single-r1 xdg-utils gnome2-utils


DESCRIPTION="A settings app for GNOME's Login/Display Manager, GDM"
HOMEPAGE="https://github.com/realmazharhussain/gdm-settings"
SRC_URI="https://github.com/realmazharhussain/gdm-settings/archive/refs/tags/v${PV}.tar.gz"

LICENSE="AGPL-3+"
SLOT="0"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"


KEYWORDS="~amd64 amd64"

DEPEND="
    >=sys-devel/automake-1.16.1-r2
    dev-util/blueprint-compiler
"
RDEPEND="${DEPEND}
    ${PYTHON_DEPS}
	gnome-base/gdm
	gui-libs/libadwaita
	dev-libs/glib
	dev-python/pygobject
	sys-devel/gettext
	sys-auth/polkit
"

src_prepare(){
    default

    sed -i '/gnome.post_install/,$d' meson.build || die
}

src_configure() {
    local emesonargs=(
	)
	meson_src_configure
}

src_install() {
	meson_src_install
	python_optimize
}

src_test() {
	virtx meson_src_test
}

pkg_preinst() {
   gnome2_schemas_savelist
}

pkg_postinst() {
   gnome2_schemas_update
   xdg_icon_cache_update
}

pkg_postrm() {
   gnome2_schemas_update
   xdg_icon_cache_update
}
