# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9..12} )

inherit gnome2-utils meson python-single-r1 xdg git-r3

DESCRIPTION="A GNOME media player built using GJS with GTK4 toolkit and powered by GStreamer with OpenGL rendering."
HOMEPAGE="https://github.com/Rafostar/clapper"

EGIT_REPO_URI="https://github.com/Rafostar/clapper.git"

KEYWORDS="~amd64 ~x86"

LICENSE="GPL-3"
SLOT="0"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	dev-libs/glib
	dev-libs/appstream-glib[introspection]
	dev-python/pygobject[cairo]
"
DEPEND="
	${RDEPEND}
"

pkg_preinst() {
	gnome2_schemas_savelist
	xdg_environment_reset
}

pkg_postinst() {
	gnome2_gconf_install
	gnome2_schemas_update
	xdg_icon_cache_update
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}

pkg_postrm() {
	gnome2_gconf_uninstall
	gnome2_schemas_update
	xdg_icon_cache_update
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}
