# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

ETYPE="sources"

inherit calculate-kernel-2 eutils

DESCRIPTION="Full sources including the Calculate patchset for the ${KV_MAJOR}.${KV_MINOR} kernel tree"
KEYWORDS="amd64 x86"
HOMEPAGE="http://www.calculate-linux.org"

SRC_URI="${KERNEL_URI} ${ARCH_URI} ${CALC_URI}"

UNIPATCH_LIST="${DISTDIR}/${PN}-${CKV}.tar.bz2"

DEPEND="vmlinuz? ( >=sys-kernel/calckernel-3.4.15-r5
	>=sys-apps/calculate-builder-2.2.14
	|| ( app-arch/xz-utils app-arch/lzma-utils )
	sys-apps/v86d )"

IUSE=""
CL_KERNEL_OPTS="--lvm --mdadm --dmraid"

src_unpack() {
	calculate-kernel-2_src_unpack
}

pkg_postinst() {
	calculate-kernel-2_pkg_postinst
}
