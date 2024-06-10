# Copyright 2021-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake flag-o-matic toolchain-funcs

LIBGIT_TAG=tag-2ecf33948a4df9ef45a66c68b8ef24a5e60eaac6
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

pkg_pretend() {
	tc-is-clang || return 0

	ewarn 'if you are using sys-libs/libcxx to compile this,'
	ewarn 'please make sure to compile sys-libs/libcxx with static-libs'
	ewarn 'echo "sys-libs/libcxx static-libs" >> /etc/portage/package.use/libcxx'
}

src_prepare() {
	# there are few vulnerabilities from libgit2 that is present in romkatv fork,
	# but it looks like vulnerable parts of code not used by gitstatus
	#
	# https://github.com/libgit2/libgit2/security
	# https://github.com/romkatv/libgit2/issues/5
	(
		cd "${CMAKE_USE_DIR}"

		# this patch replaces vulnerable parts with `assert(false)`
		eapply "${FILESDIR}/${P}-abort-on-vulnerable-libgit2-funcions.patch"
	)

	cmake_src_prepare
}

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
	local DOCS=( {README,docs/listdir}.md )

	insinto "/usr/share/${PN}"
	exeinto "${_}"

	doins gitstatus.*.{sh,zsh{,.zwc}} *.info
	doexe install

	exeinto "/usr/libexec/${PN}"
	doexe usrbin/gitstatusd

	dosym "../../../libexec/${PN}/gitstatusd" \
		"/usr/share/${PN}/usrbin/gitstatusd"

	einstalldocs
}
