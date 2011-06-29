# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

ETYPE="sources"

K_DEBLOB_AVAILABLE="0"
K_SECURITY_UNSUPPORTED="1"

inherit kernel-2 eutils rpm
detect_version
detect_arch

KV_FULL="${KV_FULL/linux/rh}"
EXTRAVERSION="${EXTRAVERSION/linux/rh}"

DESCRIPTION="Full sources including the Red Hat Enterprise Linux sources patchset for the ${KV_MAJOR}.${KV_MINOR} kernel tree"
HOMEPAGE="http://www.redhat.com/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"

SRC_URI_PREFIX="http://ftp.redhat.com/pub/redhat/linux/enterprise"
SRC_URI="${SRC_URI_PREFIX}/6Client/en/os/SRPMS/kernel-2.6.32-71.18.2.el6.src.rpm
	${SRC_URI_PREFIX}/6ComputeNode/en/os/SRPMS/kernel-2.6.32-71.18.2.el6.src.rpm
	${SRC_URI_PREFIX}/6Server/en/os/SRPMS/kernel-2.6.32-71.18.2.el6.src.rpm
	${SRC_URI_PREFIX}/6Workstation/en/os/SRPMS/kernel-2.6.32-71.18.2.el6.src.rpm"

IUSE=""

RESTRICT="nomirror"

S="${WORKDIR}/linux-${KV_FULL}"

src_unpack() {
	rpm_unpack || die

	tar -xpf "${WORKDIR}/linux-2.6.32-71.18.2.el6.tar.bz2" || die
	mv "linux-2.6.32-71.18.2.el6" "${S}" || die
	rm -f "${WORKDIR}/linux-2.6.32-71.18.2.el6.tar.bz2" || die

	rm -f "${WORKDIR}/linux-kernel-test.patch" || die
	sed -i -e "s:^\(EXTRAVERSION =\).*:\1 ${EXTRAVERSION}:" "${S}/Makefile" || die
}

src_prepare() {

	cd "${S}"

	echo
	ewarn "In the original kernel rhel not have these patches."
	ewarn "Read ChangeLog."
	echo

	# acpi
	epatch "${FILESDIR}/${PVR}/acpi-ec-add-delay-before-write.patch" || die # https://bugzilla.kernel.org/show_bug.cgi?id=14733
	# fs
	epatch "${FILESDIR}/${PVR}/xfs-list-sort.patch" || die
	# font
	epatch "${FILESDIR}/${PVR}/font-8x16-iso-latin-1.patch" || die # http://sudormrf.wordpress.com/2010/10/23/ka-ping-yee-iso-latin-1 font-in-linux-kernel/

	epatch "${FILESDIR}/${PVR}/linux-2.6-hotfixes.patch" || die

}

src_install() {
	local version_h_name="usr/src/linux-${KV_FULL}/include/linux"
	local version_h="${ROOT}${version_h_name}"

	if [ -f "${version_h}" ]; then
		einfo "Discarding previously installed version.h to avoid collisions"
		addwrite "/${version_h_name}"
		rm -f "${version_h}"
	fi

	kernel-2_src_install

	#cd "${D}/usr/src/linux-${KV_FULL}"
	#local oldarch=${ARCH}
	#cp ${DISTDIR}/${K_SABKERNEL_CONFIG_FILE} .config || die "cannot copy kernel config"
	#zcat /proc/config.gz >> .config || die "cannot copy kernel config" # copies previous .config
	#unset ARCH
	#make oldconfig || die "failed to run oldconfig"
	#make modules_prepare || die "failed to run modules_prepare"
	#make && make modules_install firmware_install headers_install && make install && module-rebuild rebuild && boot-update || die "failed to build kernel"
	#rm .config || die "cannot remove .config"
	#rm Makefile || die "cannot remove Makefile"
	#rm include/linux/version.h || die "cannot remove include/linux/version.h"
	#fi
	#ARCH=${oldarch}

}
