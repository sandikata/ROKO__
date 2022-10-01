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

LICENSE="GPL"
SLOT="testing"
KEYWORDS=""
IUSE="bore cacule high-hz +latency +nest prjc tt"
REQUIRED_USE="bore? ( !cacule !nest !prjc !tt ) cacule? ( !bore !nest !prjc !tt ) nest? ( !bore !cacule latency !prjc !tt ) prjc? ( !bore !cacule latency !nest !tt ) tt? ( !bore !cacule high-hz !nest !prjc )"

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
#	eapply "${FILESDIR}/6.0/6.0-amd-pstate-epp-enhancement.patch"

	if use high-hz; then
		eapply "${FILESDIR}/6.0/6.0-high-hz.patch"
	fi

	if use latency; then
		eapply "${FILESDIR}/6.0/6.0-latency-fix.patch"
	fi

	if use nest; then
		eapply "${FILESDIR}/6.0/6.0-NEST.patch"
	fi

	if use bore; then
		eapply "${FILESDIR}/6.0/6.0-bore.patch"
	fi

	if use tt; then
		eapply "${FILESDIR}/6.0/6.0-tt.patch"
	fi

	if use cacule; then
		eapply "${FILESDIR}/6.0/6.0-cacULE-cachy.patch"
	fi

	if use prjc; then
		eapply "${FILESDIR}/6.0/6.0-prjc.patch"
	fi

	eapply_user

	# prepare default config
	if use bore; then
		cp "${FILESDIR}/config-x86_64-bore" .config && elog "BORE config applied" || die
	fi

	if use cacule; then
		cp "${FILESDIR}/config-x86_64-cacule" .config && elog "CaCULE config applied" || die
	fi

	if use nest; then
		cp "${FILESDIR}/config-x86_64-nest" .config && elog "NEST config applied" || die
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
