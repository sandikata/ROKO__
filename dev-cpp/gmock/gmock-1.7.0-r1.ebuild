# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

PYTHON_COMPAT=( python2_7 )

inherit flag-o-matic libtool multilib-minimal python-any-r1

DESCRIPTION="Google's C++ mocking framework"
HOMEPAGE="http://code.google.com/p/googlemock/"
#SRC_URI="http://googlemock.googlecode.com/files/${P}.zip"
SRC_URI="https://src.fedoraproject.org/lookaside/extras/gmock/gmock-1.7.0.zip/073b984d8798ea1594f5e44d85b20d66/gmock-1.7.0.zip"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="static-libs +tr1 test"

RDEPEND="=dev-cpp/gtest-${PV}*[${MULTILIB_USEDEP},tr1(+)?]"
DEPEND="${RDEPEND}
	test? ( ${PYTHON_DEPS} )
	app-arch/unzip"

DOCS=""

pkg_setup() {
	# Stub to disable python_setup running when USE=-test.
	# We'll handle it down in src_test ourselves.
	:
	if ! use tr1; then
		append-cflags -DGTEST_USE_OWN_TR1_TUPLE=1
		append-cxxflags -DGTEST_USE_OWN_TR1_TUPLE=1
	fi
}

src_unpack() {
	default
	# make sure we always use the system one
	rm -r "${S}"/gtest/{Makefile,configure}* || die
}

src_prepare() {
	sed -i -r \
		-e '/^install-(data|exec)-local:/s|^.*$|&\ndisabled-&|' \
		Makefile.in
	elibtoolize
}

multilib_src_configure() {
	ECONF_SOURCE=${S} econf $(use_enable static-libs static)
}

multilib_src_test() {
	python_setup
	emake check
}

multilib_src_install() {
	DOCS="" default
	dobin scripts/gmock-config
}

multilib_src_install_all() {
	use static-libs || find "${ED}" -name '*.la' -delete
}
