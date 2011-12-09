# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-kernel/vanilla-sources/vanilla-sources-3.2_rc4.ebuild,v 1.1 2011/11/29 18:58:44 psomas Exp $

EAPI="2"
K_NOUSENAME="yes"
K_NOSETEXTRAVERSION="yes"
K_SECURITY_UNSUPPORTED="1"
K_DEBLOB_AVAILABLE="0"
ETYPE="sources"
inherit kernel-2
detect_version

DESCRIPTION="Потребителска версия на vanilla-sources с включена поддръжка за fbcondecor"
HOMEPAGE="http://www.kernel.org"
SRC_URI="http://www.kernel.org/pub/linux/kernel/v3.0/testing/linux-3.2-rc4.tar.bz2"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="-deblob"

src_unpack() {
	unpack $A
}
src_prepare() {
	epatch "${FILESDIR}"/fbcondecor-0.9.6-3.0-rc2.patch
}


