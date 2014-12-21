# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit toolchain-funcs flag-o-matic

DESCRIPTION="POSIX bindings for Lua"
HOMEPAGE="http://git.alpinelinux.org/cgit/luaposix.git"
SRC_URI="http://git.alpinelinux.org/cgit/luaposix.git/snapshot/${P}.tar.bz2"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=dev-lang/lua-5.1"
DEPEND="${RDEPEND}"


src_compile() {
	append-flags -fPIC
	emake \
		CFLAGS="${CFLAGS}" \
		LDFLAGS="${LDFLAGS}" \
		CC="$(tc-getCC)" \
		LD="$(tc-getCC)" \
		|| die
}

src_install() {
	emake DESTDIR=${D} PREFIX=/usr install || die
}
