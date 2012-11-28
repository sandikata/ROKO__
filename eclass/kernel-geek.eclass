# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

#
# Original Author: © 2011-2012 Andrey Ovcharov <sudormrfhalt@gmail.com>
# Purpose: Installing linux.
# Apply patches, build the kernel from source.
#
# Bugs to sudormrfhalt@gmail.com
#

EXPORT_FUNCTIONS ApplyPatch src_unpack src_prepare src_compile src_install pkg_postinst

# No need to run scanelf/strip on kernel sources/headers (bug #134453).
RESTRICT="mirror binchecks strip"

# Even though xz-utils are in @system, they must still be added to DEPEND; see
# http://archives.gentoo.org/gentoo-dev/msg_a0d4833eb314d1be5d5802a3b710e0a4.xml
DEPEND="${DEPEND} app-arch/xz-utils"

OLDIFS="$IFS"
VER="${PV}"
IFS='.'
set -- ${VER}
IFS="${OLDIFS}"

# the kernel version (e.g 3 for 3.4.2)
VERSION="${1}"
# the kernel patchlevel (e.g 4 for 3.4.2)
PATCHLEVEL="${2}"
# the kernel sublevel (e.g 2 for 3.4.2)
SUBLEVEL="${3}"
# the kernel major version (e.g 3.4 for 3.4.2)
KMV="${1}.${2}"

# ebuild default values setup settings
EXTRAVERSION="-calculate"
KV_FULL="${PVR}${EXTRAVERSION}"
S="${WORKDIR}"/linux-"${KV_FULL}"
SLOT="${PV}"

KNOWN_FEATURES="aufs bfq bld branding build ck debian deblob fedora genpatches grsecurity ice imq mageia pardus pld reiser4 rt suse symlink uksm vserver zfs"

SRC_URI="http://www.kernel.org/pub/linux/kernel/v3.0/linux-${KMV}.tar.xz"

if  [ "${SUBLEVEL}" != "0" ]; then
	SRC_URI="${SRC_URI} http://www.kernel.org/pub/linux/kernel/v3.0/patch-${PV}.xz"
fi

