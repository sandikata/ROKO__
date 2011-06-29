# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

GTK_SHARP_REQUIRED_VERSION="2.12"
GTK_SHARP_MODULE_DIR="gnomedesktop"

inherit gtk-sharp-module

SRC_URI+=" mirror://ubuntu/pool/main/g/${PN}2/${PN}2_${PV}-2ubuntu1.diff.gz"

SLOT="2"
KEYWORDS="~x86 ~amd64"
IUSE=""

RESTRICT="test"

src_prepare() {
	default_src_prepare
	patch -p1 < ../${PN}2_${PV}-2ubuntu1.diff -s
	epatch debian/patches/04_update_for_gnomedesktop_SONAME.dpatch
}
