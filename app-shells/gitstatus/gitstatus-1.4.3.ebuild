# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake flag-o-matic

LIBGIT_TAG=tag-82cefe2b42300224ad3c148f8b1a569757cc617a
LIBGIT_P="libgit2-romkatv-${LIBGIT_TAG}"
LIBGIT_DIR="${LIBGIT_P/-romkatv/}"

CMAKE_USE_DIR="${WORKDIR}/${LIBGIT_DIR}"
BUILD_DIR="${CMAKE_USE_DIR}_build"

DESCRIPTION="Git status for Bash and Zsh prompt"
HOMEPAGE="
	https://github.com/romkatv/gitstatus
	https://github.com/romkatv/libgit2
"
SRC_URI="
	https://github.com/romkatv/${PN}/archive/v${PV}.tar.gz
		-> ${P}.tar.gz
	https://github.com/romkatv/libgit2/archive/${LIBGIT_TAG}.tar.gz
		-> ${LIBGIT_P}.tar.gz
"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 ~arm ~arm64 ~ppc64 ~riscv ~x86"

src_configure() {
	mycmakeargs=(
		-DUSE_SSH=OFF
		-DZERO_NSEC=ON
		-DTHREADSAFE=ON
		-DUSE_HTTPS=OFF
		-DBUILD_CLAR=OFF
		-DUSE_GSSAPI=OFF
		-DUSE_NTLMCLIENT=OFF
		-DUSE_BUNDLED_ZLIB=ON
		-DBUILD_SHARED_LIBS=OFF
		-DREGEX_BACKEND=builtin
		-DUSE_HTTP_PARSER=builtin
		-DENABLE_REPRODUCIBLE_BUILDS=ON
	)
	cmake_src_configure
}

src_compile() {
	append-cflags $(test-flags-CC -fno-plt)

	cmake_src_compile

	local cxxflags=(
		"-I${CMAKE_USE_DIR}/include"
		-DGITSTATUS_ZERO_NSEC
		-D_GNU_SOURCE
	)
	local ldflags=(
		"-L${BUILD_DIR}"
		-static
	)

	append-cxxflags "${cxxflags[@]}"
	append-ldflags "${ldflags[@]}"
	emake all pkg
}

src_install() {
	insinto "/usr/share/${PN}"
	exeinto "${_}"

	doins gitstatus.*.{sh,zsh{,.zwc}} *.info
	doexe install

	exeinto "/usr/libexec/${PN}"
	doexe usrbin/gitstatusd

	dosym "../../../libexec/${PN}/gitstatusd" \
		"/usr/share/${PN}/usrbin/gitstatusd"

	dodoc {README,docs/listdir}.md
}