featureKnown() {
	local feature="${1/-/}"
	feature="${feature/+/}"
	[ "${feature}" == "" ] && die "Feature not defined!"

	expr index "${SUPPORTED_FEATURES}" "${feature}" >/dev/null || die "${feature} is not supported in current kernel"
	expr index "${KNOWN_FEATURES}" "${feature}" >/dev/null || die "${feature} is not known"
	IUSE="${IUSE} ${feature}"
	case ${feature} in
		aufs)	aufs_url="http://aufs.sourceforge.net/"
			HOMEPAGE="${HOMEPAGE} ${aufs_url}"
			;;
		bfq)	if [ "${OVERRIDE_bfq_src}" != "" ]; then
				bfq_src="${OVERRIDE_bfq_src}"
			fi
			bfq_url="http://algo.ing.unimo.it/people/paolo/disk_sched/"
			HOMEPAGE="${HOMEPAGE} ${bfq_url}"
			;;
		bld)	bld_src="http://bld.googlecode.com/files/bld-${bld_ver/KMV/$KMV}.tar.bz2"
			if [ "${OVERRIDE_bld_src}" != "" ]; then
				bld_src="${OVERRIDE_bld_src}"
			fi
			bld_url="http://code.google.com/p/bld"
			HOMEPAGE="${HOMEPAGE} ${bld_url}"
			SRC_URI="${SRC_URI}
				bld?		( ${bld_src} )"
			;;
		ck)	ck_src="http://ck.kolivas.org/patches/3.0/${KMV}/${ck_ver/KMV/$KMV}/patch-${ck_ver/KMV/$KMV}.bz2"
			if [ "${OVERRIDE_ck_src}" != "" ]; then
				ck_src="${OVERRIDE_ck_src}"
			fi
			ck_url="http://users.on.net/~ckolivas/kernel"
			HOMEPAGE="${HOMEPAGE} ${ck_url}"
			SRC_URI="${SRC_URI}
				ck?		( ${ck_src} )"
			;;
		debian) debian_url="http://anonscm.debian.org/viewvc/kernel/dists/trunk/linux/debian/patches";
			HOMEPAGE="${HOMEPAGE} ${debian_url}"
			;;
		deblob) deblob_src="http://linux-libre.fsfla.org/pub/linux-libre/releases/LATEST-${KMV}.N/deblob-${KMV} http://linux-libre.fsfla.org/pub/linux-libre/releases/LATEST-${KMV}.N/deblob-check"
			if [ "${OVERRIDE_deblob_src}" != "" ]; then
				deblob_src="${OVERRIDE_deblob_src}"
			fi
			deblob_url="http://linux-libre.fsfla.org/pub/linux-libre/"
			HOMEPAGE="${HOMEPAGE} ${deblob_url}"
			SRC_URI="${SRC_URI}
				deblob?		( ${deblob_src} )"
			;;
		fedora) fedora_url="http://pkgs.fedoraproject.org/gitweb/?p=kernel.git;a=summary";
			HOMEPAGE="${HOMEPAGE} ${fedora_url}"
			;;
		genpatches) genpatches_url="http://dev.gentoo.org/~mpagano/genpatches";
			HOMEPAGE="${HOMEPAGE} ${genpatches_url}"
			;;
		grsecurity) grsecurity_url="http://grsecurity.net http://www.gentoo.org/proj/en/hardened"
			HOMEPAGE="${HOMEPAGE} ${grsecurity_url}"
			RDEPEND="${RDEPEND}
				grsecurity?	( >=sys-apps/gradm-2.2.2 )"
			;;
		ice)	ice_url="http://tuxonice.net"
			HOMEPAGE="${HOMEPAGE} ${ice_url}"
			RDEPEND="${RDEPEND}
				ice?	( >=sys-apps/tuxonice-userui-1.0
						( || ( >=sys-power/hibernate-script-2.0 sys-power/pm-utils ) ) )"
			;;
		imq)	imq_src="http://www.linuximq.net/patches/patch-imqmq-${imq_ver/KMV/$KMV}.diff.xz"
			if [ "${OVERRIDE_imq_src}" != "" ]; then
				imq_src="${OVERRIDE_imq_src}"
			fi
			imq_url="http://www.linuximq.net"
			HOMEPAGE="${HOMEPAGE} ${imq_url}"
			SRC_URI="${SRC_URI}
				imq?		( ${imq_src} )"
			;;
		mageia) mageia_url="http://svnweb.mageia.org/packages/cauldron/kernel/current"
			HOMEPAGE="${HOMEPAGE} ${mageia_url}"
			;;
		pardus) pardus_url="https://svn.pardus.org.tr/pardus/playground/kaan.aksit/2011/kernel/default/kernel"
			HOMEPAGE="${HOMEPAGE} ${pardus_url}"
			;;
		pld)	pld_url="http://cvs.pld-linux.org/cgi-bin/viewvc.cgi/cvs/packages/kernel/?pathrev=MAIN"
			HOMEPAGE="${HOMEPAGE} ${pld_url}"
			;;
		reiser4) reiser4_src="mirror://sourceforge/project/reiser4/reiser4-for-linux-3.x/reiser4-for-${reiser4_ver/PV/$PV}.patch.gz"
			if [ "${OVERRIDE_reiser4_src}" != "" ]; then
				reiser4_src="${OVERRIDE_reiser4_src}"
			fi
			reiser4_url="http://sourceforge.net/projects/reiser4"
			HOMEPAGE="${HOMEPAGE} ${reiser4_url}"
			SRC_URI="${SRC_URI}
				reiser4?	( ${reiser4_src} )"
			;;
		rt)	rt_src="http://www.kernel.org/pub/linux/kernel/projects/rt/${KMV}/patch-${rt_ver/KMV/$KMV}.patch.xz"
			if [ "${OVERRIDE_rt_src}" != "" ]; then
				rt_src="${OVERRIDE_rt_src}"
			fi
			rt_url="http://www.kernel.org/pub/linux/kernel/projects/rt"
			HOMEPAGE="${HOMEPAGE} ${rt_url}"
			SRC_URI="${SRC_URI}
				rt?		( ${rt_src} )"
			;;
		suse)	suse_url="http://kernel.opensuse.org/cgit/kernel-source"
			HOMEPAGE="${HOMEPAGE} ${suse_url}"
			;;
		uksm)	uksm_url="http://kerneldedup.org"
			HOMEPAGE="${HOMEPAGE} ${uksm_url}"
			;;
		vserver) vserver_src="http://vserver.13thfloor.at/Experimental/patch-${vserver_ver}.diff"
			if [ "${OVERRIDE_vserver_src}" != "" ]; then
				vserver_src="${OVERRIDE_vserver_src}"
			fi
			vserver_url="http://linux-vserver.org"
			HOMEPAGE="${HOMEPAGE} ${vserver_url}"
			SRC_URI="${SRC_URI}
				vserver?	( ${vserver_src} )"
			;;
		zfs)	zfs_url="http://zfsonlinux.org"
			HOMEPAGE="${HOMEPAGE} ${zfs_url}"
			RDEPEND="${RDEPEND}
				zfs?	( sys-fs/zfs[kernel-builtin] )"
			;;
	esac
}

