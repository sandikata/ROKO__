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

KNOWN_USES="aufs bfq bld branding build ck deblob fedora gentoo grsec ice lqx mageia pax pf reiser4 rt suse symlink uksm zen zfs"

# @FUNCTION: geek-sources_init_variables
# @INTERNAL
# @DESCRIPTION:
# Internal function initializing all git variables.
# We define it in function scope so user can define
# all the variables before and after inherit.
geek-sources_init_variables() {
	debug-print-function ${FUNCNAME} "$@"

	: ${GEEK_STORE_DIR:="${PORTAGE_ACTUAL_DISTDIR-${DISTDIR}}/geek"}
	# Disable the sandbox for this dir
	addwrite "${GEEK_STORE_DIR}"

	: ${SKIP_KERNEL_PATCH_UPDATE:="lqx pf zen"}
	: ${patch_user_dir:="/etc/portage/patches"}
	: ${cfg_file:="/etc/portage/kernel.conf"}
	: ${DEFAULT_GEEKSOURCES_PATCHING_ORDER:="pax lqx pf zen bfq ck gentoo grsec ice reiser4 rt bld uksm aufs mageia fedora suse zfs branding fix upatch"}

	local disable_fixes_cfg=$(source $cfg_file 2>/dev/null; echo ${disable_fixes})
	: ${disable_fixes:=${disable_fixes_cfg:-no}} # disable_fixes=yes/no
}

