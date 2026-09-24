# Copyright 2020-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
_PN=zenpower

inherit linux-mod-r1
DESCRIPTION="Linux kernel driver AMD Zen CPU monitoring (Zen 1-5)"
HOMEPAGE="
        https://github.com/mattkeenan/zenpower5
"

inherit git-r3
EGIT_REPO_URI="https://github.com/mattkeenan/zenpower5.git"

LICENSE="GPL-2"
SLOT="0"

CONFIG_CHECK="HWMON PCI AMD_NB"

DEPEND+=(
        !!sys-kernel/zenpower3
        !!sys-kernel/zenpower
)

src_prepare() {
        default
        eapply "${FILESDIR}/fix-cpuid.patch"
        sed -i "s|Wimplicit-fallthrough=3|Wimplicit-fallthrough|" Makefile || die
}

src_compile() {
        MODULES_MAKEARGS+=(
                TARGET="${KV_FULL}"
        )
        local modlist=(
                ${_PN}=kernel/drivers/hwmon:::all
        )
        linux-mod-r1_src_compile
}

src_install() {
        linux-mod-r1_src_install
        dodoc README.md
}
