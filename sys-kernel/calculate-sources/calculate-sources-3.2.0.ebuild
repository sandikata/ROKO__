# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

ETYPE="sources"

inherit calculate-kernel-3 eutils

DESCRIPTION="Full sources including the Calculate patchset for the ${KV_MAJOR}.${KV_MINOR} kernel tree"
HOMEPAGE="http://www.calculate-linux.org"
SRC_URI="${KERNEL_URI}"

LICENSE=""
SLOT="3.2"
KEYWORDS="~amd64"
IUSE="vmlinuz fbcondecor"

DEPEND="vmlinuz? ( >=sys-kernel/calckernel-3.4.18
	>=sys-apps/calculate-builder-2.2.22-r2
	|| ( app-arch/xz-utils app-arch/lzma-utils )
	sys-apps/v86d
	!<net-wireless/rtl8192se-3.0 )"
RDEPEND="${DEPEND}"

CL_KERNEL_OPTS="--lvm --mdadm --dmraid"

src_unpack() {
	calculate-kernel-3_src_unpack
	if use fbcondecor; then
	epatch "${FILESDIR}/4200_fbcondecor-0.9.6.patch"
	fi
}

pkg_postinst() {
	calculate-kernel-3_pkg_postinst
	elog "At this moment aufs3 patch is not available, and must run 'emerge
	aufs3' with enabled 'kernel-patch fuse ramfs' use flags, and then recompille
	kernel again."
	elog "x86 version available soon."
}