# internal function
#
# @FUNCTION: USEKnown
# @USAGE:
# @DESCRIPTION:
USEKnown() {
	debug-print-function ${FUNCNAME} "$@"

	local USE=$1
	[ "${USE}" == "" ] && die "${RED}Feature not defined!${NORMAL}"

	expr index "${SUPPORTED_USES}" "${USE}" >/dev/null || die "${RED}${USE}${NORMAL} ${BLUE}is not supported in current kernel${NORMAL}"
	expr index "${KNOWN_USES}" "${USE}" >/dev/null || die "${RED}${USE}${NORMAL} ${BLUE}is not known${NORMAL}"
	IUSE="${IUSE} ${USE}"
	case ${USE} in
		aufs)	aufs_ver=${user_aufs_ver:-$KMV}
			aufs_def_src="git://git.code.sf.net/p/aufs/aufs3-standalone"
			aufs_src=${user_aufs_src:-$aufs_def_src}
			aufs_url="http://aufs.sourceforge.net"
			aufs_inf="${YELLOW}Another UnionFS - ${aufs_url}${NORMAL}"
			HOMEPAGE="${HOMEPAGE} ${aufs_url}"
			;;
		bfq)	bfq_ver=${user_bfq_ver:-$KMV}
			bfq_def_src="http://algo.ing.unimo.it/people/paolo/disk_sched/patches"
			bfq_src=${user_bfq_src:-$bfq_def_src}
			bfq_url="http://algo.ing.unimo.it/people/paolo/disk_sched/"
			bfq_inf="${YELLOW}Budget Fair Queueing Budget I/O Scheduler - ${bfq_url}${NORMAL}"
			HOMEPAGE="${HOMEPAGE} ${bfq_url}"
			;;
		bld)	bld_ver=${user_bld_ver:-$KMV}
			bld_def_src="http://bld.googlecode.com/files/bld-${bld_ver/KMV/$KMV}.tar.bz2"
			bld_src=${user_bld_src:-$bld_def_src}
			bld_url="http://code.google.com/p/bld"
			bld_inf="${YELLOW}Alternate CPU load distribution technique for Linux kernel scheduler - ${bld_url}${NORMAL}"
			HOMEPAGE="${HOMEPAGE} ${bld_url}"
			SRC_URI="${SRC_URI}
				bld?		( ${bld_src} )"
			;;
		ck)	ck_ver=${user_ck_ver:-$KMV-ck1}
			ck_def_src="http://ck.kolivas.org/patches/3.0/${KMV}/${ck_ver/KMV/$KMV}/patch-${ck_ver/KMV/$KMV}.lrz"
			ck_src=${user_ck_src:-$ck_def_src}
			ck_url="http://users.on.net/~ckolivas/kernel"
			ck_inf="${YELLOW}Con Kolivas high performance patchset - ${ck_url}${NORMAL}"
			HOMEPAGE="${HOMEPAGE} ${ck_url}"
			DEPEND="${DEPEND} >=app-arch/lrzip-0.614"
			SRC_URI="${SRC_URI}
				ck?		( ${ck_src} )"
			;;
		fedora)	fedora_ver=${user_fedora_ver:-f19}
			fedora_def_src="git://pkgs.fedoraproject.org/kernel.git"
			fedora_src=${user_fedora_src:-$fedora_def_src}
			fedora_url="http://fedoraproject.org"
			fedora_inf="${YELLOW}Fedora - ${fedora_url}${NORMAL}"
			HOMEPAGE="${HOMEPAGE} ${fedora_url}"
			;;
		gentoo)	gentoo_ver=${user_gentoo_ver:-$KMV}
			gentoo_def_src="svn://anonsvn.gentoo.org/linux-patches/genpatches-2.6/trunk"
			gentoo_src=${user_gentoo_src:-$gentoo_def_src}
			gentoo_url="http://dev.gentoo.org/~mpagano/genpatches"
			gentoo_inf="${YELLOW}Gentoo patches - ${gentoo_url}${NORMAL}"
			HOMEPAGE="${HOMEPAGE} ${gentoo_url}"
			;;
		grsec)	grsec_ver=${user_grsec_ver:-$KMV}
			grsec_def_src="git://git.overlays.gentoo.org/proj/hardened-patchset.git"
			grsec_src=${user_grsec_src:-$grsec_def_src}
			grsec_url="http://hardened.gentoo.org"
			grsec_inf="${YELLOW}GrSecurity patches - ${grsec_url}${NORMAL}"
			HOMEPAGE="${HOMEPAGE} ${grsec_url}"
			RDEPEND="${RDEPEND}
				grsec?	( >=sys-apps/gradm-2.2.2 )"
			;;
		ice)	ice_ver=${user_ice_ver:-$KMV}
			ice_def_src="https://github.com/NigelCunningham/tuxonice-kernel/compare/vanilla-${ice_ver/KMV/$KMV}...tuxonice-${ice_ver/KMV/$KMV}.diff"
			ice_src=${user_ice_src:-$ice_def_src}
			ice_url="http://tuxonice.net"
			ice_inf="${YELLOW}TuxOnIce - ${ice_url}${NORMAL}"
			HOMEPAGE="${HOMEPAGE} ${ice_url}"
			RDEPEND="${RDEPEND}
				ice?	( >=sys-apps/tuxonice-userui-1.0
						|| ( >=sys-power/hibernate-script-2.0 sys-power/pm-utils ) )"
			;;
		lqx)	lqx_ver=${user_lqx_ver:-$KMV}
			lqx_def_src="http://liquorix.net/sources/${lqx_ver/KMV/$KMV}.patch.gz"
			lqx_src=${user_lqx_src:-$lqx_def_src}
			lqx_url="http://liquorix.net"
			lqx_inf="${YELLOW}Liquorix patches - ${lqx_url}${NORMAL}"
			HOMEPAGE="${HOMEPAGE} ${lqx_url}"
			SRC_URI="${SRC_URI}
				lqx?			( ${lqx_src} )"
			;;
		mageia) mageia_ver=${user_mageia_ver:-$KMV}
			mageia_def_src="svn://svn.mageia.org/svn/packages/cauldron/kernel"
			mageia_src=${user_mageia_src:-$mageia_def_src}
			mageia_url="http://www.mageia.org"
			mageia_inf="${YELLOW}Mageia - ${mageia_url}${NORMAL}"
			HOMEPAGE="${HOMEPAGE} ${mageia_url}"
			;;
		pax)	pax_ver=${user_pax_ver:-$KMV}
			pax_def_src="http://grsecurity.net/test/pax-linux-${pax_ver/KMV/$KMV}.patch"
			pax_src=${user_pax_src:-$pax_def_src}
			pax_url="http://pax.grsecurity.net"
			pax_inf="${YELLOW}PAX patches - ${pax_url}${NORMAL}"
			HOMEPAGE="${HOMEPAGE} ${pax_url}"
			SRC_URI="${SRC_URI}
				pax?			( ${pax_src} )"
			;;
		pf)	pf_ver=${user_pf_ver:-$KMV}
			pf_def_src="http://pf.natalenko.name/sources/${KMV}/patch-${pf_ver/KMV/$KMV}.bz2"
			pf_src=${user_pf_src:-$pf_def_src}
			pf_url="http://pf.natalenko.name"
			pf_inf="${YELLOW}pf-kernel patches - ${pf_url}${NORMAL}"
			HOMEPAGE="${HOMEPAGE} ${pf_url}"
			SRC_URI="${SRC_URI}
				pf?			( ${pf_src} )"
			;;
		reiser4) reiser4_ver=${user_reiser4_ver:-$KMV}
			reiser4_def_src="mirror://sourceforge/project/reiser4/reiser4-for-linux-3.x/reiser4-for-${reiser4_ver/PV/$PV}.patch.gz"
			reiser4_src=${user_reiser4_src:-$reiser4_def_src}
			reiser4_url="http://sourceforge.net/projects/reiser4"
			reiser4_inf="${YELLOW}ReiserFS v4 - ${reiser4_url}${NORMAL}"
			HOMEPAGE="${HOMEPAGE} ${reiser4_url}"
			SRC_URI="${SRC_URI}
				reiser4?	( ${reiser4_src} )"
			;;
		rt)	rt_ver=${user_rt_ver:-$KMV}
			rt_def_src="mirror://kernel/linux/kernel/projects/rt/${KMV}/patch-${rt_ver/KMV/$KMV}.patch.xz"
			rt_src=${user_rt_src:-$rt_def_src}
			rt_url="http://www.kernel.org/pub/linux/kernel/projects/rt"
			rt_inf="${YELLOW}Ingo Molnar"\'"s realtime preempt patches - ${rt_url}${NORMAL}"
			HOMEPAGE="${HOMEPAGE} ${rt_url}"
			SRC_URI="${SRC_URI}
				rt?		( ${rt_src} )"
			;;
		suse)	suse_ver=${user_suse_ver:-stable}
			suse_def_src="git://kernel.opensuse.org/kernel-source.git"
			suse_src=${user_suse_src:-$suse_def_src}
			suse_url="http://www.opensuse.org"
			suse_inf="${YELLOW}OpenSuSE - ${suse_url}${NORMAL}"
			HOMEPAGE="${HOMEPAGE} ${suse_url}"
			;;
		uksm)	uksm_ver=${user_uksm_ver:-$KMV}
			uksm_name=${user_uksm_name:-uksm-${uksm_ver}-for-v${KMV}.ge.1}
			uksm_def_src="http://kerneldedup.org/download/uksm/${uksm_ver}/${uksm_name}.patch"
			uksm_src=${user_uksm_src:-$uksm_def_src}
			uksm_url="http://kerneldedup.org"
			uksm_inf="${YELLOW}Ultra Kernel Samepage Merging - ${uksm_url}${NORMAL}"
			HOMEPAGE="${HOMEPAGE} ${uksm_url}"
			;;
		zen)	zen_ver=${user_zen_ver:-$KMV}
			zen_def_src="https://github.com/damentz/zen-kernel/compare/torvalds:v${zen_ver/KMV/$KMV}...${zen_ver/KMV/$KMV}/master.diff"
			zen_src=${user_zen_src:-$zen_def_src}
			zen_url="https://github.com/damentz/zen-kernel"
			zen_inf="${YELLOW}The Zen Kernel - ${zen_url}${NORMAL}"
			HOMEPAGE="${HOMEPAGE} ${zen_url}"
			;;
		zfs)	spl_ver=${user_spl_ver:-$KMV}
			spl_def_src="git://github.com/zfsonlinux/spl.git"
			spl_src=${user_spl_src:-$spl_def_src}
			zfs_ver=${user_zfs_ver:-$KMV}
			zfs_def_src="git://github.com/zfsonlinux/zfs.git"
			zfs_src=${user_zfs_src:-$zfs_def_src}
			zfs_url="http://zfsonlinux.org"
			zfs_inf="${YELLOW}Native ZFS on Linux - ${zfs_url}${NORMAL}"
			HOMEPAGE="${HOMEPAGE} ${zfs_url}"
			LICENSE="${LICENSE} GPL-3"
			PDEPEND="${PDEPEND}
				zfs?	( sys-fs/zfs[kernel-builtin(+)] )"
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
	debug-print-function ${FUNCNAME} "$@"

	in_iuse $1 || return 1
	use $1
}

