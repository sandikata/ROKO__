# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
ETYPE="sources"
K_WANT_GENPATCHES="base extras experimental"
K_GENPATCHES_VER="11"
K_SECURITY_UNSUPPORTED="1"
K_NOSETEXTRAVERSION="1"
XANMOD_VERSION="1"
XANMOD_URI="https://github.com/xanmod/linux/releases/download/"

HOMEPAGE="https://xanmod.org"
LICENSE+=" CDDL"
KEYWORDS="~amd64"

inherit kernel-2
detect_version

DESCRIPTION="XanMod kernel sources, including the Gentoo patchset"
SRC_URI="
	${KERNEL_BASE_URI}/linux-${KV_MAJOR}.${KV_MINOR}.tar.xz
	${XANMOD_URI}/${OKV}-xanmod${XANMOD_VERSION}/patch-${OKV}-xanmod${XANMOD_VERSION}.xz
	${GENPATCHES_URI}"
IUSE="+experimental"

UNIPATCH_LIST+="${DISTDIR}/patch-${OKV}-xanmod${XANMOD_VERSION}.xz ${FILESDIR}/z1950_cifs-fix-minor-compile-warning.patch"

# excluding all minor kernel revision patches; XanMod will take care of that
UNIPATCH_EXCLUDE="${UNIPATCH_EXCLUDE} 1*_linux-${KV_MAJOR}.${KV_MINOR}.*.patch"

# excluding CPU optimizations patches, since it's included in XanMod too
UNIPATCH_EXCLUDE="${UNIPATCH_EXCLUDE} 5*_*cpu-optimization*.patch"

# this patch needs to be applied after the minor version patches - i.e. after the xanmod patch. We do a little trolling and ignore it for now, just to re-add it with a Z at the end and apply it after the minor version has been fixed.
UNIPATCH_EXCLUDE="${UNIPATCH_EXCLUDE} 1950_cifs-fix-minor-compile-warning.patch"


pkg_postinst() {
	elog "The XanMod team strongly suggests the use of updated CPU microcodes with its"
	elog "kernels. For details, see https://wiki.gentoo.org/wiki/Microcode ."
	kernel-2_pkg_postinst
}
