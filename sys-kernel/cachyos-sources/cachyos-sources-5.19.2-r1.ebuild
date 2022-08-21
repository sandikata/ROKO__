# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
EXTRAVERSION="-cachyos"
K_SECURITY_UNSUPPORTED="1"
ETYPE="sources"
inherit kernel-2
detect_version

DESCRIPTION="CachyOS are improved kernels that improve performance and other aspects."
HOMEPAGE="https://github.com/CachyOS/linux-cachyos"
SRC_URI="${KERNEL_URI}"

LICENSE=""
SLOT="5.19-unstable"
KEYWORDS="~amd64"
IUSE="bore high-hz prjc tt"
REQUIRED_USE="bore? ( !prjc !tt ) prjc? ( !bore !tt ) tt? ( high-hz !bore !prjc )"

DEPEND="virtual/linux-sources"
RDEPEND="${DEPEND}"
BDEPEND=""

src_prepare() {
	eapply "${FILESDIR}/${KV_MAJOR}.${KV_MINOR}/5.19-cachyos-base-all-dev.patch"

	if use high-hz; then
		eapply "${FILESDIR}/${KV_MAJOR}.${KV_MINOR}/5.19-high-hz.patch"
	fi

	if use bore; then
		eapply "${FILESDIR}/${KV_MAJOR}.${KV_MINOR}/5.19-bore.patch"
	fi

	if use tt; then
		eapply "${FILESDIR}/${KV_MAJOR}.${KV_MINOR}/5.19-tt-cachy.patch"
	fi

	if use prjc; then
		eapply "${FILESDIR}/${KV_MAJOR}.${KV_MINOR}/5.19-prjc-cachy.patch"
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
