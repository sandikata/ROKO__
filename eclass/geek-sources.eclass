# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

#
#  Copyright © 2011-2013 Andrey Ovcharov <sudormrfhalt@gmail.com>
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#  The latest version of this software can be obtained here:
#
#  https://github.com/init6/init_6/blob/master/eclass/geek-sources.eclass
#
#  Wiki: https://github.com/init6/init_6/wiki/geek-sources.eclass
#

# Logical part
# Purpose: Installing geek-sources
# Uses: linux-geek.eclass
#
# Bugs to sudormrfhalt@gmail.com
#

inherit linux-geek

EXPORT_FUNCTIONS src_unpack src_prepare src_compile src_install pkg_postinst

KNOWN_USES="aufs bfq bld branding build ck debian deblob fedora genpatches grsecurity ice imq lqx mageia pardus pax pf phc pld reiser4 rifs rt rtai scst suse symlink uksm vserver xenomai zen zfs";

# internal function
#
# @FUNCTION: USEKnown
# @USAGE:
# @DESCRIPTION:
USEKnown() {
	local USE=$1
	[ "${USE}" == "" ] && die "Feature not defined!"

	expr index "${SUPPORTED_USES}" "${USE}" >/dev/null || die "${USE} is not supported in current kernel"
	expr index "${KNOWN_USES}" "${USE}" >/dev/null || die "${USE} is not known"
	IUSE="${IUSE} ${USE}"
	case ${USE} in
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
		ck)	ck_src="http://ck.kolivas.org/patches/3.0/${KMV}/${ck_ver/KMV/$KMV}/patch-${ck_ver/KMV/$KMV}.lrz"
#			if [ "${VERSION}" -eq "3" -o "${PATCHLEVEL}" -eq "8" ]; then
#				ck_src="http://ck.kolivas.org/patches/3.0/${KMV}/patch-${ck_ver/KMV/$KMV}.lrz"
#			fi
			if [ "${OVERRIDE_ck_src}" != "" ]; then
				ck_src="${OVERRIDE_ck_src}"
			fi
			ck_url="http://users.on.net/~ckolivas/kernel"
			HOMEPAGE="${HOMEPAGE} ${ck_url}"
			DEPEND="${DEPEND} >=app-arch/lrzip-0.614"
			SRC_URI="${SRC_URI}
				ck?		( ${ck_src} )"
			;;
		debian) debian_url="http://anonscm.debian.org/viewvc/kernel/dists/trunk/linux/debian/patches";
			HOMEPAGE="${HOMEPAGE} ${debian_url}"
			;;
		fedora) fedora_url="http://pkgs.fedoraproject.org/gitweb/?p=kernel.git;a=summary";
			HOMEPAGE="${HOMEPAGE} ${fedora_url}"
			;;
		genpatches) genpatches_url="http://dev.gentoo.org/~mpagano/genpatches";
			HOMEPAGE="${HOMEPAGE} ${genpatches_url}"
			;;
		grsecurity) grsecurity_url="http://grsecurity.net"
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
		lqx)	lqx_src="http://liquorix.net/sources/${lqx_ver/KMV/$KMV}.patch.gz"
			if [ "${OVERRIDE_lqx_src}" != "" ]; then
				lqx_src="${OVERRIDE_lqx_src}"
			fi
			lqx_url="http://liquorix.net"
			HOMEPAGE="${HOMEPAGE} ${lqx_url}"
			SRC_URI="${SRC_URI}
				lqx?			( ${lqx_src} )"
			;;
		mageia) mageia_url="http://svnweb.mageia.org/packages/cauldron/kernel/current"
			HOMEPAGE="${HOMEPAGE} ${mageia_url}"
			;;
		pardus) pardus_url="https://svn.pardus.org.tr/pardus/playground/kaan.aksit/2011/kernel/default/kernel"
			HOMEPAGE="${HOMEPAGE} ${pardus_url}"
			;;
		pax)	pax_src="http://grsecurity.net/test/pax-linux-${pax_ver/KMV/$KMV}.patch"
			if [ "${OVERRIDE_pax_src}" != "" ]; then
				pax_src="${OVERRIDE_pax_src}"
			fi
			pax_url="http://pax.grsecurity.net"
			HOMEPAGE="${HOMEPAGE} ${pax_url}"
			SRC_URI="${SRC_URI}
				pax?			( ${pax_src} )"
			;;
		pf)	pf_src="http://pf.natalenko.name/sources/${KMV}/patch-${pf_ver/KMV/$KMV}.bz2"
			if [ "${OVERRIDE_pf_src}" != "" ]; then
				pf_src="${OVERRIDE_pf_src}"
			fi
			pf_url="http://pf.natalenko.name"
			HOMEPAGE="${HOMEPAGE} ${pf_url}"
			SRC_URI="${SRC_URI}
				pf?			( ${pf_src} )"
			;;
		phc)	phc_url="http://www.linux-phc.org"
			HOMEPAGE="${HOMEPAGE} ${phc_url}"
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
		rifs)	rifs_url="http://code.google.com/p/rifs-scheduler"
			HOMEPAGE="${HOMEPAGE} ${rifs_url}"
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
		rtai)	rtai_url="https://www.rtai.org"
			HOMEPAGE="${HOMEPAGE} ${rtai_url}"
			;;
		scst)	scs_url="http://scst.sourceforge.net"
			HOMEPAGE="${HOMEPAGE} ${scst_url}"
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
		xenomai) xenomai_src="http://download.gna.org/adeos/patches/v3.x/x86/ipipe-core-${xenomai_ver/KMV/$KMV}-x86-3.patch"
			xenomai_url="http://www.xenomai.org"
			HOMEPAGE="${HOMEPAGE} ${xenomai_url}"
			SRC_URI="${SRC_URI}
				xenomai?	( ${xenomai_src} )"
			;;
		zen)	zen_url="https://github.com/damentz/zen-kernel"
			HOMEPAGE="${HOMEPAGE} ${zen_url}"
			;;
		zfs)	zfs_url="http://zfsonlinux.org"
			HOMEPAGE="${HOMEPAGE} ${zfs_url}"
			LICENSE="${LICENSE} GPL-3"
			RDEPEND="${RDEPEND}
				zfs?	( sys-fs/zfs[kernel-builtin] )"
			;;
	esac
}

