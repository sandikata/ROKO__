# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

#
# Original Author: © 2007-2009 Mir Calculate, Ltd. 
# Purpose: Installing linux-desktop, linux-server. 
# Build the kernel from source.

inherit calculate eutils kernel-2
EXPORT_FUNCTIONS pkg_setup src_unpack src_compile src_install pkg_postinst

IUSE="vmlinuz"

detect_version
detect_arch

CKV=$(get_version_component_range 1-3)
SLOT=$(get_version_component_range 1-4)
KV_FULL="${PV}-calculate"

S="${WORKDIR}/linux-${KV_FULL}"
EXTRAVERSION="-calculate"

CALC_K_SUBV=.$(get_version_component_range 4)
[[ ${CALC_K_SUBV} == "." ]] && CALC_K_SUBV=

EXTRAVERSION="${CALC_K_SUBV}-calculate"

UNIPATCH_STRICTORDER=1

CALC_URI="ftp://ftp.calculate.ru/pub/calculate/${PN}/${PN}-${CKV}.tar.bz2
        ftp://ftp.calculate-linux.org/pub/calculate/${PN}/${PN}-${CKV}.tar.bz2
		http://mirror.yandex.ru/calculate/${PN}/${PN}-${CKV}.tar.bz2
		ftp://ftp.linux.kiev.ua/pub/Linux/Calculate/${PN}/${PN}-${CKV}.tar.bz2"

NEW_CALCULATE_OVERLAY="/var/lib/layman/calculate"
[[ -d ${ROOT}/${NEW_CALCULATE_OVERLAY} ]] &&
	CALCULATE_OVERLAY=${NEW_CALCULATE_OVERLAY} ||
	CALCULATE_OVERLAY="/usr/local/portage/layman/calculate"

MODULESDBFILE=${ROOT}/var/lib/module-rebuild/moduledb

calculate-kernel-old_pkg_setup() {
	kernel-2_pkg_setup
	local calculate_ini=${ROOT}/etc/calculate/calculate.ini
	[[ -e $calculate_ini ]] && \
		SYSTEM=$( sed -rn 's/^system\=(.*)/\1/p' $calculate_ini )
	[[ -n "$SYSTEM" ]] || SYSTEM=desktop
	if [[ -z "${KERNEL_CONFIG}" ]] || [[ ! -f "${KERNEL_CONFIG}" ]]
	then
		KERNEL_CONFIG="${ROOT}/${CALCULATE_OVERLAY}/profiles/kernel"
		[[ -n "$CARCH" ]] || CARCH=`arch`
		KERNEL_CONFIG="${KERNEL_CONFIG}/config-${SYSTEM}-${CARCH}-${CKV}"
	fi
	ewarn "After the kernel assemble perform command to update modules:"
	ewarn "  module-rebuild -X rebuild"
	ebeep 5
}

calculate-kernel-old_src_unpack() {
	kernel-2_src_unpack
}

