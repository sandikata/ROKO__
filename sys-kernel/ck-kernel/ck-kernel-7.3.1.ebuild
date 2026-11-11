# Copyright 2026 Rosen Aleksandrov
# Distributed under the terms of the GNU General Public License v2

EAPI=8

KERNEL_IUSE_GENERIC_UKI=1

inherit kernel-build toolchain-funcs

# CK дървото излиза само за базовата версия (v7.3-ck1), затова:
#   PV=7.3.1  ->  CK дърво v7.3-ck1 + kernel.org patch-7.3.1.xz (7.3 -> 7.3.1)
# При ново ck издание (ck2) вдигни само CK_REV.
CK_REV=1
CK_BASE=$(ver_cut 1-2)
CK_TAG=v${CK_BASE}-ck${CK_REV}
PATCH_PV=${PV%_p*}

PATCHSET=linux-gentoo-patches-${PATCH_PV}
CONFIG_VER=${PATCH_PV}-gentoo
GENTOO_CONFIG_P=gentoo-kernel-config-g19

DESCRIPTION="Linux kernel (Con Kolivas CK tree) built with Gentoo patches"
HOMEPAGE="
	https://github.com/ckolivas/linux
	https://wiki.gentoo.org/wiki/Project:Distribution_Kernel
	https://www.kernel.org/
"
SRC_URI+="
	https://github.com/ckolivas/linux/archive/refs/tags/${CK_TAG}.tar.gz
		-> linux-ck-${CK_BASE}-ck${CK_REV}.tar.gz
	https://distfiles.gentoo.org/pub/proj/dist-kernel/patchsets/$(ver_cut 1-2)/${PATCHSET}.tar.xz
	https://gitweb.gentoo.org/proj/dist-kernel/gentoo-kernel-config.git/snapshot/${GENTOO_CONFIG_P}.tar.bz2
	https://distfiles.gentoo.org/pub/proj/dist-kernel/config/fedora-kernel-config-${CONFIG_VER}.tar.xz
"
# stable patch само за x.y.z (за чисто x.y няма patch-x.y.xz)
if [[ -n $(ver_cut 3 ${PATCH_PV}) ]]; then
	SRC_URI+="
		https://cdn.kernel.org/pub/linux/kernel/v$(ver_cut 1).x/patch-${PATCH_PV}.xz
	"
fi
# GitHub архивът се разархивира в linux-<tag без водещото v>
S=${WORKDIR}/linux-${CK_BASE}-ck${CK_REV}

LICENSE="GPL-2"
KEYWORDS="~amd64"
IUSE="debug hardened"
RESTRICT="mirror"

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
	# ред както в gentoo-kernel: първо stable patch, после Gentoo patchset
	if [[ -f ${WORKDIR}/patch-${PATCH_PV} ]]; then
		eapply "${WORKDIR}/patch-${PATCH_PV}"
	fi
	eapply "${WORKDIR}/${PATCHSET}"

	default

	# добавя _pN суфикса (ако има) след "-ck1" от Makefile-а;
	# без суфикс EXTRAVERSION не се пипа
	local extraversion=${PV#${PATCH_PV}}
	if [[ -n ${extraversion} ]]; then
		sed -i -e "s:^\(EXTRAVERSION =.*\):\1${extraversion/_/-}:" Makefile || die
	fi

	# "-ck1" идва от самото CK дърво, затова тук е само "-dist"
	local myversion="-dist"
	use hardened && myversion+="-hardened"
	echo "CONFIG_LOCALVERSION=\"${myversion}\"" > "${T}"/version.config || die

	# базови MuQSS настройки; /etc/kernel/config.d/*.config се прилага
	# след тях и може да ги презапише
	cat > "${T}"/muqss.config <<-EOF || die
		CONFIG_SCHED_MUQSS=y
		CONFIG_SMT_NICE=y
		CONFIG_MUQSS_IOTIME=y
		CONFIG_RQ_MC_LLC=y
		CONFIG_HZ_100=y
		# CONFIG_HZ_250 is not set
		# CONFIG_HZ_300 is not set
		# CONFIG_HZ_1000 is not set
	EOF

	local dist_conf_path="${WORKDIR}/${GENTOO_CONFIG_P}"

	local merge_configs=(
		"${T}"/version.config
		"${dist_conf_path}"/base.config
		"${dist_conf_path}"/6.12+.config
		"${T}"/muqss.config
	)
	use debug || merge_configs+=(
		"${dist_conf_path}"/no-debug.config
	)
	if use hardened; then
		merge_configs+=( "${dist_conf_path}"/hardened-base.config )

		tc-is-gcc && merge_configs+=( "${dist_conf_path}"/hardened-gcc-plugins.config )

		if [[ -f "${dist_conf_path}/hardened-${ARCH}.config" ]]; then
			merge_configs+=( "${dist_conf_path}/hardened-${ARCH}.config" )
		fi
	fi

	use secureboot && merge_configs+=(
		"${dist_conf_path}/secureboot.config"
		"${dist_conf_path}/zboot.config"
	)

	# само amd64; за други архитектури върни case блока от gentoo-kernel
	[[ ${ARCH} == amd64 ]] || die "Unsupported arch ${ARCH}"
	cp "${WORKDIR}/fedora-kernel-config-${CONFIG_VER}/kernel-x86_64-fedora.config" .config || die

	kernel-build_merge_configs "${merge_configs[@]}"
}