for I in ${SUPPORTED_USES}; do
	USEKnown "${I}"
done

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

# @FUNCTION: src_unpack
# @USAGE:
# @DESCRIPTION:
geek-sources_src_unpack() {

	local SKIP_KERNEL_PATCH_UPDATE="lqx pf";
	for Current_Patch in $SKIP_KERNEL_PATCH_UPDATE; do
		if use_if_iuse "${Current_Patch}" ; then
		case "${Current_Patch}" in
			*) SKIP_UPDATE="1";
				;;
		esac
		else continue
		fi;
	done;

	linux-geek_src_unpack
}


# @FUNCTION: src_prepare
# @USAGE:
# @DESCRIPTION:
geek-sources_src_prepare() {

### BRANCH APPLY ###

	local _PATCHDIR="/etc/portage/patches" # for user patch
	local config_file="/etc/portage/kernel.conf"
	local DEFAULT_GEEKSOURCES_PATCHING_ORDER="pax lqx pf phc scst vserver bfq ck genpatches grsecurity ice imq reiser4 rifs rt rtai xenomai bld uksm aufs mageia fedora suse debian pardus pld zfs branding fix zen upatch";
	local xUserOrder=""
	local xDefOder=""
	if [ -e "${config_file}" ] ; then
		source "${config_file}"
		xUserOrder="$(echo -n "$GEEKSOURCES_PATCHING_ORDER" | tr '\n' ' ' | tr -s ' ' | tr ' ' '\n' | sort | tr '\n' ' ' | sed -e 's,^\s*,,' -e 's,\s*$,,')"
		xDefOrder="$(echo -n "$DEFAULT_GEEKSOURCES_PATCHING_ORDER" | tr '\n' ' ' | tr -s ' ' | tr ' ' '\n' | sort | tr '\n' ' ' | sed -e 's,^\s*,,' -e 's,\s*$,,')"

		if [ "x${xUserOrder}" = "x${xDefOrder}" ] ; then
			ewarn "Use GEEKSOURCES_PATCHING_ORDER=\"${GEEKSOURCES_PATCHING_ORDER}\" from ${config_file}"
		else
			ewarn "Use GEEKSOURCES_PATCHING_ORDER=\"${GEEKSOURCES_PATCHING_ORDER}\" from ${config_file}"
			ewarn "Not all USE flag present in GEEKSOURCES_PATCHING_ORDER from ${config_file}"
			difference=$(echo "${xDefOrder} ${xUserOrder}" | awk '{for(i=1;i<=NF;i++){_a[$i]++}for(i in _a){if(_a[i]==1)print i}}' ORS=" ")
			ewarn "The following flags are missing: ${difference}"
			ewarn "Probably that's the plan. In that case, never mind."
		fi
	else
		GEEKSOURCES_PATCHING_ORDER="${DEFAULT_GEEKSOURCES_PATCHING_ORDER}";
		ewarn "The order of patching is defined in file ${config_file} with the variable GEEKSOURCES_PATCHING_ORDER is its default value:
GEEKSOURCES_PATCHING_ORDER=\"${GEEKSOURCES_PATCHING_ORDER}\"
You are free to choose any order of patching.
For example, if you like the alphabetical order of patching you must set the variable:
echo 'GEEKSOURCES_PATCHING_ORDER=\"aufs bfq bld branding build ck debian deblob fedora genpatches grsecurity ice imq lqx mageia pardus pax pf phc pld reiser4 rifs rt rtai scst suse symlink uksm vserver xenomai zen zfs\"' > ${config_file}
Otherwise i will use the default value of GEEKSOURCES_PATCHING_ORDER!
And may the Force be with you…"
	fi

for Current_Patch in $GEEKSOURCES_PATCHING_ORDER; do
	if use_if_iuse "${Current_Patch}" || [[ "${Current_Patch}" == "fix" ]] || [[ "${Current_Patch}" == "upatch" ]] ; then
		if [ -e "${FILESDIR}/${PV}/${Current_Patch}/info" ] ; then
			echo
			cat "${FILESDIR}/${PV}/${Current_Patch}/info";
		fi
		case "${Current_Patch}" in
			aufs)	ApplyPatch "${FILESDIR}/${PV}/${Current_Patch}/patch_list" "aufs3 - ${aufs_url}";
				;;
			bfq)	ApplyPatch "${FILESDIR}/${PV}/${Current_Patch}/patch_list" "Budget Fair Queueing Budget I/O Scheduler - ${bfq_url}";
				;;
			bld)	echo;
				cd "${T}";
				unpack "bld-${bld_ver/KMV/$KMV}.tar.bz2";
				cp "${T}/bld-${bld_ver/KMV/$KMV}/BLD-${bld_ver/KMV/$KMV}.patch" "${S}/BLD-${bld_ver/KMV/$KMV}.patch";
				cd "${S}";
				ApplyPatch "BLD-${bld_ver/KMV/$KMV}.patch" "Alternate CPU load distribution technique for Linux kernel scheduler - ${bld_url}";
				rm -f "BLD-${bld_ver/KMV/$KMV}.patch";
				rm -r "${T}/bld-${bld_ver/KMV/$KMV}"; # Clean temp
				;;
			branding) if [ -e "${FILESDIR}/${Current_Patch}/info" ] ; then
					echo
					cat "${FILESDIR}/${Current_Patch}/info";
				fi
				ApplyPatch "${FILESDIR}/${Current_Patch}/patch_list" "Branding";
				;;
			ck)	ApplyPatch "${DISTDIR}/patch-${ck_ver/KMV/$KMV}.lrz" "Con Kolivas high performance patchset - ${ck_url}";
				if [ -d "${FILESDIR}/${PV}/${Current_Patch}" ] ; then
					if [ -e "${FILESDIR}/${PV}/${Current_Patch}/patch_list" ] ; then
						ApplyPatch "${FILESDIR}/${PV}/${Current_Patch}/patch_list" "CK Fix";
					fi
				fi
				# Comment out EXTRAVERSION added by CK patch:
				sed -i -e 's/\(^EXTRAVERSION :=.*$\)/# \1/' "Makefile"
				;;
			debian) ApplyPatch "${FILESDIR}/${PV}/${Current_Patch}/patch_list" "Debian - ${debian_url}";
				;;
			fedora) ApplyPatch "${FILESDIR}/${PV}/${Current_Patch}/patch_list" "Fedora - ${fedora_url}";
				;;
			fix)	ApplyPatch "${FILESDIR}/${PV}/${Current_Patch}/patch_list" "Fixes for current kernel"
				;;
			genpatches) ApplyPatch "${FILESDIR}/${PV}/${Current_Patch}/patch_list" "Gentoo patches - ${genpatches_url}";
				;;
			grsecurity) ApplyPatch "${FILESDIR}/${PV}/${Current_Patch}/patch_list" "GrSecurity patches - ${grsecurity_url}";
				;;
			ice)	ApplyPatch "${FILESDIR}/${PV}/${Current_Patch}/patch_list" "TuxOnIce - ${ice_url}";
				;;
			imq)	ApplyPatch "${DISTDIR}/patch-imqmq-${imq_ver}.diff.xz" "Intermediate Queueing Device patches - ${imq_url}";
				;;
			lqx)	ApplyPatch "${DISTDIR}/${lqx_ver/KMV/$KMV}.patch.gz" "Liquorix patches - ${lqx_url}";
				;;
			mageia) ApplyPatch "${FILESDIR}/${PV}/${Current_Patch}/patch_list" "Mandriva/Mageia - ${mageia_url}";
				;;
			pardus) ApplyPatch "${FILESDIR}/${PV}/${Current_Patch}/patch_list" "Pardus - ${pardus_url}";
				;;
			pax)	ApplyPatch "${DISTDIR}/pax-linux-${pax_ver/KMV/$KMV}.patch" "PAX patches - ${pax_url}";
				;;
			pf)	ApplyPatch "${DISTDIR}/patch-${pf_ver/KMV/$KMV}.bz2" "pf-kernel patches - ${pf_url}";
				;;
			phc)	ApplyPatch "${FILESDIR}/${PV}/${Current_Patch}/patch_list" "Processor Hardware Control for the Linux Kernel - ${phc_url}";
				;;
			pld)	ApplyPatch "${FILESDIR}/${PV}/${Current_Patch}/patch_list" "PLD - ${pld_url}";
				;;
			reiser4) ApplyPatch "${DISTDIR}/reiser4-for-${reiser4_ver}.patch.gz" "Reiser4 - ${reiser4_url}";
				;;
			rifs)	ApplyPatch "${FILESDIR}/${PV}/${Current_Patch}/patch_list" "RIFS scheduler - ${rifs_url}";
				;;
			rt)	ApplyPatch "${DISTDIR}/patch-${rt_ver}.patch.xz" "Ingo Molnar's realtime preempt patches - ${rt_url}";
					if [ -e "${FILESDIR}/${PV}/$Current_Patch/patch_list" ]
						then ApplyPatch "${FILESDIR}/${PV}/$Current_Patch/patch_list" "Debian rt - ${debian_url}";
					fi
				;;
			rtai)	ApplyPatch "${FILESDIR}/${PV}/${Current_Patch}/patch_list" "RealTime Application Interface for Linux - ${rtai_url}";
				;;
			scst)	ApplyPatch "${FILESDIR}/${PV}/${Current_Patch}/patch_list" "Generic SCSI target (SCST) subsystem for Linux - ${scst_url}";
				;;
			suse)	ApplyPatch "${FILESDIR}/${PV}/${Current_Patch}/patch_list" "OpenSuSE - ${suse_url}";
				;;
			uksm)	ApplyPatch "${FILESDIR}/${PV}/${Current_Patch}/patch_list" "Ultra Kernel Samepage Merging - ${uksm_url}";
				;;
			upatch) if [ -d "${_PATCHDIR}/${CATEGORY}/${PN}" ] ; then
					if [ -e "${_PATCHDIR}/${CATEGORY}/${PN}/info" ] ; then
						echo
						cat "${_PATCHDIR}/${CATEGORY}/${PN}/info";
					fi
					if [ -e "${_PATCHDIR}/${CATEGORY}/${PN}/patch_list" ] ; then
						ApplyPatch "${_PATCHDIR}/${CATEGORY}/${PN}/patch_list" "Applying user patches"
					else
						ewarn "File ${_PATCHDIR}/${CATEGORY}/${PN}/patch_list not found!"
						ewarn "Try to apply the patches if they are there…"
						for i in `ls ${_PATCHDIR}/${CATEGORY}/${PN}/*.{patch,gz,bz,bz2,lrz,xz,zip,Z} 2> /dev/null`; do
							ApplyPatch "${i}" "Applying user patches"
						done
					fi
				fi
				;;
			vserver) ApplyPatch "${DISTDIR}/patch-${vserver_ver}.diff" "VServer - ${vserver_url}";
				;;
			xenomai) ApplyPatch "${DISTDIR}/ipipe-core-${xenomai_ver/KMV/$KMV}-x86-3.patch" "Xenomai - ${xenomai_url}";
				;;
			zen)	ApplyPatch "${FILESDIR}/${PV}/${Current_Patch}/patch_list" "zen-kernel - ${zen_url}";
				;;
			zfs)	if use_if_iuse "grsecurity" ; then
					[ -e "${FILESDIR}/${PV}/${Current_Patch}/grsecurity/info" ] && echo; cat "${FILESDIR}/${PV}/${Current_Patch}/grsecurity/info";
					[ -e "${FILESDIR}/${PV}/${Current_Patch}/grsecurity/patch_list" ] && ApplyPatch "${FILESDIR}/${PV}/${Current_Patch}/grsecurity/patch_list" "zfs for grsecurity - ${zfs_url}";
				else
					[ -e "${FILESDIR}/${PV}/${Current_Patch}/vanilla/info" ] && cat "${FILESDIR}/${PV}/${Current_Patch}/vanilla/info";
					[ -e "${FILESDIR}/${PV}/${Current_Patch}/vanilla/patch_list" ] && ApplyPatch "${FILESDIR}/${PV}/${Current_Patch}/vanilla/patch_list" "zfs for vanilla - ${zfs_url}";
				fi;
				[ -e "${FILESDIR}/${PV}/${Current_Patch}/patch_list" ] && ApplyPatch "${FILESDIR}/${PV}/${Current_Patch}/patch_list" "zfs for vanilla - ${zfs_url}";
				;;
		esac
	else continue
	fi;
