# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit gnome2-utils git-2

DESCRIPTION="gnome shell extension for selecting windows in overview mode with arrow keys"
HOMEPAGE="https://github.com/tanwald/gnome-shell-extension-arrow-key-window-selector"
EGIT_REPO_URI="https://github.com/tanwald/gnome-shell-extension-arrow-key-window-selector"

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
        gnome-base/gnome-common"


src_configure() {
        :
}

src_compile()   {
        :
}

src_install()   {
	dodir -p /usr/share/gnome-shell/extensions/arrow-key-window-selector@tanwald.net

	insinto /usr/share/gnome-shell/extensions/arrow-key-window-selector@tanwald.net
	doins extension.js
	doins metadata.json
}
