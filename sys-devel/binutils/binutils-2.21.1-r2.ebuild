# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/binutils/binutils-2.21.1-r1.ebuild,v 1.2 2011/08/25 18:32:57 hwoarang Exp $

PATCHVER="1.1"
ELF2FLT_VER=""
inherit toolchain-binutils

KEYWORDS="~alpha amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 -sparc-fbsd -x86-fbsd"

src_configure() {
		econf --enable-gold=yes
}
