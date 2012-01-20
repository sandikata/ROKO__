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

if [[ ${KV_MAJOR} -ge 3 ]]
then
	CKV=$(get_version_component_range 1-3)
	CL_PATCH=$(get_version_component_range 1-2)
	local oldifs=${IFS}
	export IFS="."
	local OKV_ARRAY=( $OKV )
	export IFS=${oldifs}
	if [[ ${#OKV_ARRAY[@]} -ge 3 ]]; then
		# handle calculate-sources-3.x.y correctly
		if [[ ${KV_PATCH} -gt 0 ]]; then
			KERNEL_URI="${KERNEL_BASE_URI}/patch-${OKV}.bz2"
			UNIPATCH_LIST_DEFAULT="${DISTDIR}/patch-${CKV}.bz2"
		fi
		KERNEL_URI="${KERNEL_URI} ${KERNEL_BASE_URI}/linux-${KV_MAJOR}.${KV_MINOR}.tar.bz2"
	else
		KERNEL_URI="${KERNEL_BASE_URI}/linux-${OKV}.tar.bz2"
	fi
else
	die "Eclass is used only for kernel-3"
fi
SLOT=$(get_version_component_range 1-4)
KV_FULL="${PV}-calculate"
S="${WORKDIR}/linux-${KV_FULL}"

CALC_K_SUBV=.$(get_version_component_range 4)
[[ ${CALC_K_SUBV} == "." ]] && CALC_K_SUBV=

EXTRAVERSION="${CALC_K_SUBV}-calculate"

UNIPATCH_STRICTORDER=1

CALC_URI="ftp://ftp.calculate.ru/pub/calculate/${PN}/${PN}-${CL_PATCH}.tar.bz2
        ftp://ftp.calculate-linux.org/pub/calculate/${PN}/${PN}-${CL_PATCH}.tar.bz2
		http://mirror.yandex.ru/calculate/${PN}/${PN}-${CL_PATCH}.tar.bz2
		ftp://ftp.linux.kiev.ua/pub/Linux/Calculate/${PN}/${PN}-${CL_PATCH}.tar.bz2"

if [[ -n $LONGTERM ]];then 
	if [[ $KERNEL_URI =~ ^(.*)(kernel/v3.0/patch)(.*)$ ]];then
		KERNEL_URI="${BASH_REMATCH[1]}kernel/v3.0/longterm/v${CKV}/patch${BASH_REMATCH[3]}"
	fi
fi

calculate-kernel-3_pkg_setup() {
	kernel-2_pkg_setup
	ewarn "!!! WARNING !!!  WARNING !!!  WARNING !!!  WARNING !!!"
	ewarn "After the kernel assemble perform command to update modules:"
	ewarn "  module-rebuild -X rebuild"
	ebeep 5
}

calculate-kernel-3_src_unpack() {
	kernel-2_src_unpack
}

vmlinuz_src_compile() {
	# disable sandbox
	export SANDBOX_ON=0
	export LDFLAGS=""
	local GENTOOARCH="${ARCH}"
	unset ARCH

	cd ${S}
	DEFAULT_KERNEL_SOURCE="${S}" CMD_KERNEL_DIR="${S}" cl-kernel \
		--ebuild \
		${CL_KERNEL_OPTS} \
		--kerneldir=${S} \
		--set cl_kernel_cache_path=${WORKDIR}/cache \
		--set cl_kernel_temp_path=${S}/temp \
		--set cl_kernel_install_path=${WORKDIR} \
		--mrproper || die "kernel build failed"
	
	make distclean &>/dev/null || die "cannot perform distclean"
	ARCH="${GENTOOARCH}"

	rm ${WORKDIR}/lib/modules/${KV_FULL}/build
	rm ${WORKDIR}/lib/modules/${KV_FULL}/source
}

calculate-kernel-3_src_compile() {
	use vmlinuz && vmlinuz_src_compile
}

vmlinuz_src_install() {
	cd ${WORKDIR}/lib
	insinto /lib
	doins -r modules
	insinto /usr/share/${PN}/${PV}
	doins -r firmware
	cd ${WORKDIR}
	doins -r boot
	
	dosym /usr/src/linux-${KV_FULL} \
		"/lib/modules/${KV_FULL}/source" ||
		die "cannot install source symlink"
	dosym /usr/src/linux-${KV_FULL} \
		"/lib/modules/${KV_FULL}/build" || 
		die "cannot install build symlink"
	insinto /etc/modprobe.d
}

calculate-kernel-3_src_install() {
	kernel-2_src_install
	dodir /usr/share/${PN}/${PV}/boot
	use vmlinuz && vmlinuz_src_install
	if ! use vmlinuz
	then
		local configname=$(cl-kernel -v --filter cl_kernel_config | \
		sed -nr 's/.*\[.\]\s//p')
		[[ -n $configname ]] &&
			cp $configname ${D}/usr/share/${PN}/${PV}/boot/config-${KV_FULL}
	fi
}

vmlinuz_pkg_postinst() {
	cp -p /usr/share/${PN}/${PV}/boot/* ${ROOT}/boot/
	cl-kernel --ebuild \
		-k /usr/src/linux-${KV_FULL} \
		--set cl_kernel_install_path=${ROOT}/

	mkdir -p ${ROOT}/lib/firmware
	cp -a ${ROOT}/usr/share/${PN}/${PV}/firmware/* ${ROOT}/lib/firmware/
	calculate_update_depmod
	calculate_update_modules

	[[ -f $MODULESDBFILE ]] &&
		sed -ri 's/a:1:sys-fs\/aufs2/a:0:sys-fs\/aufs2/' $MODULESDBFILE
}

calculate-kernel-3_pkg_postinst() {
	kernel-2_pkg_postinst

	KV_OUT_DIR=${ROOT}/usr/src/linux-${KV_FULL}
	if ls /usr/share/${PN}/${PV}/boot/ | grep -q System.map
	then
		cp -p /usr/share/${PN}/${PV}/boot/System.map* ${KV_OUT_DIR}/System.map
	fi
	cp -p /usr/share/${PN}/${PV}/boot/config* ${KV_OUT_DIR}/.config
	cd ${KV_OUT_DIR}
	local GENTOOARCH="${ARCH}"
	unset ARCH
	ebegin "kernel: >> Running oldconfig..."
	make oldconfig </dev/null &>/dev/null
	eend $? "Failed oldconfig"
	ebegin "kernel: >> Running modules_prepare..."
	make modules_prepare &>/dev/null
	eend $? "Failed modules prepare"
	ARCH="${GENTOOARCH}"

	use vmlinuz && vmlinuz_pkg_postinst
}