# @FUNCTION: get_from_url
# @USAGE:
# @DESCRIPTION:
get_from_url() {
	debug-print-function ${FUNCNAME} "$@"

	local url="$1"
	local release="$2"
	shift
	wget -nd --no-parent --level 1 -r -R "*.html*" --reject "$release" \
	"$url/$release" > /dev/null 2>&1
}

# @FUNCTION: git_get_all_branches
# @USAGE:
# @DESCRIPTION:
git_get_all_branches(){
	debug-print-function ${FUNCNAME} "$@"

	for branch in `git branch -a | grep remotes | grep -v HEAD | grep -v master`; do
		git branch --track ${branch##*/} ${branch} > /dev/null 2>&1
	done
}

# @FUNCTION: git_checkout
# @USAGE:
# @DESCRIPTION:
git_checkout(){
	debug-print-function ${FUNCNAME} "$@"

	local branch_name=${1:-master}

	pushd "${EGIT_SOURCEDIR}" > /dev/null

	debug-print "${FUNCNAME}: git checkout ${branch_name}"
	git checkout ${branch_name}

	popd > /dev/null
}

# @FUNCTION: get_or_bump
# @USAGE:
# @DESCRIPTION:
get_or_bump() {
	debug-print-function ${FUNCNAME} "$@"

	local patch=$1
	local CSD="${GEEK_STORE_DIR}/${patch}"
	shift
	if [ -d ${CSD} ]; then
		cd "${CSD}" || die "${RED}cd ${CSD} failed${NORMAL}"
		if [ -e ".git" ]; then # git
			git fetch --all && git pull --all
		elif [ -e ".svn" ]; then # subversion
			svn up
		fi
	else
		case "${patch}" in
		aufs)	git clone "${aufs_src}" "${CSD}" > /dev/null 2>&1; cd "${CSD}" || die "${RED}cd ${CSD} failed${NORMAL}"; git_get_all_branches ;;
		fedora)	git clone "${fedora_src}" "${CSD}" > /dev/null 2>&1; cd "${CSD}" || die "${RED}cd ${CSD} failed${NORMAL}"; git_get_all_branches ;;
		gentoo)	svn co "${gentoo_src}" "${CSD}" > /dev/null 2>&1;;
		grsec)	git clone "${grsec_src}" "${CSD}" > /dev/null 2>&1; cd "${CSD}" || die "${RED}cd ${CSD} failed${NORMAL}"; git_get_all_branches ;;
		mageia)	svn co "${mageia_src}" "${CSD}" > /dev/null 2>&1;;
		suse)	git clone "${suse_src}" "${CSD}" > /dev/null 2>&1; cd "${CSD}" || die "${RED}cd ${CSD} failed${NORMAL}"; git_get_all_branches ;;
		zfs)	git clone "${spl_src}" "${CSD}/spl" > /dev/null 2>&1; cd "${CSD}/spl" || die "${RED}cd ${CSD} failed${NORMAL}"; git_get_all_branches
			git clone "${zfs_src}" "${CSD}/zfs" > /dev/null 2>&1; cd "${CSD}/zfs" || die "${RED}cd ${CSD} failed${NORMAL}"; git_get_all_branches ;;
		esac
	fi
}

