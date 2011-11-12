# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="3"

PYTHON_DEPEND="2:2.6"

inherit base autotools-utils python

DESCRIPTION="The libuser library implements a standardized interface for manipulating and administering user and group accounts."
HOMEPAGE="https://fedorahosted.org/libuser"
SRC_URI="https://fedorahosted.org/releases/l/i/${PN}/${P}.tar.xz"

LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE="ldap +popt sasl selinux nls"
COMMON_DEPEND="dev-libs/glib:2
	>=sys-devel/gettext-0.17
	virtual/pam
	ldap? ( net-nds/openldap )
	popt? ( dev-libs/popt )
	sasl? ( dev-libs/cyrus-sasl
		  ldap? ( net-nds/openldap[sasl] ) )
	selinux? ( sys-libs/libselinux )"
DEPEND="
	sys-devel/bison
	${COMMON_DEPEND}"
RDEPEND="${COMMON_DEPEND}"

DOCS=(README NEWS TODO)

AUTOTOOLS_IN_SOURCE_BUILD=1

pkg_setup() {
	python_set_active_version 2
	python_need_rebuild
}

src_configure() {

	local myeconfargs=(
		$(use_with ldap)
		$(use_with popt)
		$(use_with sasl)
		$(use_with selinux)
		$(use_enable nls)
		--with-python
		--disable-rpath
		--disable-gtk-doc-html )
	autotools-utils_src_configure
}

src_test() {
	if has_version net-nds/openldap minimal ; then
		ewarn "Test require build net-nds/openldap without minimal use flag"
	fi
	default
}

src_install() {
	strip-linguas -i po

	autotools-utils_src_install "LINGUAS=""${LINGUAS}"""
	remove_libtool_files all
}