for I in ${SUPPORTED_FEATURES}; do
	featureKnown "${I}"
done

# default argument to patch
#patch_command='patch -p1 -F1 -s'
patch_command='patch -p1 -s'
ExtractApply() {
	local patch=$1
	shift
	case "$patch" in
	*.gz)  gunzip -dc    < "$patch" | $patch_command ${1+"$@"} ;;
	*.bz)  bunzip -dc    < "$patch" | $patch_command ${1+"$@"} ;;
	*.bz2) bunzip2 -dc   < "$patch" | $patch_command ${1+"$@"} ;;
	*.xz)  xz -dc        < "$patch" | $patch_command ${1+"$@"} ;;
	*.zip) unzip -d      < "$patch" | $patch_command ${1+"$@"} ;;
	*.Z)   uncompress -c < "$patch" | $patch_command ${1+"$@"} ;;
	*) $patch_command ${1+"$@"} < "$patch" ;;
	esac
}

# check the availability of a patch on the path passed
# check that the patch was not an empty
# test run patch with 'patch -p1 --dry-run'
# All tests completed successfully? run ExtractApply
Handler() {
	local patch=$1
	shift
	if [ ! -f "$patch" ]; then
		ewarn "Patch $patch does not exist."
		#exit 1 # why exit ?
	fi
	# don't apply patch if it's empty
	local C=$(wc -l "$patch" | awk '{print $1}')
	if [ "$C" -gt 9 ]; then
		# test argument to patch
		patch_command='patch -p1 --dry-run'
		if ExtractApply "$patch" &>/dev/null; then
			# default argument to patch
			#patch_command='patch -p1 -F1 -s'
			patch_command='patch -p1 -s'
			ExtractApply "$patch" &>/dev/null
		else
			patch_base_name=$(basename "$patch")
			ewarn "Skipping patch --> $patch_base_name"
		fi
	else
		patch_base_name=$(basename "$patch")
		ewarn "Skipping empty patch --> $patch_base_name"
	fi
}

# main function
kernel-geek_ApplyPatch() {
	local patch=$1
	local msg=$2
	shift
	echo
	einfo "${msg}"
	patch_base_name=$(basename "$patch")
	patch_dir_name=$(dirname "$patch")
	case $patch_base_name in
	patch_list) # list of patches
		while read -r line
		do
			# skip empty lines
			[[ -z "$line" ]] && continue
			# skip comments
			[[ $line =~ ^\ {0,}# ]] && continue
			ebegin "Applying $line"
				Handler "$patch_dir_name/$line";
			eend $?
		done < "$patch"
	;;
	*) # else is patch
		ebegin "Applying $patch_base_name"
			Handler "$patch";
		eend $?
	;;
	esac
}