# @FUNCTION: make_patch
# @USAGE:
# @DESCRIPTION:
make_patch() {
	debug-print-function ${FUNCNAME} "$@"

	local patch="$1"
	local CSD="${GEEK_STORE_DIR}/${patch}"
	local CWD="${T}/${patch}"
	local CTD="/tmp/${patch}"$$
	# Disable the sandbox for this dir
	addwrite "${CTD}"
	shift
	case "${patch}" in
	aufs)	cd "${CSD}" >/dev/null 2>&1
		test -d "${CWD}" >/dev/null 2>&1 || mkdir -p "${CWD}"
		get_or_bump "${patch}" > /dev/null 2>&1
		cp -r "${CSD}" "${CTD}" || die "${RED}cp -r ${CSD} ${CTD} failed${NORMAL}"
		cd "${CTD}" || die "${RED}cd ${CTD} failed${NORMAL}"
		dir=( "Documentation" "fs" "include" )
		local dest="${CWD}"/aufs3-${aufs_ver}-`date +"%Y%m%d"`.patch

		git_checkout "origin/aufs${aufs_ver}" > /dev/null 2>&1 git pull > /dev/null 2>&1

		mkdir ../a ../b || die "${RED}mkdir ../a ../b failed${NORMAL}"
		cp -r {Documentation,fs,include} ../b || die "${RED}cp -r {Documentation,fs,include} ../b failed${NORMAL}"
		rm ../b/include/uapi/linux/Kbuild || die "${RED}rm ../b/include/uapi/linux/Kbuild failed${NORMAL}"
		cd .. || die "${RED}cd .. failed${NORMAL}"

		for i in "${dir[@]}"; do
			diff -U 3 -dHrN -- a/ b/"${i}"/ >> "${dest}"
			sed -i "s:a/:a/"${i}"/:" "${dest}"
			sed -i "s:b:b:" "${dest}"
		done
		rm -rf a b || die "${RED}rm -rf a b failed${NORMAL}"

		cp "${CTD}"/aufs3-base.patch "${CWD}"/aufs3-base-${aufs_ver}-`date +"%Y%m%d"`.patch || die "${RED}cp ${CTD}/aufs3-base.patch ${CWD}/aufs3-base-${aufs_ver}-`date +"%Y%m%d"`.patch failed${NORMAL}"
		cp "${CTD}"/aufs3-standalone.patch "${CWD}"/aufs3-standalone-${aufs_ver}-`date +"%Y%m%d"`.patch || die "${RED}cp ${CTD}/aufs3-standalone.patch ${CWD}/aufs3-standalone-${aufs_ver}-`date +"%Y%m%d"`.patch failed${NORMAL}"
		cp "${CTD}"/aufs3-kbuild.patch "${CWD}"/aufs3-kbuild-${aufs_ver}-`date +"%Y%m%d"`.patch || die "${RED}cp ${CTD}/aufs3-kbuild.patch ${CWD}/aufs3-kbuild-${aufs_ver}-`date +"%Y%m%d"`.patch failed${NORMAL}"
		cp "${CTD}"/aufs3-proc_map.patch "${CWD}"/aufs3-proc_map-${aufs_ver}-`date +"%Y%m%d"`.patch || die "${RED}cp ${CTD}/aufs3-proc_map.patch ${CWD}/aufs3-proc_map-${aufs_ver}-`date +"%Y%m%d"`.patch failed${NORMAL}"
		cp "${CTD}"/aufs3-loopback.patch "${CWD}"/aufs3-loopback-${aufs_ver}-`date +"%Y%m%d"`.patch || die "${RED}cp ${CTD}/aufs3-loopback.patch ${CWD}/aufs3-loopback-${aufs_ver}-`date +"%Y%m%d"`.patch failed${NORMAL}"

		rm -rf "${CTD}" || die "${RED}rm -rf ${CTD} failed${NORMAL}"

		ls -1 "${CWD}" | grep ".patch" > "${CWD}"/patch_list
	;;
	bfq)	test -d "${CWD}" >/dev/null 2>&1 || mkdir -p "${CWD}"
		cd "${CWD}" || die "${RED}cd ${CWD} failed${NORMAL}"

		get_from_url "${bfq_src}" "${bfq_ver}" > /dev/null 2>&1

		ls -1 "${CWD}" | grep ".patch" > "${CWD}"/patch_list
	;;
	bld)	test -d "${CWD}" >/dev/null 2>&1 || mkdir -p "${CWD}"
		test -d "${CTD}" >/dev/null 2>&1 || mkdir -p "${CTD}"
		cd "${CTD}" || die "${RED}cd ${CTD} failed${NORMAL}"

		cp "${DISTDIR}/bld-${bld_ver/KMV/$KMV}.tar.bz2" "bld-${bld_ver/KMV/$KMV}.tar.bz2" || die "${RED}cp ${DISTDIR}/bld-${bld_ver/KMV/$KMV}.tar.bz2 bld-${bld_ver/KMV/$KMV}.tar.bz2 failed${NORMAL}"
		tar -xjpf "bld-${bld_ver/KMV/$KMV}.tar.bz2" || die "${RED}tar -xjpf bld-${bld_ver/KMV/$KMV}.tar.bz2 failed${NORMAL}"
		find "${CTD}/bld-${bld_ver/KMV/$KMV}/" -name "*-${bld_ver/KMV/$KMV}.patch" -exec cp {} "${CWD}" \ > /dev/null 2>&1;

		rm -rf "${CTD}" || die "${RED}rm -rf ${CTD} failed${NORMAL}"

		ls -1 "${CWD}" | grep ".patch" > "${CWD}"/patch_list
	;;
	fedora) cd "${CSD}" >/dev/null 2>&1
		test -d "${CWD}" >/dev/null 2>&1 || mkdir -p "${CWD}"
		get_or_bump "${patch}" > /dev/null 2>&1

		cp -r "${CSD}" "${CTD}" || die "${RED}cp -r ${CSD} ${CTD} failed${NORMAL}"
		cd "${CTD}" || die "${RED}cd ${CTD} failed${NORMAL}"

		git_checkout "${fedora_ver}" > /dev/null 2>&1 git pull > /dev/null 2>&1

		ls -1 | grep ".patch" | xargs -I{} cp "{}" "${CWD}"

		awk '/^Apply.*Patch.*\.patch/{print $2}' kernel.spec > "$CWD"/patch_list

		rm -rf "${CTD}" || die "${RED}rm -rf ${CTD} failed${NORMAL}"
	;;
	gentoo) cd "${CSD}" >/dev/null 2>&1
		test -d "${CWD}" >/dev/null 2>&1 || mkdir -p "${CWD}"
		cd "${CWD}" || die "${RED}cd ${CWD} failed${NORMAL}"

		get_or_bump "${patch}" > /dev/null 2>&1

		cp -r "${CSD}" "${CTD}" || die "${RED}cp -r ${CSD} ${CTD} failed${NORMAL}"
		cd "${CTD}"/${KMV} || die "${RED}cd ${CTD}/${KMV} failed${NORMAL}"

		find -name .svn -type d -exec rm -rf {} \ > /dev/null 2>&1
		find -type d -empty -delete

		ls -1 | grep "linux" | xargs -I{} rm -rf "{}"
		ls -1 | grep ".patch" > "$CWD"/patch_list

		cp -r "${CTD}"/${KMV}/* "${CWD}" || die "${RED}cp -r ${CTD}/${KMV}/* ${CWD} failed${NORMAL}"

		rm -rf "${CTD}" || die "${RED}rm -rf ${CTD} failed${NORMAL}"
	;;
	grsec)	cd "${CSD}" >/dev/null 2>&1
		test -d "${CWD}" >/dev/null 2>&1 || mkdir -p "${CWD}"
		get_or_bump "${patch}" > /dev/null 2>&1

		cp -r "${CSD}" "${CTD}" || die "${RED}cp -r ${CSD} ${CTD} failed${NORMAL}"

		cd "${CTD}"/"${grsec_ver}" || die "${RED}cd ${CTD}/${grsec_ver} failed${NORMAL}"

		ls -1 | xargs -I{} cp "{}" "${CWD}"

		rm -rf "${CTD}" || die "${RED}rm -rf ${CTD} failed${NORMAL}"

		ls -1 "${CWD}" | grep ".patch" > "${CWD}"/patch_list
	;;
	ice)	test -d "${CWD}" >/dev/null 2>&1 || mkdir -p "${CWD}"
		dest="${CWD}"/tuxonice-kernel-"${PV}"-`date +"%Y%m%d"`.patch
		wget "${ice_src}" -O "${dest}" > /dev/null 2>&1
		cd "${CWD}" || die "${RED}cd ${CWD} failed${NORMAL}"
		ls -1 | grep ".patch" | xargs -I{} xz "{}" | xargs -I{} cp "{}" "${CWD}"
		ls -1 "${CWD}" | grep ".patch.xz" > "${CWD}"/patch_list
	;;
	mageia) cd "${CSD}" >/dev/null 2>&1
		test -d "${CWD}" >/dev/null 2>&1 || mkdir -p "${CWD}"
		get_or_bump "${patch}" > /dev/null 2>&1

		cp -r "${CSD}" "${CTD}" || die "${RED}cp -r ${CSD} ${CTD} failed${NORMAL}"
		cd "${CTD}"/"${mageia_ver}"/PATCHES || die "${RED}cd ${CTD}/${mageia_ver}/PATCHES failed${NORMAL}"

		find . -name "*.patch" | xargs -i cp "{}" "${CWD}"

		awk '{gsub(/3rd/,"#3rd") ;print $0}' patches/series > "${CWD}"/patch_list

		rm -rf "${CTD}" || die "${RED}rm -rf ${CTD} failed${NORMAL}"
	;;
	suse)	cd "${CSD}" >/dev/null 2>&1
		test -d "${CWD}" >/dev/null 2>&1 || mkdir -p "${CWD}"
		get_or_bump "${patch}" > /dev/null 2>&1

		cp -r "${CSD}" "${CTD}" || die "${RED}cp -r ${CSD} ${CTD} failed${NORMAL}"

		cd "${CTD}" || die "${RED}cd ${CTD} failed${NORMAL}"

		git_checkout "${suse_ver}" > /dev/null 2>&1 git pull > /dev/null 2>&1

		[ -e "patches.kernel.org" ] && rm -rf patches.kernel.org > /dev/null 2>&1
		[ -e "patches.rpmify" ] && rm -rf patches.rpmify > /dev/null 2>&1

		awk '!/(#|^$)/ && !/^(\+(needs|tren|hare|xen|jbeulich|jeffm))|patches\.(kernel|rpmify|xen).*/{gsub(/[ \t]/,"") ; print $1}' series.conf > patch_list
		grep patches.xen series.conf > spatch_list

		cp -r patches.*/ "${CWD}" || die "${RED}cp -r patches.*/ ${CWD} failed${NORMAL}"
		cp patch_list "${CWD}" || die "${RED}cp patch_list ${CWD} failed${NORMAL}"
		cp spatch_list "${CWD}" || die "${RED}cp spatch_list ${CWD} failed${NORMAL}"

		rm -rf "${CTD}" || die "${RED}rm -rf ${CTD} failed${NORMAL}"
	;;
	uksm)	test -d "${CWD}" >/dev/null 2>&1 || mkdir -p "${CWD}"
		wget "${uksm_src}" -O "${CWD}/${uksm_name}.patch" > /dev/null 2>&1
		cd "${CWD}" || die "${RED}cd ${CWD} failed${NORMAL}"
		ls -1 "${CWD}" | grep ".patch" > "${CWD}"/patch_list
	;;
	zen)	test -d "${CWD}" >/dev/null 2>&1 || mkdir -p "${CWD}"
		dest="${CWD}"/zen-kernel-"${PV}"-`date +"%Y%m%d"`.patch
		wget "${zen_src}" -O "${dest}" > /dev/null 2>&1
		cd "${CWD}" || die "${RED}cd ${CWD} failed${NORMAL}"
		ls -1 | grep ".patch" | xargs -I{} xz "{}" | xargs -I{} cp "{}" "${CWD}"
		ls -1 "${CWD}" | grep ".patch.xz" > "${CWD}"/patch_list
	;;
	zfs)	einfo "Prepare kernel sources"
		cd "${S}" || die "${RED}cd ${S} failed${NORMAL}"
		export PORTAGE_ARCH="${ARCH}"
		case ${ARCH} in
			x86) export ARCH="i386";;
			amd64) export ARCH="x86_64";;
			*) export ARCH="${ARCH}";;
		esac
		`zcat /proc/config.gz > .config && yes "" | make oldconfig && make prepare && make scripts` > /dev/null 2>&1

		test -d "${CWD}" >/dev/null 2>&1 || mkdir -p "${CWD}"
		get_or_bump "${patch}" > /dev/null 2>&1
		cp -r "${CSD}" "${CTD}" || die "${RED}cp -r ${CSD} ${CTD} failed${NORMAL}"
		rm -rf "${CTD}"/{spl,zfs}/.git || die "${RED}rm -rf ${CTD}/{spl,zfs}/.git failed${NORMAL}"

		addwrite "/usr/src/linux"
		unlink "/usr/src/linux" #|| die "${RED}unlink /usr/src/linux failed${NORMAL}"
		ln -s "${S}" /usr/src/linux #|| die "${RED}ln -s ${S} /usr/src/linux failed${NORMAL}"

		einfo "Integrate SPL"
		cd "${CTD}/spl" || die "${RED}cd ${CTD}/spl failed${NORMAL}"
		[ -e autogen.sh ] && ./autogen.sh > /dev/null 2>&1
		./configure \
			--prefix=/ \
			--libdir=/lib64 \
			--includedir=/usr/include \
			--datarootdir=/usr/share \
			--enable-linux-builtin=yes \
			--with-linux=${S} \
			--with-linux-obj=${S} > /dev/null 2>&1 || die "${RED}spl ./configure failed${NORMAL}"
		./copy-builtin ${S} > /dev/null 2>&1 || die "${RED}spl ./copy-builtin ${S} failed${NORMAL}"

		einfo "Integrate ZFS"
		cd "${CTD}/zfs" || die "${RED}cd ${CTD}/zfs failed${NORMAL}"
		[ -e autogen.sh ] && ./autogen.sh > /dev/null 2>&1
		./configure \
			--prefix=/ \
			--libdir=/lib64 \
			--includedir=/usr/include \
			--datarootdir=/usr/share \
			--enable-linux-builtin=yes \
			--with-linux=${S} \
			--with-linux-obj=${S} \
			--with-spl="${CTD}/spl" \
			--with-spl-obj="${CTD}/spl" > /dev/null 2>&1 || die "${RED}zfs ./configure failed${NORMAL}"
		./copy-builtin ${S} > /dev/null 2>&1 || die "${RED}zfs ./copy-builtin ${S} failed${NORMAL}"

		cd "${S}" || die "${RED}cd ${S} failed${NORMAL}"
		make mrproper > /dev/null 2>&1

		addwrite "/usr/src/linux"
		unlink "/usr/src/linux" #|| die "${RED}unlink /usr/src/linux failed${NORMAL}"

		mv "${CTD}" "${S}/patches/${patch}" || die "${RED}mv ${CTD} ${S}/patches/${patch} failed${NORMAL}"
	;;
	esac

	cd "${S}" || die "${RED}cd ${S} failed${NORMAL}"
}

