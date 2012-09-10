# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit lua

DESCRIPTION="Binding of three regular expression libraries (POSIX, PCRE and Oniguruma) to Lua"
HOMEPAGE="http://luaforge.net/projects/lrexlib/"
SRC_URI="http://luaforge.net/frs/download.php/3599/${P}.zip"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc oniguruma pcre"

RDEPEND=">=dev-lang/lua-5.1
	oniguruma? ( dev-libs/oniguruma )
	pcre? ( dev-libs/pcre )"
RDEPEND="${DEPEND}
	app-arch/unzip"

src_unpack() {
	unpack ${A}
	cd "${S}"

	sed -i \
		-e "s:\(MYCFLAGS =\):\1 -fPIC ${CFLAGS}:" \
		src/defaults.mak || die "sed failed"

	sed -i \
		-e "s/\(all:.*\)test/\1/" \
		Makefile || die "sed failed"

	if ! use pcre; then
		sed -i \
			-e "s/build_pcre//g" \
			-e "s/test_pcre//g" \
			Makefile || die "sed failed"
	fi

	if ! use oniguruma; then
		sed -i \
			-e "s/build_onig//g" \
			-e "s/test_onig//g" \
			Makefile || die "sed failed"
	fi
}

src_install() {
	if use doc; then
		dohtml -r doc/* || die "dodoc failed"
	fi

	lua_install_cmodule src/posix/rex_posix.so.${PV%.*}
	dosym rex_posix.so.${PV%.*} $(lua_get_libdir)/rex_posix.so || die "dosym failed"
	if use pcre; then
		lua_install_cmodule src/pcre/rex_pcre.so.${PV%.*}
		dosym rex_pcre.so.${PV%.*} $(lua_get_libdir)/rex_pcre.so || die "dosym failed"
	fi
	if use oniguruma; then
		lua_install_cmodule src/oniguruma/rex_onig.so.${PV%.*}
		dosym rex_onig.so.${PV%.*} $(lua_get_libdir)/rex_onig.so || die "dosym failed"
	fi
}