kernel-geek_src_unpack() {
	if [ "${A}" != "" ]; then
		ebegin "Extract the sources"
			tar xvJf "${DISTDIR}/linux-${KMV}.tar.xz" &>/dev/null
		eend $?
		cd "${WORKDIR}"
		mv "linux-${KMV}" "${S}"
	fi
	cd "${S}"
	if  [ "${SUBLEVEL}" != "0" ]; then
		ApplyPatch "${DISTDIR}/patch-${PV}.xz" "Update to latest upstream ..."
	fi
	if [[ $DEBLOB_AVAILABLE == 1 ]] && use deblob ; then
		cp "${DISTDIR}/deblob-${KMV}" "${T}" || die "cp deblob-${KMV} failed"
		cp "${DISTDIR}/deblob-check" "${T}/deblob-check" || die "cp deblob-check failed"
		chmod +x "${T}/deblob-${KMV}" "${T}/deblob-check" || die "chmod deblob scripts failed"
	fi
}

# @FUNCTION: in_iuse
# @USAGE: <flag>
# @DESCRIPTION:
# Determines whether the given flag is in IUSE. Strips IUSE default prefixes
# as necessary.
#
# Note that this function should not be used in the global scope.
in_iuse() {
	debug-print-function ${FUNCNAME} "${@}"
	[[ ${#} -eq 1 ]] || die "Invalid args to ${FUNCNAME}()"

	local flag=${1}
	local liuse=( ${IUSE} )

	has "${flag}" "${liuse[@]#[+-]}"
}

# @FUNCTION: use_if_iuse
# @USAGE: <flag>
# @DESCRIPTION:
# Return true if the given flag is in USE and IUSE.
#
# Note that this function should not be used in the global scope.
use_if_iuse() {
	in_iuse $1 || return 1
	use $1
}

kernel-geek_src_prepare() {

### BRANCH APPLY ###

	config_file="/etc/portage/kernel.conf"
	if [ -e "$config_file" ]
	then
		source "$config_file"
		ewarn "GEEKSOURCES_PATCHING_ORDER=\"${GEEKSOURCES_PATCHING_ORDER}\""
	else
		GEEKSOURCES_PATCHING_ORDER="vserver bfq ck genpatches grsecurity ice imq reiser4 rt bld uksm aufs mageia fedora suse debian pardus pld zfs branding";
		ewarn "The order of patching is defined in file $config_file with the variable GEEKSOURCES_PATCHING_ORDER is its default value:
GEEKSOURCES_PATCHING_ORDER=\"${GEEKSOURCES_PATCHING_ORDER}\"
You are free to choose any order of patching.
For example, if you like the alphabetical order of patching you must set the variable:
echo 'GEEKSOURCES_PATCHING_ORDER=\"aufs bfq bld branding ck fedora genpatches grsecurity ice imq mageia pardus pld reiser4 rt suse uksm vserver zfs\"' > $config_file
Otherwise i will use the default value of GEEKSOURCES_PATCHING_ORDER!
And may the Force be with you…"
	fi

for Current_Patch in $GEEKSOURCES_PATCHING_ORDER; do
	if use_if_iuse "$Current_Patch"; then

		if [ -e "$FILESDIR/${PV}/$Current_Patch/info" ] ; then
			echo
			cat "$FILESDIR/${PV}/$Current_Patch/info";
		fi

		case ${Current_Patch} in
			aufs)	ApplyPatch "$FILESDIR/${PV}/$Current_Patch/patch_list" "aufs3 - ${aufs_url}";
				;;
			bfq)	ApplyPatch "${FILESDIR}/${PV}/$Current_Patch/patch_list" "Budget Fair Queueing Budget I/O Scheduler - ${bfq_url}";
				;;
			bld)	echo;
				cd "${T}";
				unpack "bld-${bld_ver/KMV/$KMV}.tar.bz2";
				cp "${T}/bld-${bld_ver/KMV/$KMV}/BLD-${KMV}.patch" "${S}/BLD-${KMV}.patch";
				cd "${S}";
				ApplyPatch "BLD-${KMV}.patch" "Alternate CPU load distribution technique for Linux kernel scheduler - ${bld_url}";
				rm -f "BLD-${KMV}.patch";
				rm -r "${T}/bld-${bld_ver/KMV/$KMV}"; # Clean temp
				;;
			branding) ApplyPatch "${FILESDIR}/font-8x16-iso-latin-1-v2.patch" "font - CONFIG_FONT_ISO_LATIN_1_8x16 http://sudormrf.wordpress.com/2010/10/23/ka-ping-yee-iso-latin-1%c2%a0font-in-linux-kernel/";
				ApplyPatch "${FILESDIR}/gentoo-larry-logo-v2.patch" "logo - CONFIG_LOGO_LARRY_CLUT224 https://github.com/init6/init_6/raw/master/sys-kernel/geek-sources/files/larry.png";
				ApplyPatch "${FILESDIR}/linux-3.6.6-colored-printk.patch" "Colored printk"
				;;
			ck)	ApplyPatch "$DISTDIR/patch-${ck_ver}.bz2" "Con Kolivas high performance patchset - ${ck_url}";
				;;
			debian)	ApplyPatch "${FILESDIR}/${PV}/$Current_Patch/patch_list" "Debian - ${debian_url}";
				#use rt && ApplyPatch "${FILESDIR}/${PV}/$Current_Patch/patch_list_rt" "Debian rt - ${debian_url}";
				;;
			fedora)	ApplyPatch "${FILESDIR}/${PV}/$Current_Patch/patch_list" "Fedora - ${fedora_url}";
				;;
			genpatches) ApplyPatch "${FILESDIR}/${PV}/$Current_Patch/patch_list" "Gentoo patches - ${genpatches_url}";
				;;
			grsecurity) ApplyPatch "${FILESDIR}/${PV}/$Current_Patch/patch_list" "GrSecurity patches - ${grsecurity_url}";
				;;
			ice)	ApplyPatch "${FILESDIR}/${PV}/$Current_Patch/patch_list" "TuxOnIce - ${ice_url}";
				;;
			imq)	ApplyPatch "${DISTDIR}/patch-imqmq-${imq_ver}.diff.xz" "Intermediate Queueing Device patches - ${imq_url}";
				;;
			mageia)	ApplyPatch "${FILESDIR}/${PV}/$Current_Patch/patch_list" "Mandriva/Mageia - ${mageia_url}";
				;;
			pardus) ApplyPatch "${FILESDIR}/${PV}/$Current_Patch/patch_list" "Pardus - ${pardus_url}";
				;;
			pld)	ApplyPatch "${FILESDIR}/${PV}/$Current_Patch/patch_list" "PLD - ${pld_url}";
				;;
			reiser4) ApplyPatch "${DISTDIR}/reiser4-for-${reiser4_ver}.patch.gz" "Reiser4 - ${reiser4_url}";
				;;
			rt)	ApplyPatch "${DISTDIR}/patch-${rt_ver}.patch.xz" "Ingo Molnar's realtime preempt patches - ${rt_url}";
					if [ -e "${FILESDIR}/${PV}/$Current_Patch/patch_list" ]
						then ApplyPatch "${FILESDIR}/${PV}/$Current_Patch/patch_list" "Debian rt - ${debian_url}";
					fi
				;;
			suse)	ApplyPatch "${FILESDIR}/${PV}/$Current_Patch/patch_list" "OpenSuSE - ${suse_url}";
				;;
			uksm)	ApplyPatch "${FILESDIR}/${PV}/$Current_Patch/patch_list" "Ultra Kernel Samepage Merging - ${uksm_url}";
				;;
			vserver) ApplyPatch "${DISTDIR}/patch-${vserver_ver}.diff" "VServer - ${vserver_url}";
				;;
			zfs)	ApplyPatch "${FILESDIR}/${PV}/$Current_Patch/patch_list" "zfs - ${zfs_url}";
				;;
		esac
	else continue
	fi;
