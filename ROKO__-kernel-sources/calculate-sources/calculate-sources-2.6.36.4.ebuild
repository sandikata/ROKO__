# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

ETYPE="sources"

inherit calculate-kernel-2 eutils

DESCRIPTION="Full sources including the Calculate patchset for the ${KV_MAJOR}.${KV_MINOR} kernel tree"
KEYWORDS="~amd64 ~x86"
HOMEPAGE="http://www.calculate-linux.org"

SRC_URI="${KERNEL_URI} ${ARCH_URI} ${CALC_URI}"

UNIPATCH_LIST="${DISTDIR}/${PN}-${CKV}.tar.bz2"

DEPEND="vmlinuz? ( >=sys-kernel/calckernel-3.4.14
	>=sys-apps/calculate-builder-2.2.11-r2
	|| ( app-arch/xz-utils app-arch/lzma-utils )
	sys-apps/v86d )"

IUSE="bfq bfs"

src_unpack() {
	calculate-kernel-2_src_unpack

	# apply patch bfq
	if use bfq
	then
		epatch "${FILESDIR}/1800_BFQ-2.6.36.patch" || \
			die "Failed apply bfq patch"
	fi
	# apply patch bfs
	if use bfs
	then
		epatch "${FILESDIR}/1810_sched-bfs-360-2.6.36.3.patch" || \
			die "Failed apply bfs patch"
	fi
}

pkg_postinst() {
	calculate-kernel-2_pkg_postinst
	if use bfq
	then
		ewarn ""
		ewarn "Change value of elevator to bfq in /boot/grub/grub.conf for"
		ewarn "using BFQ I/O scheduler."
		ewarn "Part of grub.conf for example:"
		ewarn "kernel /boot/vmlinuz-a7acd396 root=/dev/sda2 elevator=bfq"
		ewarn ""
	fi
	einfo "For more info on this patchset, and how to report problems, see:"
	einfo "${HOMEPAGE}"
}
