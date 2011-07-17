# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit eutils gnome2-utils git-2

DESCRIPTION="Weather extensions for GNOME Shell"
HOMEPAGE="https://github.com/Keruspe/GPaste"
EGIT_REPO_URI="https://github.com/Keruspe/GPaste"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

COMMON_DEPEND="
        >=dev-libs/glib-2.26
        >=gnome-base/gnome-desktop-3:3"
RDEPEND="${COMMON_DEPEND}
        gnome-base/gnome-desktop:3[introspection]
        media-libs/clutter:1.0[introspection]
        net-libs/telepathy-glib[introspection]
        x11-libs/gtk+:3[introspection]
        x11-libs/pango[introspection]"
DEPEND="${COMMON_DEPEND}
        sys-devel/gettext
        >=dev-util/pkgconfig-0.22
        >=dev-util/intltool-0.26
        gnome-base/gnome-common
	dev-lang/vala:0.12"


src_prepare() {
	./autogen.bash --enable-gnome-shell-extension
	G2CONF="${G2CONF} --prefix=/usr"
}

src_install()   {
        emake DESTDIR="${D}" install

	rm ${D}/usr/share/glib-2.0/schemas/gschemas.compiled

	cd ${D}/usr/share/gnome-shell/extensions/GPaste\@gnome.org

	sed -i "s|/usr/local/share/|/usr/share/|g" metadata.json
	sed -i "s|/usr/local/libexec/|/usr/libexec/|g" metadata.json
}

pkg_preinst() {
        gnome2_schemas_savelist
}

pkg_postinst() {
        gnome2_schemas_update
}

pkg_postrm() {
        gnome2_schemas_update --uninstall
}

