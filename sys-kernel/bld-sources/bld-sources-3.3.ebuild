# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
K_SECURITY_UNSUPPORTED="1"
K_DEBLOB_AVAILABLE="1"
CKV=3.3.0
EXTRAVERSION=-bld
ETYPE="sources"
inherit calculate-kernel-old
detect_version
detect_arch

DESCRIPTION="This is an alternate CPU load distribution technique for Linux kernel scheduler. "
HOMEPAGE="http://code.google.com/p/bld/"
SRC_URI="${KERNEL_URI}"

LICENSE=""
SLOT="3.3"
KEYWORDS="~amd64 ~x86"
IUSE="deblob +vmlinuz"

DEPEND="vmlinuz? ( >=sys-kernel/calckernel-3.4.18
	>=sys-apps/calculate-builder-2.2.22-r2
	|| ( app-arch/xz-utils app-arch/lzma-utils )
	sys-apps/v86d
	!<net-wireless/rtl8192se-3.0
	)"
RDEPEND="${DEPEND}"

CL_KERNEL_OPTS="--lvm --mdadm --dmraid"

src_prepare() {
	epatch "${FILESDIR}"/BLD_3.3-rc3-feb12.patch
	epatch "${FILESDIR}"/4200_fbcondecor-0.9.6.patch
#	epatch "${FILESDIR}"/Makefile-bld.patch
}
