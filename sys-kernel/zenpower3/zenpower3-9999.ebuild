# Copyright 2022-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit linux-mod-r1

DESCRIPTION="Linux kernel driver for reading sensors of AMD Zen family CPUs"
HOMEPAGE="https://git.exozy.me/a/zenpower3"

inherit git-r3
EGIT_REPO_URI="https://git.exozy.me/a/zenpower3.git"
EGIT_BRANCH="master"

LICENSE="GPL-2"
SLOT="0"

RDEPEND="!sys-kernel/zenpower"

CONFIG_CHECK="HWMON PCI AMD_NB ~!SENSORS_K10TEMP"

src_prepare() {
	# Set kernel build dir
	sed -i "s@^KERNEL_BUILD.*@KERNEL_BUILD := ${KV_DIR}@" "${S}/Makefile" || die "Could not fix build path"

	default
}

src_compile() {
	local modlist=( zenpower=misc:"${S}" )

	linux-mod-r1_src_compile
}
