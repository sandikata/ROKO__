# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# Created by Martin Kupec

EAPI=4

inherit eutils python autotools

DESCRIPTION="Cloud file syncing software"
HOMEPAGE="http://www.seafile.com"
SRC_URI="https://github.com/haiwen/${PN}/archive/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="console server client python riak fuse"

DEPEND="
	>=dev-lang/python-2.5[sqlite]
	>=net-libs/ccnet-${PV}[python]
	>=net-libs/libevhtp-1.1.6
	sys-devel/gettext
	virtual/pkgconfig
	dev-libs/jansson
	dev-libs/libevent
	client? ( >=net-libs/ccnet-2.1.2[client] )
	server? ( 	>=net-libs/ccnet-3.1.7[server]
				=dev-python/django-1.5*
				www-servers/gunicorn	
				dev-python/simplejson
				dev-python/mako
				dev-python/webpy
				dev-python/Djblets
				dev-python/chardet	)"


RDEPEND=""

pkg_setup() {
	python_set_active_version 2
	python_pkg_setup
}

src_prepare() {
	./autogen.sh || die "src_prepare failed"
	# epatch "${FILESDIR}/${PV}-seafile-admin-datadir-pathfix.patch"
}

src_configure() {
	econf \
		$(use_enable fuse) \
		$(use_enable riak) \
		$(use_enable client) \
		$(use_enable server) \
		$(use_enable python) \
		$(use_enable console) \ 
}

src_compile() {
	# dev-lang/vala does not provide a valac symlink
	mkdir ${S}/tmpbin
	ln -s $(echo $(whereis valac-) | grep -oE "[^[[:space:]]*$") ${S}/tmpbin/valac
	PATH="${S}/tmpbin/:$PATH" emake -j1 || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install
	SEAFILE_SHARE_PATH="/usr/share/seafile"
	insinto ${SEAFILE_SHARE_PATH}/${PV}
	doins -r ${S}/scripts
	dodoc ${S}/doc/cli-readme.txt 
	doman ${S}/doc/*.1
}
