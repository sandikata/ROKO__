# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools edo flag-o-matic multilib-minimal

MY_PN="${PN/-compat/}"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="The Theora Video Compression Codec"
HOMEPAGE="https://www.theora.org"
SRC_URI="https://downloads.xiph.org/releases/theora/${MY_P}.tar.xz"
S="${WORKDIR}/${MY_P}"

LICENSE="BSD"
SLOT="0/2"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~loong ~mips ~ppc ~ppc64 ~riscv ~sparc ~x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos"
IUSE="+encode static-libs"

RDEPEND="media-libs/libogg:=[${MULTILIB_USEDEP}]
	encode? ( media-libs/libvorbis:=[${MULTILIB_USEDEP}] )"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

VARTEXFONTS=${T}/fonts

PATCHES=( "${FILESDIR}/${PN}"-1.0_beta2-flags.patch
	"${FILESDIR}/${P}"-underlinking.patch
	"${FILESDIR}/${P}"-libpng16.patch # bug 465450
	"${FILESDIR}/${P}"-fix-UB.patch # bug 620800
)

src_prepare() {
	default

	# bug 467006
	sed -i "s/AM_CONFIG_HEADER/AC_CONFIG_HEADERS/" configure.ac \
		|| die "sed failed for configure.ac"

	AT_M4DIR=m4 eautoreconf
}

multilib_src_configure() {
	use x86 && filter-flags -fforce-addr -frename-registers #200549

	local myconf=(
		--disable-spec
		"$(use_enable encode)"
		"$(use_enable static-libs static)"
	)
	ECONF_SOURCE="${S}" econf "${myconf[@]}"
}

multilib_src_install() {
	for lib in libtheora{.so.0.3.10,dec.so.1.1.4,enc.so.1.1.2} ; do
		edo install -D lib/.libs/"${lib}" -t \
		"${ED}"/usr/"$(get_libdir)"
		dosym ./"${lib}" usr/"$(get_libdir)"/"${lib%.*.*}"
	done
}
