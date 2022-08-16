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
SRC_URI="https://git.kernel.org/torvalds/t/linux-6.0-rc1.tar.gz \
		https://raw.githubusercontent.com/CachyOS/kernel-patches/master/6.0/all/0001-cachyos-base-all.patch -> 6.0-cachyos-base-all.patch \
		https://raw.githubusercontent.com/CachyOS/kernel-patches/master/6.0/sched/0001-bore.patch -> 6.0-bore.patch \
		https://raw.githubusercontent.com/CachyOS/kernel-patches/master/6.0/sched/0001-tt-cachy.patch -> 6.0-tt-cachy.patch \
		"

LICENSE=""
SLOT="6.0-testing"
KEYWORDS=""
IUSE="bore tt"
REQUIRED_USE="bore? ( !tt ) tt? ( !bore )"

DEPEND="virtual/linux-sources"
RDEPEND="${DEPEND}"
BDEPEND=""

S="${WORKDIR}/linux-6.0-rc1"

src_unpack() {
	unpack linux-${KV_MAJOR}.0${RELEASE}.tar.gz
}

src_prepare() {
	eapply "${DISTDIR}/6.0-cachyos-base-all.patch"

#	if use high-hz; then
#		eapply "${DISTDIR}/0001-high-hz.patch"
#	fi

	if use bore; then
		eapply "${DISTDIR}/6.0-bore.patch"
	fi

	if use tt; then
		eapply "${DISTDIR}/6.0-tt-cachy-dev.patch"
	fi

#	if use cacule; then
#		eapply "${DISTDIR}/0001-cacULE-cachy.patch"
#	fi

#	if use prjc; then
#		eapply "${DISTDIR}/0001-prjc-cachy.patch"
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