done;

	# Fixes
	ApplyPatch "${FILESDIR}/fixes/acpi-ec-add-delay-before-write.patch" "Oops: ACPI: EC: input buffer is not empty, aborting transaction - 2.6.32 regression https://bugzilla.kernel.org/show_bug.cgi?id=14733#c41";
	# fix for 3.5 kernel
	((${PATCHLEVEL} < 6)) && ApplyPatch "${FILESDIR}/fixes/lpc_ich_3.5.1.patch" "Oops: lpc_ich: Resource conflict(s) found affecting iTCO_wdt https://bugzilla.kernel.org/show_bug.cgi?id=44991";
	# CK fixes for 3.6
	use ck && if [ ${PATCHLEVEL} = 6 ]; then ApplyPatch "${FILESDIR}/fixes/Fix boot issue with BFS and linux-3.6.patch" "http://ck.kolivas.org/patches/bfs/3.0/3.6/Fix boot issue with BFS and linux-3.6.patch"; fi;
	# fixes for 3.6 kernel
	((${PATCHLEVEL} < 7)) && ApplyPatch "${FILESDIR}/fixes/zram_pagealloc_fix.patch" "zram pagealloc fix http://code.google.com/p/compcache/issues/detail?id=102";
	((${PATCHLEVEL} < 7)) && ApplyPatch "${FILESDIR}/fixes/gpio-ich_share_ownership_of_GPIO_groups_3.6.patch" "gpio-ich: Share ownership of GPIO groups http://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git;a=patch;h=4f600ada70beeb1dfe08e11e871bf31015aa0a3d";
	# fix module initialisation https://bugs.archlinux.org/task/32122
	((${PATCHLEVEL} < 7)) && ApplyPatch "${FILESDIR}/fixes/module-symbol-waiting-3.6.patch" "Fix module initialisation https://bugs.archlinux.org/task/32122";
	((${PATCHLEVEL} < 7)) && ApplyPatch "${FILESDIR}/fixes/module-init-wait-3.6.patch" "Fix module initialisation https://bugs.archlinux.org/task/32122";
	# add gcc 4.7 support for Kconfig and menuconfig
	ApplyPatch "${FILESDIR}/fixes/kernel-33-gcc47-0.patch" "Fix for kernel-3* and gcc47"
	# zfs
	use zfs && ((${PATCHLEVEL} < 7)) && ApplyPatch "${FILESDIR}/fixes/zfs_gpl_blk_queue_flush.patch" "Fix FATAL: modpost: GPL-incompatible module zfs.ko uses GPL-only symbol 'blk_queue_flush'"

