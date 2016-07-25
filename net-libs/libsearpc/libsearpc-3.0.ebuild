# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# Created by Martin Kupec

EAPI=4

inherit eutils autotools python

DESCRIPTION="RPC library for Seafile"
HOMEPAGE="http://www.seafile.com"
#SRC_URI="http://seafile.googlecode.com/files/seafile-${PV}.tar.gz"
#SRC_URI="https://github.com/haiwen/libsearpc/archive/v${PV}.tar.gz"
SRC_URI="https://github.com/haiwen/${PN}/archive/v${PV}-latest.tar.gz -> ${PN}-${PV}.tar.gz"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=">=dev-lang/python-2.5
	>=dev-libs/glib-2.0
	dev-libs/jansson
	virtual/pkgconfig"

RDEPEND=""

S="${WORKDIR}/${P}-latest"

pkg_setup() {
	python_set_active_version 2
	python_pkg_setup
}

src_prepare() {
	./autogen.sh || die "src_prepare failed"
}

src_configure() {
	econf || die "econf failed"
}


src_compile() {
    emake -j1 || die "emake failed"
}

src_install() {
	#Fix wrong prefix in libsearpc.pc file
	cat "${S}/libsearpc.pc" | sed 's/(DESTDIR)//' > "${S}/libsearpc.pc_m"
	mv "${S}/libsearpc.pc_m" "${S}/libsearpc.pc"

	emake DESTDIR="${D}" install

	local d
	for d in README* ChangeLog AUTHORS NEWS TODO CHANGES THANKS BUGS \
			FAQ CREDITS CHANGELOG ; do
		[[ -s "${d}" ]] && dodoc "${d}"
	done
}
