# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-boot/syslinux/syslinux-3.75.ebuild,v 1.1 2009/04/29 15:51:18 jer Exp $

inherit eutils

[[ ${PV} =~ ([0-9]+)\.([0-9]+)\.([0-9]+) ]]

SYSLINUX_PV=${BASH_REMATCH[1]}.${BASH_REMATCH[2]}
SYSLINUX_PN=syslinux
SYSLINUX_P=${SYSLINUX_PN}-${SYSLINUX_PV}

DESCRIPTION="Module calcmenu.c32 for syslinux"
HOMEPAGE="http://www.calculate-linux.org/main/ru/calcboot"
SRC_URI="mirror://kernel/linux/utils/boot/syslinux/${SYSLINUX_PV:0:1}.xx/${SYSLINUX_P/_/-}.tar.bz2
		ftp://ftp.calculate.ru/pub/calculate/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="~sys-boot/syslinux-4.04"
DEPEND="${RDEPEND}"

# This ebuild is a departure from the old way of rebuilding everything in syslinux
# This departure is necessary since hpa doesn't support the rebuilding of anything other
# than the installers.

# removed all the unpack/patching stuff since we aren't rebuilding the core stuff anymore

S=${WORKDIR}/${SYSLINUX_P}

src_unpack() {
	unpack ${SYSLINUX_P/_/-}.tar.bz2
	cd "${S}"
	cd com32/menu
	unpack ${P}.tar.bz2
	cd ../..
	# Fix building on hardened
	pwd
	pwd
	pwd
	epatch "${FILESDIR}"/${SYSLINUX_PN}-4.00-nopie.patch

	rm -f gethostip #bug 137081
}

src_compile() {
	#emake installer || die
	cd com32
	emake || die
}

src_install() {
	insinto /usr/share/syslinux
	cd com32/menu
	doins calcmenu.c32
	insinto /boot
	doins boot.jpg
	insinto /boot/grub
	doins grub-calculate.xpm.gz
}
