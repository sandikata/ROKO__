# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
ETYPE="sources"
K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="58"
K_SECURITY_UNSUPPORTED="1"
K_NOSETEXTRAVERSION="1"
XANMOD_VERSION="1"
XANMOD_URI="https://github.com/xanmod/linux/releases/download/"

HOMEPAGE="https://xanmod.org"
LICENSE+=" CDDL"
KEYWORDS="~amd64"
IUSE="tasktype"

inherit kernel-2
detect_version

DESCRIPTION="XanMod Kernel sources with Task Type option and including the Gentoo patchset"
SRC_URI="
	${KERNEL_BASE_URI}/linux-${KV_MAJOR}.${KV_MINOR}.tar.xz
	!tasktype? ( ${XANMOD_URI}/${OKV}-xanmod${XANMOD_VERSION}/patch-${OKV}-xanmod${XANMOD_VERSION}.xz )
	tasktype? ( ${XANMOD_URI}/${OKV}-xanmod${XANMOD_VERSION}-tt/patch-${OKV}-xanmod${XANMOD_VERSION}-tt.xz )
	${GENPATCHES_URI}"

# excluding all minor kernel revision patches; XanMod will take care of that
UNIPATCH_EXCLUDE="${UNIPATCH_EXCLUDE} 1*_linux-${KV_MAJOR}.${KV_MINOR}.*.patch"

src_unpack() {
	use tasktype &&	UNIPATCH_LIST+="${DISTDIR}/patch-${OKV}-xanmod${XANMOD_VERSION}-tt.xz " || UNIPATCH_LIST+="${DISTDIR}/patch-${OKV}-xanmod${XANMOD_VERSION}.xz "
	kernel-2_src_unpack
}

pkg_postinst() {
	elog "The XanMod team strongly suggests the use of updated CPU microcodes with its"
	elog "kernels. For details, see https://wiki.gentoo.org/wiki/Microcode ."
	kernel-2_pkg_postinst
}
