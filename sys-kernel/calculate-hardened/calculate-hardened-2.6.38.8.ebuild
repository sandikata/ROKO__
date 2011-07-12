# Автор: Росен Александров - e-mail: sandikata@yandex.ru - jabber: roko@calculate-linux.org - Freenode - ROKO__
# Лиценз: GPL2
# $Header: $

ETYPE="sources"
inherit kernel-2 eutils
detect_version
EAPI=3
LICENSE="GPL-2"
SLOT="0"
IUSE="hardened vmlinuz"
DESCRIPTION="Calculate Linux Ядро с допълнителна поддръжка за Hardened ${KV_MAJOR}.${KV_MINOR}"
HOMEPAGE="http://calculate-linux.ru/"
KEYWORDS="amd64 x86"
CKV=2.6.38.8
KERNEL_ARCHIVE="linux-${CKV}.tar.bz2"
SRC_URI="${KERNEL_URI}"
UNIPATCH_LIST="${DISTDIR}/calculate-sources-2.6.38.tar.bz2 ${DISTDIR}/hardened-patches-2.6.38.8.extras.tar.bz2"

DEPEND="vmlinuz? ( >=sys-kernel/calckernel-3.4.15-r5
	>=sys-apps/calculate-builder-2.2.14
	|| ( app-arch/xz-utils app-arch/lzma-utils )
	sys-apps/v86d )"

RDEPEND="=sys-apps/gradm-2.2.2*"

CL_KERNEL_OPTS="--lvm --mdadm --dmraid"

src_unpack() {
unpack ${KERNEL_ARCHIVE}

	if use hardened
	then
		unipatch ${DISTDIR}/hardened-patches-2.6.38.8.extras.tar.bz2 || die
	fi
}

pkg_postinst() {
	kernel-2_pkg_postinst

	local GRADM_COMPAT="sys-apps/gradm-2.2.2*"

	ewarn
	ewarn "Hardened Gentoo provides three different predefined grsecurity level:"
	ewarn "[server], [workstation], and [virtualization]."
	ewarn
	ewarn "Those who intend to use one of these predefined grsecurity levels"
	ewarn "should read the help associated with the level.  Users importing a"
	ewarn "kernel configuration from a kernel prior to ${PN}-2.6.32,"
	ewarn "should review their selected grsecurity/PaX options carefully."
	ewarn
	ewarn "Users of grsecurity's RBAC system must ensure they are using"
	ewarn "${GRADM_COMPAT}, which is compatible with ${PF}."
	ewarn "It is strongly recommended that the following command is issued"
	ewarn "prior to booting a ${PF} kernel for the first time:"
	ewarn
	ewarn "emerge -na =${GRADM_COMPAT}"
	ewarn
}

