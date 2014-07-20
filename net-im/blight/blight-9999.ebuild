# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI=5

inherit git-2

DESCRIPTION="Blight is a cross-platform graphical user interface for Tox written in Racket"
HOMEPAGE="https://github.com/lehitoskin/blight"
EGIT_REPO_URI="git://github.com/lehitoskin/blight
				https://github.com/lehitoskin/blight"
LICENSE="GPL-3"
SLOT="0"

RDEPEND="net-libs/tox
		>=dev-db/sqlite-3.8.2
		>=dev-scheme/racket-6.0.1[X]"

src_prepare() {
		raco pkg install --no-setup github://github.com/lehitoskin/libtoxcore-racket/master
		epatch "$FILESDIR/${P}.patch"
}

src_compile() {
		emake
}

src_install() {
		emake DESTDIR="${D}/usr" install
}
