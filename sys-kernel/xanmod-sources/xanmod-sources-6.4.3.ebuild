# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
ETYPE="sources"
K_SECURITY_UNSUPPORTED="1"
K_NOSETEXTRAVERSION="1"
K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="5"
XANMOD_VER="1"
PRJC_VER="$(ver_cut 1-2)"
PRJC_REV="1"
PRJC_GLUE_VER="6.3.0"

IUSE=""

inherit kernel-2
detect_version

DESCRIPTION="Full XanMod sources including the Gentoo patchset"
HOMEPAGE="https://xanmod.org"
KEYWORDS="~amd64"

LICENSE+=" CDDL"

XANMOD_URI="https://github.com/xanmod/linux/releases/download"
XANMOD_PATCH="1000-xanmod-${OKV}-${XANMOD_VER}.patch.xz"

SRC_URI="
	${KERNEL_BASE_URI}/linux-${KV_MAJOR}.${KV_MINOR}.tar.xz
	${XANMOD_URI}/${OKV}-xanmod${XANMOD_VER}/patch-${OKV}-xanmod${XANMOD_VER%_rev*}.xz -> ${XANMOD_PATCH}
	${GENPATCHES_URI}
"

src_unpack() {
	UNIPATCH_LIST_DEFAULT=""
	UNIPATCH_LIST+=" ${DISTDIR}/${XANMOD_PATCH}"
	UNIPATCH_EXCLUDE+=" 1*_linux-${KV_MAJOR}.${KV_MINOR}.*.patch"
	kernel-2_src_unpack
}

pkg_postinst() {
	elog "MICROCODES"
	elog "xanmod-sources should be used with updated microcodes"
	elog "Read https://wiki.gentoo.org/wiki/Microcode"
	kernel-2_pkg_postinst
}
