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

LICENSE="GPL"
SLOT="stable"
KEYWORDS="amd64"
IUSE="bore +eevdf high-hz latency prjc tt"
REQUIRED_USE="bore? ( !eevdf latency !prjc !tt ) eevdf? ( !bore !latency !prjc !tt )  prjc? ( !bore !eevdf !latency !tt ) tt? ( high-hz !bore !eevdf !latency !prjc )"

DEPEND="virtual/linux-sources"
RDEPEND="${DEPEND}"
BDEPEND=""

src_prepare() {
#	eapply "${FILESDIR}/${KV_MAJOR}.${KV_MINOR}/${KV_MAJOR}.${KV_MINOR}-amd-pstate-epp-enhancement.patch"

	eapply "${FILESDIR}/${KV_MAJOR}.${KV_MINOR}/${KV_MAJOR}.${KV_MINOR}-cachyos-base-all.patch"

#	if use cacule; then
#	    eapply "${FILESDIR}/${KV_MAJOR}.${KV_MINOR}/${KV_MAJOR}.${KV_MINOR}-cacULE-cachy.patch"
#	fi

	if use latency; then
		eapply "${FILESDIR}/${KV_MAJOR}.${KV_MINOR}/${KV_MAJOR}.${KV_MINOR}-latency-fix.patch"
	fi

	if use bore; then
		eapply "${FILESDIR}/${KV_MAJOR}.${KV_MINOR}/${KV_MAJOR}.${KV_MINOR}-bore-cachy.patch"
		eapply "${FILESDIR}/${KV_MAJOR}.${KV_MINOR}/${KV_MAJOR}.${KV_MINOR}-bore-tuning-sysctl.patch"
	fi

	if use eevdf; then
		eapply "${FILESDIR}/${KV_MAJOR}.${KV_MINOR}/${KV_MAJOR}.${KV_MINOR}-eevdf.patch"
	fi

	if use high-hz; then
		eapply "${FILESDIR}/${KV_MAJOR}.${KV_MINOR}/${KV_MAJOR}.${KV_MINOR}-high-hz.patch"
	fi

	if use tt; then
		eapply "${FILESDIR}/${KV_MAJOR}.${KV_MINOR}/${KV_MAJOR}.${KV_MINOR}-tt-cachy.patch"
	fi

	if use prjc; then
		eapply "${FILESDIR}/${KV_MAJOR}.${KV_MINOR}/${KV_MAJOR}.${KV_MINOR}-prjc-cachy.patch"
	fi

	eapply_user

	# prepare default config
	if use bore; then
		cp "${FILESDIR}/config-x86_64-bore" .config && elog "BORE config applied" || die
	fi

	#if use cacule; then
	#	cp "${FILESDIR}/config-x86_64-cacule" .config && elog "CaCULE config applied" || die
	#fi

	if use eevdf; then
		cp "${FILESDIR}/config-x86_64-eevdf" .config && elog "EEVDF config applied" || die
	fi

	if use prjc; then
		cp "${FILESDIR}/config-x86_64-prjc" .config && elog "PRJC config applied" || die
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
