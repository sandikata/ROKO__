# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/keybinder/Attic/keybinder-0.2.2.ebuild,v 1.6 2012/10/21 09:59:15 ssuominen dead $

EAPI=3

PYTHON_DEPEND="python? 2:2.5"

inherit python

DESCRIPTION="A library for registering global keyboard shortcuts"
HOMEPAGE="http://kaizer.se/wiki/keybinder/"
#SRC_URI="http://kaizer.se/publicfiles/${PN}/${P}.tar.gz"
SRC_URI="http://pkgs.fedoraproject.org/repo/pkgs/keybinder/keybinder-0.2.2.tar.gz/b4ccd4bd19f3ae3f0ab2cbda11fcd3ac/keybinder-0.2.2.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="lua python"

RDEPEND=">=x11-libs/gtk+-2.20:2
	x11-libs/libXext
	x11-libs/libXrender
	x11-libs/libX11
	lua? ( >=dev-lang/lua-5.1 )
	python? ( >=dev-python/pygobject-2.15.3:2
		>=dev-python/pygtk-2.12 )"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

pkg_setup() {
	if use python; then
		python_set_active_version 2
		python_pkg_setup
	fi
}

src_prepare() {
	rm -f py-compile
	ln -s $(type -P true) py-compile
}

src_configure() {
	local myconf
	use lua || myconf="--disable-lua"

	econf \
		--disable-dependency-tracking \
		$(use_enable python) \
		${myconf}
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS NEWS README

	find "${D}" -name '*.la' -exec rm -f '{}' +
}

pkg_postinst() {
	use python && python_mod_optimize keybinder
}

pkg_postrm() {
	use python && python_mod_cleanup keybinder
}
