# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit linux-mod-r1 systemd

DESCRIPTION="CPU monitoring software designed for the 64-bits Processors, like top"
HOMEPAGE="https://www.cyring.fr/"
SRC_URI="https://github.com/cyring/$PN/archive/$PV.tar.gz -> $P.tar.gz"
S="${WORKDIR}/CoreFreq-${PV}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-* ~amd64"

IUSE="doc systemd"

DEPEND="dev-build/make
	kernel_linux? ( virtual/linux-sources )"

BDEPEND="sys-devel/gcc
	dev-build/make
	dev-vcs/git"

RDEPEND="sys-libs/glibc"

CONFIG_CHECK="SMP X86_MSR ~HOTPLUG_CPU ~CPU_IDLE ~CPU_FREQ ~PM_SLEEP ~DMI ~XEN ~AMD_NB ~HAVE_PERF_EVENTS"

pkg_setup() {
	get_version
	require_configured_kernel
	linux-mod-r1_pkg_setup
}

QA_PREBUILT="
	usr/bin/${PN}d
	/usr/bin/${PN}-cli
"

src_compile() {
	local modlist=( corefreqk=misc::build )
	linux-mod-r1_src_compile
}

src_install() {
	linux-mod-r1_src_install
	dobin build/corefreqd build/corefreq-cli
	insinto /usr/lib/modules-load.d
	doins "${FILESDIR}"/corefreqk.conf
	newconfd "${FILESDIR}/${PN}.conf" "${PN}"
	doinitd "${FILESDIR}/${PN}"
	use systemd && systemd_dounit ${PN}d.service
	use doc && dodoc README.md
}

pkg_postinst() {
	linux-mod-r1_pkg_postinst
	einfo "To be able to use corefreq, you need to load kernel module:"
	einfo "`modprobe corefreqk`"
	einfo "After that - start daemon with corefreqd"
	einfo "or by `systemctl start corefreqd`"
	einfo "And only after that you can start corefreq-cli"
}