### END OF PATCH APPLICATIONS ###

	echo
	einfo "Live long and prosper."
	echo

	einfo "Set extraversion in Makefile" # manually set extraversion
	sed -i -e "s:^\(EXTRAVERSION =\).*:\1 ${EXTRAVERSION}:" Makefile

	# Comment out EXTRAVERSION added by CK patch:
	use ck && sed -i -e 's/\(^EXTRAVERSION :=.*$\)/# \1/' "Makefile"

	einfo "Copy current config from /proc"
#	if [ -f /proc/config.gz ] && [ ! -f "/usr/src/linux-${KV_FULL}/.config" ]; then
#		zcat /proc/config > "/usr/src/linux-${KV_FULL}/.config" || ewarn "Can't copy /proc/config"
#	fi
	if [ -e "/usr/src/linux-${KV_FULL}/.config" ]; then
		ewarn "Kernel config file already exist."
		ewarn "I will NOT overwrite that."
		cp "/usr/src/linux-${KV_FULL}/.config" "${WORKDIR}/linux-${KV_FULL}/.config"
	else
		zcat /proc/config > .config || ewarn "Can't copy /proc/config"
	fi

	einfo "Cleanup backups after patching"
	find '(' -name '*~' -o -name '*.orig' -o -name '.*.orig' -o -name '.gitignore'  -o -name '.*.old' ')' -print0 | xargs -0 -r -l512 rm -f

