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
SRC_URI="https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.19.tar.xz
		https://raw.githubusercontent.com/ptr1337/kernel-patches/master/5.19/all/0001-cachyos-base-all.patch
		https://raw.githubusercontent.com/ptr1337/kernel-patches/master/5.19/sched/0001-bore.patch
		https://raw.githubusercontent.com/ptr1337/kernel-patches/master/5.19/sched/0001-cacULE-cachy.patch
		https://raw.githubusercontent.com/ptr1337/kernel-patches/master/5.19/sched/0001-tt-cachy.patch
		https://raw.githubusercontent.com/ptr1337/kernel-patches/master/5.19/misc/0001-high-hz.patch"

LICENSE=""
SLOT="5.19"
KEYWORDS="~amd64"
IUSE="bore cacule high-hz tt"

DEPEND="virtual/linux-sources"
RDEPEND="${DEPEND}"
BDEPEND=""

src_prepare() {
	eapply "${DISTDIR}/0001-cachyos-base-all.patch"

	if use high-hz; then
		eapply "${DISTDIR}/0001-high-hz.patch"
	fi

	if use bore; then
		eapply "${DISTDIR}/0001-bore.patch"
	fi

	if use cacule; then
		eapply "{DISTDIR}/0001-cacULE-cachy.patch"
	fi

	if use tt; then
		eapply "{DISTDIR}/0001-tt-cachy.patch"
	fi

	eapply_user
}