vmlinuz_src_compile() {
	# disable sandbox
	export SANDBOX_ON=0
	export LDFLAGS=""
	mkdir -p ${WORKDIR}/boot
	cd ${S}
	einfo "Using kernel config from "$( readlink -f ${KERNEL_CONFIG} )
	cp ${KERNEL_CONFIG}  ${WORKDIR}/config || die "cannot copy kernel config"

	cp ${WORKDIR}/config ${S}/.config
	local GENTOOARCH="${ARCH}"
	unset ARCH

	DEFAULT_KERNEL_SOURCE="${S}" CMD_KERNEL_DIR="${S}" genkernel \
		--kerneldir=${S} \
		--kernel-config=${WORKDIR}/config \
		--cachedir=${WORKDIR}/cache \
		--makeopts=${MAKEOPTS} \
		--tempdir=${S}/temp \
		--logfile=${WORKDIR}/genkernel.log \
		--bootdir=${WORKDIR}/boot \
		--no-save-config \
		--kernname=${SYSTEM} \
		--no-menuconfig \
		--clean \
		--loglevel=2 \
		--mrproper \
		--no-cleartmp \
		--disklabel \
		--slowusb \
		--splash=tty1 \
		--all-ramdisk-modules \
		--unionfs \
		--module-prefix=${WORKDIR} \
		all || die "genkernel failed"
	
	cp ${S}/.config ${WORKDIR}/boot/config-${KV_FULL}-installed
	einfo "kernel: >> Distclean..."
	make distclean &>/dev/null || die "cannot perform distclean"
	ARCH="${GENTOOARCH}"
	mv ${WORKDIR}/boot/kernel-${SYSTEM}-*-${KV_FULL} \
		${WORKDIR}/boot/vmlinuz-${KV_FULL}-installed
	mv ${WORKDIR}/boot/initramfs-${SYSTEM}-*-${KV_FULL} \
		${WORKDIR}/boot/initramfs-${KV_FULL}-installed
	mv ${WORKDIR}/boot/System.map-${SYSTEM}-*-${KV_FULL} \
		${WORKDIR}/boot/System.map-${KV_FULL}-installed
	cp ${WORKDIR}/boot/System.map-${KV_FULL}-installed ${S}/System.map
	rm ${WORKDIR}/lib/modules/${KV_FULL}/build
	rm ${WORKDIR}/lib/modules/${KV_FULL}/source
}

calculate-kernel-old_src_compile() {
	use vmlinuz && vmlinuz_src_compile
}

vmlinuz_src_install() {
	cd ${WORKDIR}
	insinto /
	doins -r boot
	cd ${WORKDIR}/lib
	insinto /lib
	doins -r modules
	insinto /tmp
	doins -r firmware
	
	dosym /usr/src/linux-${KV_FULL} \
		"/lib/modules/${KV_FULL}/source" ||
		die "cannot install source symlink"
	dosym /usr/src/linux-${KV_FULL} \
		"/lib/modules/${KV_FULL}/build" || 
		die "cannot install build symlink"
	insinto /etc/modprobe.d
	newins "${FILESDIR}"/modprobe_i915.conf i915.conf || die
}

calculate-kernel-old_src_install() {
	kernel-2_src_install
	use vmlinuz && vmlinuz_src_install
}

vmlinuz_pkg_postinst() {
	calculate_update_splash ${ROOT}/boot/initramfs-${KV_FULL}-installed
	cp ${ROOT}/boot/initramfs-${KV_FULL}-installed \
		${ROOT}/boot/initramfs-${KV_FULL}-install-installed
	calculate_update_kernel ${KV_FULL} ${ROOT}/boot
	mkdir -p ${ROOT}/lib/firmware
	cp -a ${ROOT}/tmp/firmware/* ${ROOT}/lib/firmware/
	rm -rf ${ROOT}/tmp/firmware
	calculate_update_depmod
	calculate_update_modules

	[[ -f $MODULESDBFILE ]] &&
		sed -ri 's/a:1:sys-fs\/aufs2/a:0:sys-fs\/aufs2/' $MODULESDBFILE
}

calculate-kernel-old_pkg_postinst() {
	kernel-2_pkg_postinst

	KV_OUT_DIR=${ROOT}/usr/src/linux-${KV_FULL}
	[[ -e ${ROOT}/boot/config-${KV_FULL}-installed ]] &&
		cp ${ROOT}/boot/config-${KV_FULL}-installed ${KV_OUT_DIR}/.config ||
		cp ${KERNEL_CONFIG} ${KV_OUT_DIR}/.config

	cd ${KV_OUT_DIR}
	local GENTOOARCH="${ARCH}"
	unset ARCH
	ebegin "kernel: >> Running modules_prepare..."
	make modules_prepare &>/dev/null
	eend $? "Failed modules prepare"
	ARCH="${GENTOOARCH}"

	use vmlinuz && vmlinuz_pkg_postinst
}
