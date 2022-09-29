# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
EXTRAVERSION="-cachyos"
K_SECURITY_UNSUPPORTED="1"
ETYPE="sources"
inherit kernel-2
#detect_version


DESCRIPTION="CachyOS are improved kernels that improve performance and other aspects."
HOMEPAGE="https://github.com/CachyOS/linux-cachyos"
SRC_URI="https://git.kernel.org/torvalds/t/linux-6.0-rc7.tar.gz"

LICENSE=""
SLOT="testing"
KEYWORDS=""
IUSE="bore tt"
REQUIRED_USE="bore? ( !tt ) tt? ( !bore )"

DEPEND="virtual/linux-sources"
RDEPEND="${DEPEND}"
BDEPEND=""

S="${WORKDIR}/linux-6.0-rc7"

src_unpack() {
	unpack linux-${KV_MAJOR}.0${RELEASE}.tar.gz
}

src_prepare() {
	eapply "${FILESDIR}/6.0/6.0-cachyos-base-all.patch"
	eapply "${FILESDIR}/6.0/6.0-amd-idle-fix.patch" # A performance fix for recent large AMD systems that avoids an ancient cpu idle hardware workaround. https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=a1375562c0a87f0fa2eaf3e8ce15824696d4170a

#	if use high-hz; then
#		eapply "${FILESDIR}/0001-high-hz.patch"
#	fi

	if use bore; then
		eapply "${FILESDIR}/6.0/6.0-bore.patch"
	fi

	if use tt; then
		eapply "${FILESDIR}/6.0/6.0-tt-cachy-dev.patch"
	fi

#	if use cacule; then
#		eapply "${FILESDIR}/0001-cacULE-cachy.patch"
#	fi

#	if use prjc; then
#		eapply "${FILESDIR}/0001-prjc-cachy.patch"
#	fi

	eapply_user

	# prepare default config
	if use bore; then
		cp "${FILESDIR}/config-x86_64-bore" .config && elog "BORE config applied" || die
	fi

#	if use prjc; then
#		cp "${FILESDIR}/config-x86_64-prjc" .config && elog "PRJC config applied"
#	fi

	if use tt; then
		cp "${FILESDIR}/config-x86_64-tt" .config && elog "TaskType config applied" || die
	fi
}

pkg_postinst() {
	elog "Default kernel config depending on selected scheduler has been applied."
	elog "You have to build kernel manually!"
	elog "Initramfs is required for all default configurations (dracut or genkernel)"
}