# @FUNCTION: src_unpack
# @USAGE:
# @DESCRIPTION: Extract source packages and do any necessary patching or fixes.
geek-sources_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	geek-sources_init_variables

	for Current_Patch in $SKIP_KERNEL_PATCH_UPDATE; do
		if use_if_iuse "${Current_Patch}"; then
		case "${Current_Patch}" in
			*) SKIP_UPDATE="1" skip_squeue="yes" ;;
		esac
		else continue
		fi
	done

	einfo "${BLUE}Disable fixes -->${NORMAL} ${RED}$disable_fixes${NORMAL}"
	linux-geek_src_unpack
}

# @FUNCTION: src_prepare
# @USAGE:
# @DESCRIPTION: Prepare source packages and do any necessary patching or fixes.
geek-sources_src_prepare() { ### BRANCH APPLY ###
	debug-print-function ${FUNCNAME} "$@"

	local xUserOrder=""
	local xDefOder=""
	if [ -e "${cfg_file}" ]; then
		source "${cfg_file}"
		xUserOrder="$(echo -n "$GEEKSOURCES_PATCHING_ORDER" | tr '\n' ' ' | tr -s ' ' | tr ' ' '\n' | sort | tr '\n' ' ' | sed -e 's,^\s*,,' -e 's,\s*$,,')"
		xDefOrder="$(echo -n "$DEFAULT_GEEKSOURCES_PATCHING_ORDER" | tr '\n' ' ' | tr -s ' ' | tr ' ' '\n' | sort | tr '\n' ' ' | sed -e 's,^\s*,,' -e 's,\s*$,,')"

		if [ "x${xUserOrder}" = "x${xDefOrder}" ]; then
			ewarn "${BLUE}Use${NORMAL} ${RED}GEEKSOURCES_PATCHING_ORDER=\"${GEEKSOURCES_PATCHING_ORDER}\"${NORMAL} ${BLUE}from${NORMAL} ${RED}${cfg_file}${NORMAL}"
		else
			ewarn "${BLUE}Use${NORMAL} ${RED}GEEKSOURCES_PATCHING_ORDER=\"${GEEKSOURCES_PATCHING_ORDER}\"${NORMAL} ${BLUE}from${NORMAL} ${RED}${cfg_file}${NORMAL}"
			ewarn "${BLUE}Not all USE flag present in GEEKSOURCES_PATCHING_ORDER from${NORMAL} ${RED}${cfg_file}${NORMAL}"
			difference=$(echo "${xDefOrder} ${xUserOrder}" | awk '{for(i=1;i<=NF;i++){_a[$i]++}for(i in _a){if(_a[i]==1)print i}}' ORS=" ")
			ewarn "${BLUE}The following flags are missing:${NORMAL} ${RED}${difference}${NORMAL}"
			ewarn "${BLUE}Probably that"\'"s the plan. In that case, never mind.${NORMAL}"
		fi
	else
		GEEKSOURCES_PATCHING_ORDER="${DEFAULT_GEEKSOURCES_PATCHING_ORDER}"
		ewarn "${BLUE}The order of patching is defined in file${NORMAL} ${RED}${cfg_file}${NORMAL} ${BLUE}with the variable GEEKSOURCES_PATCHING_ORDER is its default value:${NORMAL}
${RED}GEEKSOURCES_PATCHING_ORDER=\"${GEEKSOURCES_PATCHING_ORDER}\"${NORMAL}
${BLUE}You are free to choose any order of patching.${NORMAL}
${BLUE}For example, if you like the alphabetical order of patching you must set the variable:${NORMAL}
${RED}echo 'GEEKSOURCES_PATCHING_ORDER=\"`echo ${GEEKSOURCES_PATCHING_ORDER} | sed "s/ /\n/g" | sort | sed ':a;N;$!ba;s/\n/ /g'`\"' > ${cfg_file}${NORMAL}
${BLUE}Otherwise i will use the default value of GEEKSOURCES_PATCHING_ORDER!${NORMAL}
${BLUE}And may the Force be with you…${NORMAL}"
	fi

for Current_Patch in $GEEKSOURCES_PATCHING_ORDER; do
	if use_if_iuse "${Current_Patch}" || [[ "${Current_Patch}" == "fix" ]] || [[ "${Current_Patch}" == "upatch" ]]; then
		if [ -e "${FILESDIR}/${PV}/${Current_Patch}/info" ]; then
			echo
			cat "${FILESDIR}/${PV}/${Current_Patch}/info"
		fi
		test -d "${S}/patches" >/dev/null 2>&1 || mkdir -p "${S}/patches"
		case "${Current_Patch}" in
			aufs)	make_patch "${Current_Patch}"
				ApplyPatch "${T}/${Current_Patch}/patch_list" "${aufs_inf}"
				mv "${T}/${Current_Patch}" "${S}/patches/${Current_Patch}" || die "${RED}mv ${T}/${Current_Patch} ${S}/patches/${Current_Patch} failed${NORMAL}"
				;;
			bfq)	make_patch "${Current_Patch}"
				ApplyPatch "${T}/${Current_Patch}/patch_list" "${bfq_inf}"
				mv "${T}/${Current_Patch}" "${S}/patches/${Current_Patch}" || die "${RED}mv ${T}/${Current_Patch} ${S}/patches/${Current_Patch} failed${NORMAL}"
				;;
			bld)	if [ "${VERSION}" = "3" -a "${PATCHLEVEL}" = "10" ]; then
					ApplyPatch "${DISTDIR}/BLD-${bld_ver/KMV/$KMV}.patch" "${bld_inf}"
				else
					make_patch "${Current_Patch}"
					ApplyPatch "${T}/${Current_Patch}/patch_list" "${bld_inf}"
					mv "${T}/${Current_Patch}" "${S}/patches/${Current_Patch}" || die "${RED}mv ${T}/${Current_Patch} ${S}/patches/${Current_Patch} failed${NORMAL}"
				fi
				;;
			branding) if [ -e "${FILESDIR}/${Current_Patch}/info" ]; then
					echo
					cat "${FILESDIR}/${Current_Patch}/info"
				fi
				ApplyPatch "${FILESDIR}/${Current_Patch}/patch_list" "Branding"
				;;
			ck)	ApplyPatch "${DISTDIR}/patch-${ck_ver/KMV/$KMV}.lrz" "${ck_inf}"
				if [ -d "${FILESDIR}/${PV}/${Current_Patch}" ]; then
					if [ -e "${FILESDIR}/${PV}/${Current_Patch}/patch_list" ]; then
						ApplyPatch "${FILESDIR}/${PV}/${Current_Patch}/patch_list" "CK Fix"
					fi
				fi
				# Comment out EXTRAVERSION added by CK patch:
				sed -i -e 's/\(^EXTRAVERSION :=.*$\)/# \1/' "Makefile"
				;;
			fedora)	make_patch "${Current_Patch}"
				ApplyPatch "${T}/${Current_Patch}/patch_list" "${fedora_inf}"
				mv "${T}/${Current_Patch}" "${S}/patches/${Current_Patch}" || die "${RED}mv ${T}/${Current_Patch} ${S}/patches/${Current_Patch} failed${NORMAL}"
				;;
			fix)	[ "${disable_fixes}" = "no" ] && ApplyPatch "${FILESDIR}/${PV}/${Current_Patch}/patch_list" "${YELLOW}Fixes for current kernel${NORMAL}"
				;;
			gentoo)	make_patch "${Current_Patch}"
				ApplyPatch "${T}/${Current_Patch}/patch_list" "${gentoo_inf}"
				mv "${T}/${Current_Patch}" "${S}/patches/${Current_Patch}" || die "${RED}mv ${T}/${Current_Patch} ${S}/patches/${Current_Patch} failed${NORMAL}"
				;;
			grsec)	make_patch "${Current_Patch}"
				ApplyPatch "${T}/${Current_Patch}/patch_list" "${grsec_inf}"
				mv "${T}/${Current_Patch}" "${S}/patches/${Current_Patch}" || die "${RED}mv ${T}/${Current_Patch} ${S}/patches/${Current_Patch} failed${NORMAL}"
				;;
			ice)	make_patch "${Current_Patch}"
				ApplyPatch "${T}/${Current_Patch}/patch_list" "${ice_inf}"
				mv "${T}/${Current_Patch}" "${S}/patches/${Current_Patch}" || die "${RED}mv ${T}/${Current_Patch} ${S}/patches/${Current_Patch} failed${NORMAL}"
				;;
			lqx)	ApplyPatch "${DISTDIR}/${lqx_ver/KMV/$KMV}.patch.gz" "${lqx_inf}"
				;;
			mageia)	make_patch "${Current_Patch}"
				ApplyPatch "${T}/${Current_Patch}/patch_list" "${mageia_inf}"
				mv "${T}/${Current_Patch}" "${S}/patches/${Current_Patch}" || die "${RED}mv ${T}/${Current_Patch} ${S}/patches/${Current_Patch} failed${NORMAL}"
				;;
			pax)	ApplyPatch "${DISTDIR}/pax-linux-${pax_ver/KMV/$KMV}.patch" "${pax_inf}"
				;;
			pf)	ApplyPatch "${DISTDIR}/patch-${pf_ver/KMV/$KMV}.bz2" "${pf_inf}"
				;;
			reiser4) ApplyPatch "${DISTDIR}/reiser4-for-${reiser4_ver}.patch.gz" "${reiser4_inf}"
				;;
			rt)	ApplyPatch "${DISTDIR}/patch-${rt_ver}.patch.xz" "${rt_inf}"
				;;
			suse)	make_patch "${Current_Patch}"
				ApplyPatch "${T}/${Current_Patch}/patch_list" "${suse_inf}"
				SmartApplyPatch "${T}/${Current_Patch}/spatch_list" "${YELLOW}OpenSuSE xen - ${suse_url}${NORMAL}"
				mv "${T}/${Current_Patch}" "${S}/patches/${Current_Patch}" || die "${RED}mv ${T}/${Current_Patch} ${S}/patches/${Current_Patch} failed${NORMAL}"
				;;
			uksm)	make_patch "${Current_Patch}"
				ApplyPatch "${T}/${Current_Patch}/patch_list" "${uksm_inf}"
				mv "${T}/${Current_Patch}" "${S}/patches/${Current_Patch}" || die "${RED}mv ${T}/${Current_Patch} ${S}/patches/${Current_Patch} failed${NORMAL}"
				;;
			upatch)	if [ -d "${patch_user_dir}/${CATEGORY}/${PN}" ]; then
					if [ -e "${patch_user_dir}/${CATEGORY}/${PN}/info" ]; then
						echo
						cat "${patch_user_dir}/${CATEGORY}/${PN}/info"
					fi
					if [ -e "${patch_user_dir}/${CATEGORY}/${PN}/patch_list" ]; then
						ApplyPatch "${patch_user_dir}/${CATEGORY}/${PN}/patch_list" "${YELLOW}Applying user patches from${NORMAL} ${RED}${patch_user_dir}/${CATEGORY}/${PN}${NORMAL}"
					else
						ewarn "${BLUE}File${NORMAL} ${RED}${patch_user_dir}/${CATEGORY}/${PN}/patch_list${NORMAL} ${BLUE}not found!${NORMAL}"
						ewarn "${BLUE}Try to apply the patches if they are there…${NORMAL}"
						for i in `ls ${patch_user_dir}/${CATEGORY}/${PN}/*.{patch,gz,bz,bz2,lrz,xz,zip,Z} 2> /dev/null`; do
							ApplyPatch "${i}" "${YELLOW}Applying user patches from${NORMAL} ${RED}${patch_user_dir}/${CATEGORY}/${PN}${NORMAL}"
						done
					fi
				fi
				;;
			zen)	make_patch "${Current_Patch}"
				ApplyPatch "${T}/${Current_Patch}/patch_list" "${zen_inf}"
				mv "${T}/${Current_Patch}" "${S}/patches/${Current_Patch}" || die "${RED}mv ${T}/${Current_Patch} ${S}/patches/${Current_Patch} failed${NORMAL}"
				;;
			zfs)	echo
				ebegin "${zfs_inf}"
					make_patch "${Current_Patch}"
				eend
				;;
		esac
	else continue
	fi
