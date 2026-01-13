# Copyright 2022-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

KERNEL_IUSE_GENERIC_UKI=1
KERNEL_IUSE_MODULES_SIGN=1

inherit kernel-build

BASE_P=linux-${PV%.*}
PATCH_PV=${PV%_p*}
PATCHSET=linux-gentoo-patches-6.18.4
GENTOO_CONFIG_VER=g18

XANMOD_VERSION="1"

DESCRIPTION="Linux kernel built with XanMod and Gentoo patches + BORE"
HOMEPAGE="https://www.kernel.org/ https://xanmod.org/"
SRC_URI="
	https://cdn.kernel.org/pub/linux/kernel/v$(ver_cut 1).x/${BASE_P}.tar.xz
	https://downloads.sourceforge.net/xanmod/patch-${PATCH_PV}-xanmod${XANMOD_VERSION}.xz
	https://dev.gentoo.org/~mgorny/dist/linux/${PATCHSET}.tar.xz
	https://github.com/mgorny/gentoo-kernel-config/archive/${GENTOO_CONFIG_VER}.tar.gz
		-> gentoo-kernel-config-${GENTOO_CONFIG_VER}.tar.gz
"
S=${WORKDIR}/${BASE_P}

LICENSE="GPL-2"
KEYWORDS="-* ~amd64"

IUSE="debug"

RDEPEND="
	!sys-kernel/xanmod-kernel-bin:${SLOT}
"
BDEPEND="
	debug? ( dev-util/pahole )
"
PDEPEND="
	>=virtual/dist-kernel-${PV}
"

QA_FLAGS_IGNORED="
	usr/src/linux-.*/scripts/gcc-plugins/.*.so
	usr/src/linux-.*/vmlinux
"

src_prepare() {
	local patch
	eapply "${WORKDIR}"/patch-${PATCH_PV}-xanmod${XANMOD_VERSION}
	eapply "${WORKDIR}/${PATCHSET}"
	eapply "${FILESDIR}/0001-bore.patch"
	eapply "${FILESDIR}/0002-glitched-cfs.patch"
	eapply "${FILESDIR}/0002-sched-ext-coexistence-fix.patch"
	eapply "${FILESDIR}/0003-glitched-eevdf-additions.patch"
	eapply "${FILESDIR}/1000-prefer-prevcpu-for-wakeup-v7.patch"

	default

	# add Gentoo patchset version
	local extraversion=${PV#${PATCH_PV}}
	sed -i -e "s:^\(EXTRAVERSION =\).*:\1 ${extraversion/_/-}:" Makefile || die

	# prepare the default config
	case ${ARCH} in
		amd64)
			cp "${S}/CONFIGS/x86_64/config" .config || die
			;;
		*)
			die "Unsupported arch ${ARCH}"
			;;
	esac

	rm "${S}/localversion" || die
	local myversion="-xanmod${XANMOD_VERSION}-dist"
	echo "CONFIG_LOCALVERSION=\"${myversion}\"" > "${T}"/version.config || die
	local dist_conf_path="${WORKDIR}/gentoo-kernel-config-${GENTOO_CONFIG_VER}"

	local merge_configs=(
		"${T}"/version.config
		"${dist_conf_path}"/base.config
		"${dist_conf_path}"/6.12+.config
		"${FILESDIR}"/x86-64-v1.config-r1 # keep v1 for simplicity, distribution kernels support user modification.
	)
	use debug || merge_configs+=(
		"${dist_conf_path}"/no-debug.config
	)

	use secureboot && merge_configs+=(
		"${dist_conf_path}/secureboot.config"
		"${dist_conf_path}/zboot.config"
	)

	kernel-build_merge_configs "${merge_configs[@]}"
}
