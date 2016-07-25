# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# Created by Martin Kupec

EAPI=4

inherit eutils autotools python

DESCRIPTION="Networking library for Seafile"
HOMEPAGE="http://www.seafile.com"
SRC_URI="https://github.com/haiwen/${PN}/archive/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~x86 ~amd64"
IUSE="client server python cluster ldap"

DEPEND="=net-libs/libsearpc-3.0
	>=dev-libs/glib-2.0
	>=dev-lang/vala-0.8
	dev-db/libzdb
	virtual/pkgconfig"

RDEPEND=""

pkg_setup() {
	python_set_active_version 2
	python_pkg_setup
}

src_prepare() {
	./autogen.sh || die "src_prepare failed"
}

src_configure() {
	econf 	$(use_enable server) \
			$(use_enable client) \
			$(use_enable python) \
			$(use_enable cluster) \
			$(use_enable ldap) \
			--enable-console
}

src_compile() {
	# dev-lang/vala does not provide a valac symlink
	mkdir ${S}/tmpbin
	ln -s $(echo $(whereis valac-) | grep -oE "[^[[:space:]]*$") ${S}/tmpbin/valac
	PATH="${S}/tmpbin/:$PATH" emake -j1 || die "emake failed"
}
