# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

VALA_MIN_API_VERSION=0.14

inherit autotools bash-completion-r1 eutils gnome2 vala

DESCRIPTION="Clipboard management system"
HOMEPAGE="https://github.com/Keruspe/GPaste"
SRC_URI="https://github.com/downloads/Keruspe/GPaste/${P}.tar.xz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="debug gnome-shell nls applet"

DEPEND=">=dev-lang/vala-0.14
		>=dev-util/pkgconfig-0.22
		>=dev-libs/glib-2.30
		x11-libs/gtk+:3
		nls? ( >=dev-util/intltool-0.40 )"
RDEPEND="${DEPEND}"

src_prepare() {
	sed -i -e '/--warn-error/d' bindings/gi.mk \
		|| die "sed failed"
	vala_src_prepare
	eautoreconf
	gnome2_src_prepare
}

src_configure() {
	if ! use debug; then
		G2CONF="--enable-silent-rules"
	else
		G2CONF="--disable-silent-rules"
	fi
	G2CONF="${myconf} \
			$(use_enable gnome-shell gnome-shell-extension) \
			$(use_enable nls) \
			$(use_enable applet)"
	export G2CONF
	gnome2_src_configure
}

src_install() {
	gnome2_src_install
	dodoc AUTHORS NEWS TODO
	dobashcomp data/completions/* || die
}
