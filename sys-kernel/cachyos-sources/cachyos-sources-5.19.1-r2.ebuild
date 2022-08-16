# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
EXTRAVERSION="-cachyos-test"
K_SECURITY_UNSUPPORTED="1"
ETYPE="sources"
inherit kernel-2
detect_version

DESCRIPTION="CachyOS are improved kernels that improve performance and other aspects."
HOMEPAGE="https://github.com/CachyOS/linux-cachyos"
SRC_URI="${KERNEL_URI} \
		https://raw.githubusercontent.com/CachyOS/kernel-patches/master/${KV_MAJOR}.${KV_MINOR}/all/0001-cachyos-base-all-dev.patch -> 5.19-cachyos-base-all-dev.patch \
		https://raw.githubusercontent.com/CachyOS/kernel-patches/master/${KV_MAJOR}.${KV_MINOR}/sched/0001-bore.patch -> 5.19-bore.patch \
		https://raw.githubusercontent.com/CachyOS/kernel-patches/master/${KV_MAJOR}.${KV_MINOR}/sched/0001-tt-cachy-dev.patch -> 5.19-tt-cachy-dev.patch \
		https://raw.githubusercontent.com/CachyOS/kernel-patches/master/${KV_MAJOR}.${KV_MINOR}/misc/0001-high-hz.patch -> 5.19-high-hz.patch \
		https://raw.githubusercontent.com/CachyOS/kernel-patches/master/${KV_MAJOR}.${KV_MINOR}/sched/0001-cacULE-cachy.patch -> 5.19-cacULE-cachy.patch \
		https://raw.githubusercontent.com/CachyOS/kernel-patches/master/${KV_MAJOR}.${KV_MINOR}/sched/0001-prjc-cachy.patch -> 5.19-prjc-cachy.patch"

LICENSE=""
SLOT="5.19-testing"
KEYWORDS=""
IUSE="bore cacule high-hz prjc tt"
REQUIRED_USE="bore? ( !cacule !high-hz !prjc !tt ) cacule? ( !bore !high-hz !prjc !tt ) prjc? ( !bore !cacule !high-hz !tt ) tt? ( high-hz !bore !cacule !prjc )"

DEPEND="virtual/linux-sources"
RDEPEND="${DEPEND}"
BDEPEND=""

src_prepare() {
	eapply "${DISTDIR}/5.19-cachyos-base-all-dev.patch"

	if use high-hz; then
		eapply "${DISTDIR}/5.19-high-hz.patch"
	fi

	if use bore; then
		eapply "${DISTDIR}/5.19-bore.patch"
	fi

	if use tt; then
		eapply "${DISTDIR}/5.19-tt-cachy-dev.patch"
	fi

	if use cacule; then
		eapply "${DISTDIR}/5.19-cacULE-cachy.patch"
	fi

	if use prjc; then
		eapply "${DISTDIR}/5.19-prjc-cachy.patch"
	fi

	eapply_user

	# prepare default config
	if use bore; then
		cp "${FILESDIR}/config-x86_64-bore" .config && elog "BORE config applied" || die
	fi

	if use prjc; then
		cp "${FILESDIR}/config-x86_64-prjc" .config && elog "PRJC config applied"
	fi

	if use tt; then
		cp "${FILESDIR}/config-x86_64-tt" .config && elog "TaskType config applied" || die
	fi
}

pkg_postinst() {
	elog "Default kernel config depending on selected scheduler has been applied."
	elog "You have to build kernel manually!"
	elog "Initramfs is required for all default configurations (dracut or genkernel)"
}
