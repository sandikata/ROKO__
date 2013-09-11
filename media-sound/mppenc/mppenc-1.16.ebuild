# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/mppenc/mppenc-1.16.ebuild,v 1.11 2007/11/23 21:26:20 corsair Exp $

inherit toolchain-funcs flag-o-matic

DESCRIPTION="musepack audio encoder"
HOMEPAGE="http://www.musepack.net/"
SRC_URI="http://files.musepack.net/source/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="amd64 ppc ppc64 sparc x86 ~x86-fbsd"
IUSE=""

DEPEND=">=dev-util/cmake-2.4"
RDEPEND=""

src_unpack() {
	unpack ${A}

	# Respect user-chosen CFLAGS
	sed -i -e '/CMAKE_C_FLAGS/d' "${S}/CMakeLists.txt"
}

src_compile() {
	tc-export CC CXX LD

	# Upstream uses this
	append-flags -ffast-math

	# maybe other big endian arches need this, too
	use ppc | use sparc && append-flags -D__APPLE__

	cmake \
		-DCMAKE_INSTALL_PREFIX=/usr \
		|| die "cmake failed"

	emake VERBOSE="1" || die "emake failed"
}

src_install() {
	emake -j1 DESTDIR="${D}" install || die "emake install failed"
	dodoc Changelog
}
