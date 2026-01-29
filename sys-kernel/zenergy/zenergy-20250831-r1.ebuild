# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit linux-mod-r1

GIT_COMMIT="58f2fda7184fbde95033f492f7c54990552ef86f"

DESCRIPTION="Linux kernel driver for reading RAPL registers for AMD Zen CPUs"
HOMEPAGE="https://github.com/BoukeHaarsma23/zenergy"
SRC_URI="https://github.com/BoukeHaarsma23/zenergy/archive/${GIT_COMMIT}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/${PN}-${GIT_COMMIT}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

MODULES_KERNEL_MIN=5.10
MODULES_KERNEL_MAX=6.19
CONFIG_CHECK="HWMON PCI AMD_NB"

PATCHES=( "${FILESDIR}/${PN}-amd_phoenix.patch" )

src_compile() {
    local modlist=( ${PN}=kernel/drivers/hwmon:${S} )
    local modargs=(
        NIH_SOURCE="${KV_OUT_DIR}"
        KDIR="${KV_OUT_DIR}"
    )
    linux-mod-r1_src_compile
}
