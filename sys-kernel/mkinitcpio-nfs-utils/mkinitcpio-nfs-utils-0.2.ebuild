# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

DESCRIPTION="ipconfig and nfsmount tools for NFS root support in mkinitcpio"
HOMEPAGE="http://www.archlinux.org/"
SRC_URI="ftp://ftp.archlinux.org/other/mkinitcpio/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="sys-kernel/mkinitcpio"

src_install() {
	cd "${S}";
	emake DESTDIR="${D}" install || die
}
