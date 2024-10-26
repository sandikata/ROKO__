# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{9..12} )

PLOCALES="ar bn ca cs de es eu fa fi fr he hi id it ja ka ko nb nl oc pl pt pt_BR ru sv tr uk ur vi zh"

inherit meson python-single-r1 xdg-utils gnome2-utils plocale


DESCRIPTION="A settings app for GNOME's Login/Display Manager, GDM"
HOMEPAGE="https://github.com/gdm-settings/gdm-settings"
SRC_URI="https://github.com/gdm-settings/gdm-settings/archive/refs/tags/v${PV}.tar.gz"

LICENSE="AGPL-3+"
SLOT="0"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"


KEYWORDS="~amd64"

BDEPEND="
    dev-util/blueprint-compiler
    dev-build/automake
    dev-libs/gobject-introspection
"

RDEPEND="
	gnome-base/gdm
	gui-libs/libadwaita
	dev-libs/glib
	$(python_gen_cond_dep 'dev-python/pygobject[${PYTHON_USEDEP}]' $PYTHON_COMPAT)
	sys-devel/gettext
	sys-auth/polkit
"

for x in ${PLOCALES}; do
	IUSE+=" l10n_${x}"
done

uninstall_language(){
    rm "po/$1.po"
    sed -i "/^$1\$/d" "po/LINGUAS"
}

src_prepare(){
    default

    plocale_find_changes "po/" "" ".po"

    sed -i '/gnome.post_install/,$d' meson.build || die

    plocale_for_each_disabled_locale uninstall_language
    elog "Removed support for those languages:" $(plocale_get_locales disabled)
}

src_configure() {
    local emesonargs=( )
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