done;

### END OF PATCH APPLICATIONS ###

	linux-geek_src_prepare
}

# @FUNCTION: src_compile
# @USAGE:
# @DESCRIPTION:
geek-sources_src_compile() {
	linux-geek_src_compile
}

# @FUNCTION: src_install
# @USAGE:
# @DESCRIPTION:
geek-sources_src_install() {
	linux-geek_src_install
}

# @FUNCTION: pkg_postinst
# @USAGE:
# @DESCRIPTION:
geek-sources_pkg_postinst() {
	linux-geek_pkg_postinst
	einfo
	einfo "Wiki: https://github.com/init6/init_6/wiki/geek-sources"
	einfo
	einfo "For more info on this patchset, and how to report problems, see:"
	for Current_Patch in $GEEKSOURCES_PATCHING_ORDER; do
		if use_if_iuse "${Current_Patch}" || [[ "${Current_Patch}" == "fix" ]] || [[ "${Current_Patch}" == "upatch" ]] ; then
			case "${Current_Patch}" in
				aufs)	einfo "aufs3 - ${aufs_url}"
					if ! has_version sys-fs/aufs-util; then
						ewarn
						ewarn "In order to use aufs FS you need to install sys-fs/aufs-util"
						ewarn
					fi
					;;
				bfq)	einfo "Budget Fair Queueing Budget I/O Scheduler - ${bfq_url}";
					;;
				bld)	einfo "Alternate CPU load distribution technique for Linux kernel scheduler - ${bld_url}";
					;;
				ck)	einfo "Con Kolivas high performance patchset - ${ck_url}";
					;;
				debian)	einfo "Debian - ${debian_url}";
					;;
				fedora)	einfo "Fedora - ${fedora_url}";
					;;
				genpatches) einfo "Gentoo patches - ${genpatches_url}";
					;;
				grsecurity) einfo "GrSecurity patches - ${grsecurity_url}";
					local GRADM_COMPAT="sys-apps/gradm-2.9.1"
					ewarn
					ewarn "Hardened Gentoo provides three different predefined grsecurity level:"
					ewarn "[server], [workstation], and [virtualization].  Those who intend to"
					ewarn "use one of these predefined grsecurity levels should read the help"
					ewarn "associated with the level.  Because some options require >=gcc-4.5,"
					ewarn "users with more, than one version of gcc installed should use gcc-config"
					ewarn "to select a compatible version."
					ewarn
					ewarn "Users of grsecurity's RBAC system must ensure they are using"
					ewarn "${GRADM_COMPAT}, which is compatible with ${PF}."
					ewarn "It is strongly recommended that the following command is issued"
					ewarn "prior to booting a ${PF} kernel for the first time:"
					ewarn
					ewarn "emerge -na =${GRADM_COMPAT}*"
					ewarn
					ewarn
					;;
				ice)	einfo "TuxOnIce - ${ice_url}";
					ewarn
					ewarn "${P} has the following optional runtime dependencies:"
					ewarn "  sys-apps/tuxonice-userui"
					ewarn "    provides minimal userspace progress information related to"
					ewarn "    suspending and resuming process"
					ewarn "  sys-power/hibernate-script or sys-power/pm-utils"
					ewarn "    runtime utilites for hibernating and suspending your computer"
					ewarn
					ewarn "If there are issues with this kernel, please direct any"
					ewarn "queries to the tuxonice-users mailing list:"
					ewarn "http://lists.tuxonice.net/mailman/listinfo/tuxonice-users/"
					ewarn
					;;
				imq)	einfo "Intermediate Queueing Device patches - ${imq_url}";
					;;
				lqx)	einfo "Liquorix patches - ${lqx_url}";
					;;
				mageia) einfo "Mandriva/Mageia - ${mageia_url}";
					;;
				pardus) einfo "Pardus - ${pardus_url}";
					;;
				pax) einfo "PAX patches - ${pax_url}";
					;;
				pf) einfo "pf-kernel patches - ${pf_url}";
					ewarn
					ewarn "Linux kernel fork with new features, including the -ck patchset (BFS), BFQ, TuxOnIce and UKSM"
					ewarn
					;;
				phc) einfo "Processor Hardware Control for the Linux Kernel - ${phc_url}";
					;;
				pld)	einfo "PLD - ${pld_url}";
					;;
				reiser4) einfo "Reiser4 - ${reiser4_url}";
					if ! has_version sys-fs/reiser4progs; then
						ewarn
						ewarn "In order to use Reiser4 FS you need to install sys-fs/reiser4progs"
						ewarn
					fi
					;;
				rifs)	einfo "RIFS scheduler - ${rifs_url}";
					;;
				rt)	einfo "Ingo Molnar's realtime preempt patches - ${rt_url}";
					;;
				rtai)	einfo "RealTime Application Interface for Linux - ${rtai_url}";
					;;
				scst)	einfo "Generic SCSI target (SCST) subsystem for Linux - ${scst_url}";
					;;
				suse)	einfo "OpenSuSE - ${suse_url}";
					;;
				uksm)	einfo "Ultra Kernel Samepage Merging - ${uksm_url}";
					;;
				vserver) einfo "VServer - ${vserver_url}";
					;;
				xenomai) einfo "Xenomai: Real-Time Framework for Linux - ${xenomai_url}";
					;;
				zen)	einfo "zen-kernel - ${zen_url}";
					;;
				zfs)	einfo "zfs - ${zfs_url}";
					;;
				esac
			else continue
		fi;
	done;
}