#	make oldconfig && make prepare
	einfo "Compile gen_init_cpio"
	make -C "${WORKDIR}"/linux-"${KV_FULL}"/usr/ gen_init_cpio
	chmod +x "${WORKDIR}"/linux-"${KV_FULL}"/usr/gen_init_cpio "${WORKDIR}"/linux-"${KV_FULL}"/scripts/gen_initramfs_list.sh

	cd "${WORKDIR}"/linux-"${KV_FULL}"
	local GENTOOARCH="${ARCH}"
	unset ARCH
	ebegin "kernel: >> Running oldconfig..."
	make oldconfig </dev/null &>/dev/null
	eend $? "Failed oldconfig"
	ebegin "kernel: >> Running modules_prepare..."
	make modules_prepare &>/dev/null
	eend $? "Failed modules prepare"
	ARCH="${GENTOOARCH}"
}

kernel-geek_src_compile() {
	if [[ $DEBLOB_AVAILABLE == 1 ]] && use deblob ; then
		echo ">>> Running deblob script ..."
		sh "${T}/deblob-${KMV}" --force || \
			die "Deblob script failed to run!!!"
	fi
}

kernel-geek_src_install() {
	# disable sandbox
	export SANDBOX_ON=0
	local version_h_name="usr/src/linux-${KV_FULL}/include/linux"
	local version_h="${ROOT}${version_h_name}"

	if [ -f "${version_h}" ]; then
		einfo "Discarding previously installed version.h to avoid collisions"
		addwrite "/${version_h_name}"
		rm -f "${version_h}"
	fi

	cd "${S}"
	dodir /usr/src
	echo ">>> Copying sources ..."

	mv ${WORKDIR}/linux* "${D}"/usr/src;

	if use symlink ; then
		if [ -h "/usr/src/linux" ]; then
			unlink "/usr/src/linux"
		elif [ -d "/usr/src/linux" ]; then
			mv "/usr/src/linux" "/usr/src/linux-old"
		fi
		dosym linux-${KV_FULL} \
			"/usr/src/linux" ||
			die "cannot install kernel symlink"
	fi
#	dosym /usr/src/linux-${KV_FULL} \
#		"/lib/modules/${KV_FULL}/source" ||
#		die "cannot install source symlink"
#	dosym /usr/src/linux-${KV_FULL} \
#		"/lib/modules/${KV_FULL}/build" ||
#		die "cannot install build symlink"

	if use build ; then
		# Find out some info..
		eval $(head -n 4 Makefile | sed -e 's/ //g')
		local ARCH=$(uname -m | sed -e s/i.86/i386/g)
		local FULLVER=${VERSION}.${PATCHLEVEL}.${SUBLEVEL}${EXTRAVERSION}
		local MODULESUPPORT=$(grep "CONFIG_MODULES=y" .config 2>/dev/null)

		if [[ -e .config && -e arch/${ARCH}/boot/bzImage ]]; then
			ISNEWER=$(find .config -newer arch/${ARCH}/boot/bzImage 2>/dev/null)
		else
			if ! [[ -e .config ]]; then
				ISNEWER="noconfig"
			else
				ISNEWER="yes"
			fi
		fi

		if [[ -e .version ]]; then
			BUILDNO=$(cat .version)
		else
			BUILDNO="0"
		fi

		ebegin "Beginning installation procedure for \"${FULLVER}\""
			if [[ ${ISNEWER} == "noconfig" ]]; then
				ebegin " No kernel config found, searching for best availiable config"
					if [[ -e /proc/config.gz ]]; then
						einfo "  Foung config from running kernel, updating to match target kernel"
							zcat /proc/config.gz > .config
							true | make oldconfig 2>/dev/null
					else
						einfo "  No suitable custom config found, defaulting to defconfig"
							cp arch/${ARCH}/defconfig .config
					fi
				eend $?
			fi

			if [[ ${ISNEWER} != "" ]]; then
				ebegin " Kernel build not uptodate, compiling"
					make bzImage 2>/dev/null
					if [[ ${MODULESUPPORT} != "" ]]; then
						einfo "  Module support in kernel detected, building modules"
							make modules 2>/dev/null
					fi
				eend $?
				BUILDNO=$(cat .version)
			fi

			ebegin " Merging kernel to system (Buildnumber: ${BUILDNO})"
				if [[ $(cat /proc/mounts | grep /boot) == "" && $(cat /etc/fstab | grep /boot) != "" ]]; then
					ebegin "  Boot partition unmounted, mounting"
						mount /boot
					eend $?
				fi
				einfo "  Copying bzImage to \"/boot/vmlinuz-${FULLVER}-${BUILDNO}\""
					cp arch/${ARCH}/boot/bzImage /boot/vmlinuz-${FULLVER}-${BUILDNO}
				einfo "  Copying System.map to \"/boot/System.map-${FULLVER}\""
					cp System.map /boot/System.map-${FULLVER}
				einfo "  Copying .config to \"/boot/config-${FULLVER}\""
					cp .config /boot/config-${FULLVER}
				if [[ ${MODULESUPPORT} != "" ]]; then
					einfo "  Installing modules to \"/lib/modules/${FULLVER}/\""
						make modules_install 2>/dev/null
				fi
				ebegin " Editing kernel entry in GRUB"
					if [[ -e "/etc/grub.d/10_linux" ]]; then
						grub2-mkconfig -o /boot/grub2/grub.cfg;
					fi;
					if [[ -e "/etc/boot.conf" ]]; then
						boot-update;
					fi;
				eend $?
			eend $?

			if [[ -e /var/lib/module-rebuild/moduledb && $(cat /var/lib/module-rebuild/moduledb | wc -l) -ge 1 ]]; then
				ebegin " Looking for external kernel modules that need rebuilding"
					for EXTKERNMOD in $(sed -e 's/.:.://g' /var/lib/module-rebuild/moduledb); do
						if [[ $(find /boot/vmlinuz-${FULLVER}-${BUILDNO} -newer /var/db/pkg/${EXTKERNMOD}/environment.bz2 2>/dev/null) != "" ]]; then
							ebegin "  Recompiling outdated module \"${EXTKERNMOD}\""
								emerge --oneshot =${EXTKERNMOD} 2>/dev/null
							eend $?
						fi
					done
				eend $?
			fi
		eend $?
	fi
}

kernel-geek_pkg_postinst() {
	einfo " If you are upgrading from a previous kernel, you may be interested "
	einfo " in the following document:"
	einfo "   - General upgrade guide: http://www.gentoo.org/doc/en/kernel-upgrade.xml"
	einfo " geek-sources is UNSUPPORTED by Funtoo or Gentoo Security."
	einfo " This means that it is likely to be vulnerable to recent security issues."
	einfo " For specific information on why this kernel is unsupported, please read:"
	einfo " http://www.gentoo.org/proj/en/security/kernel.xml"
	echo
	einfo " Now is the time to configure and build the kernel."
	use uksm && einfo " Do not forget to disable the remote bug reporting feature by echo 0 > /sys/kernel/mm/uksm/usr_spt_enabled
	more http://kerneldedup.org/en/projects/uksm/uksmdoc/usage/"
}