done
	linux-geek_src_prepare
} ### END OF PATCH APPLICATIONS ###

# @FUNCTION: src_compile
# @USAGE:
# @DESCRIPTION: Configure and build the package.
geek-sources_src_compile() {
	debug-print-function ${FUNCNAME} "$@"

	linux-geek_src_compile
}

# @FUNCTION: src_install
# @USAGE:
# @DESCRIPTION: Install a package to ${D}
geek-sources_src_install() {
	debug-print-function ${FUNCNAME} "$@"

	linux-geek_src_install
}

# @FUNCTION: pkg_postinst
# @USAGE:
# @DESCRIPTION: Called after image is installed to ${ROOT}
geek-sources_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	linux-geek_pkg_postinst
	einfo
	einfo "${BLUE}Wiki:${NORMAL} ${RED}https://github.com/init6/init_6/wiki/geek-sources${NORMAL}"
	einfo
	einfo "${BLUE}For more info on this patchset, and how to report problems, see:${NORMAL}"
	for Current_Patch in $GEEKSOURCES_PATCHING_ORDER; do
		if use_if_iuse "${Current_Patch}" || [[ "${Current_Patch}" == "fix" ]] || [[ "${Current_Patch}" == "upatch" ]]; then
			case "${Current_Patch}" in
				aufs)	if ! has_version sys-fs/aufs-util; then
						ewarn
						ewarn "${BLUE}In order to use aufs FS you need to install${NORMAL} ${RED}sys-fs/aufs-util${NORMAL}"
						ewarn
					fi
					;;
				grsec) local GRADM_COMPAT="sys-apps/gradm-2.9.1"
					ewarn
					ewarn "${BLUE}Hardened Gentoo provides three different predefined grsecurity level:${NORMAL}"
					ewarn "${BLUE}[server], [workstation], and [virtualization].  Those who intend to${NORMAL}"
					ewarn "${BLUE}use one of these predefined grsecurity levels should read the help${NORMAL}"
					ewarn "${BLUE}associated with the level.  Because some options require >=gcc-4.5,${NORMAL}"
					ewarn "${BLUE}users with more, than one version of gcc installed should use gcc-config${NORMAL}"
					ewarn "${BLUE}to select a compatible version.${NORMAL}"
					ewarn
					ewarn "${BLUE}Users of grsecurity's RBAC system must ensure they are using${NORMAL}"
					ewarn "${RED}${GRADM_COMPAT}${NORMAL}${BLUE}, which is compatible with${NORMAL} ${RED}${PF}${NORMAL}${BLUE}.${NORMAL}"
					ewarn "${BLUE}It is strongly recommended that the following command is issued${NORMAL}"
					ewarn "${BLUE}prior to booting a${NORMAL} ${RED}${PF}${NORMAL} ${BLUE}kernel for the first time:${NORMAL}"
					ewarn
					ewarn "${RED}emerge -na =${GRADM_COMPAT}*${NORMAL}"
					ewarn
					ewarn
					;;
				ice)	ewarn
					ewarn "${RED}${P}${NORMAL} ${BLUE}has the following optional runtime dependencies:${NORMAL}"
					ewarn "  ${RED}sys-apps/tuxonice-userui${NORMAL}"
					ewarn "    ${BLUE}provides minimal userspace progress information related to${NORMAL}"
					ewarn "    ${BLUE}suspending and resuming process${NORMAL}"
					ewarn "  ${RED}sys-power/hibernate-script${NORMAL} ${BLUE}or${NORMAL} ${RED}sys-power/pm-utils${NORMAL}"
					ewarn "    ${BLUE}runtime utilites for hibernating and suspending your computer${NORMAL}"
					ewarn
					ewarn "${BLUE}If there are issues with this kernel, please direct any${NORMAL}"
					ewarn "${BLUE}queries to the tuxonice-users mailing list:${NORMAL}"
					ewarn "${RED}http://lists.tuxonice.net/mailman/listinfo/tuxonice-users/${NORMAL}"
					ewarn
					;;
				pf)	ewarn
					ewarn "${BLUE}Linux kernel fork with new features, including the -ck patchset (BFS), BFQ, TuxOnIce and UKSM${NORMAL}"
					ewarn
					;;
				reiser4) if ! has_version sys-fs/reiser4progs; then
						ewarn
						ewarn "${BLUE}In order to use Reiser4 FS you need to install${NORMAL} ${RED}sys-fs/reiser4progs${NORMAL}"
						ewarn
					fi
					;;
				esac
			else continue
		fi
	done
}
