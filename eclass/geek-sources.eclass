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
#  Bugs: https://github.com/init6/init_6/issues
#
#  Wiki: https://github.com/init6/init_6/wiki/geek-sources
#

inherit geek-linux geek-utils geek-fix geek-upatch geek-squeue

KNOWN_USES="aufs bfq bld brand build cjktty ck deblob fedora gentoo grsec ice lqx mageia optimization pax pf reiser4 rt suse symlink uksm zen zfs"

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
}

for I in ${SUPPORTED_USES}; do
	USEKnown "${I}"
done

for use_flag in ${IUSE}; do
	case ${use_flag} in
		aufs	)	inherit geek-aufs ;;
		bfq	)	inherit geek-bfq ;;
		bld	)	inherit geek-bld ;;
		brand	)	inherit geek-brand ;;
		build	)	inherit geek-build ;;
		cjktty	)	inherit geek-cjktty ;;
		ck	)	inherit geek-ck ;;
		deblob	)	inherit geek-deblob ;;
		fedora	)	inherit geek-fedora ;;
		gentoo	)	inherit geek-gentoo ;;
		grsec	)	inherit geek-grsec ;;
		ice	)	inherit geek-ice ;;
		lqx	)	inherit geek-lqx ;;
		mageia	)	inherit geek-mageia ;;
		optimization	)	inherit geek-optimization ;;
		pax	)	inherit geek-pax ;;
		pf	)	inherit geek-pf ;;
		reiser4	)	inherit geek-reiser4 ;;
		rt	)	inherit geek-rt ;;
		suse	)	inherit geek-suse ;;
		uksm	)	inherit geek-uksm ;;
		zen	)	inherit geek-zen ;;
		zfs	)	inherit geek-spl geek-zfs ;;
	esac
done

# @FUNCTION: init_variables
# @INTERNAL
# @DESCRIPTION:
# Internal function initializing all variables.
# We define it in function scope so user can define
# all the variables before and after inherit.
geek-sources_init_variables() {
	debug-print-function ${FUNCNAME} "$@"

	: ${SKIP_KERNEL_PATCH_UPDATE:="lqx pf zen"}
	: ${cfg_file:="/etc/portage/kernel.conf"}
	: ${DEFAULT_GEEKSOURCES_PATCHING_ORDER:="zfs optimization pax lqx pf zen bfq ck cjktty gentoo grsec ice reiser4 rt bld uksm aufs mageia fedora suse brand fix upatch squeue"}
	
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

	geek-linux_src_unpack

	test -d "${S}/patches" >/dev/null 2>&1 || mkdir -p "${S}/patches"
	for Current_Patch in $GEEKSOURCES_PATCHING_ORDER; do
		if use_if_iuse "${Current_Patch}" || [ "${Current_Patch}" = "fix" ] || [ "${Current_Patch}" = "upatch" ] || [ "${Current_Patch}" = "squeue" ]; then
			einfo "Unpack - ${Current_Patch}"
			case "${Current_Patch}" in
				aufs	)	geek-aufs_src_unpack ;;
				bfq	)	geek-bfq_src_unpack ;;
				bld	)	geek-bld_src_unpack ;;
				cjktty	)	geek-cjktty_src_unpack ;;
				fedora	)	geek-fedora_src_unpack ;;
				gentoo	)	geek-gentoo_src_unpack ;;
				grsec	)	geek-grsec_src_unpack ;;
				ice	)	geek-ice_src_unpack ;;
				mageia	)	geek-mageia_src_unpack ;;
				optimization	)	geek-optimization_src_unpack ;;
				pf	)	geek-pf_src_unpack ;;
				squeue	)	geek-squeue_src_unpack ;;
				suse	)	geek-suse_src_unpack ;;
				uksm	)	geek-uksm_src_unpack ;;
				zen	)	geek-zen_src_unpack ;;
				zfs	)	geek-spl_src_unpack; geek-zfs_src_unpack ;;
			esac
		else continue
		fi
	done
}

# @FUNCTION: src_prepare
# @USAGE:
# @DESCRIPTION: Prepare source packages and do any necessary patching or fixes.
geek-sources_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

	for Current_Patch in $GEEKSOURCES_PATCHING_ORDER; do
		if use_if_iuse "${Current_Patch}" || [ "${Current_Patch}" = "fix" ] || [ "${Current_Patch}" = "upatch" ] || [ "${Current_Patch}" = "squeue" ]; then
#			einfo "Prepare - ${Current_Patch}"
			case "${Current_Patch}" in
				aufs	)	geek-aufs_src_prepare ;;
				bfq	)	geek-bfq_src_prepare ;;
				bld	)	geek-bld_src_prepare ;;
				brand	)	geek-brand_src_prepare ;;
				cjktty	)	geek-cjktty_src_prepare ;;
				ck	)	geek-ck_src_prepare ;;
				fedora	)	geek-fedora_src_prepare ;;
				fix	)	geek-fix_src_prepare ;;
				gentoo	)	geek-gentoo_src_prepare ;;
				grsec	)	geek-grsec_src_prepare ;;
				ice	)	geek-ice_src_prepare ;;
				lqx	)	geek-lqx_src_prepare ;;
				mageia	)	geek-mageia_src_prepare ;;
				optimization	)	geek-optimization_src_prepare ;;
				pax	)	geek-pax_src_prepare ;;
				pf	)	geek-pf_src_prepare ;;
				reiser4	)	geek-reiser4_src_prepare ;;
				rt	)	geek-rt_src_prepare ;;
				squeue	)	geek-squeue_src_prepare ;;
				suse	)	geek-suse_src_prepare ;;
				uksm	)	geek-uksm_src_prepare ;;
				upatch	)	geek-upatch_src_prepare ;;
				zen	)	geek-zen_src_prepare ;;
				zfs	)	geek-spl_src_prepare; geek-zfs_src_prepare ;;
			esac
		else continue
		fi
	done

	geek-linux_src_prepare
}

# @FUNCTION: src_compile
# @USAGE:
# @DESCRIPTION: Configure and build the package.
geek-sources_src_compile() {
	debug-print-function ${FUNCNAME} "$@"

	geek-linux_src_compile
}

# @FUNCTION: src_install
# @USAGE:
# @DESCRIPTION: Install a package to ${D}
geek-sources_src_install() {
	debug-print-function ${FUNCNAME} "$@"

	geek-linux_src_install
}

# @FUNCTION: pkg_postinst
# @USAGE:
# @DESCRIPTION: Called after image is installed to ${ROOT}
geek-sources_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	geek-linux_pkg_postinst
	einfo
	einfo "${BLUE}Wiki:${NORMAL} ${RED}https://github.com/init6/init_6/wiki/geek-sources${NORMAL}"
	einfo
	einfo "${BLUE}For more info on this patchset, and how to report problems, see:${NORMAL}"
	for Current_Patch in $GEEKSOURCES_PATCHING_ORDER; do
		if use_if_iuse "${Current_Patch}" || [[ "${Current_Patch}" == "fix" ]] || [[ "${Current_Patch}" == "upatch" ]]; then
			case "${Current_Patch}" in
				aufs	) geek-aufs_pkg_postinst ;;
				grsec	) geek-grsec_pkg_postinst ;;
				ice	) geek-ice_pkg_postinst ;;
				pf	) geek-pf_pkg_postinst ;;
				reiser4	) geek-reiser4_pkg_postinst ;;
				zfs	) geek-spl_pkg_postinst; geek-zfs_pkg_postinst ;;
			esac
			else continue
		fi
	done
}

EXPORT_FUNCTIONS src_unpack src_prepare src_compile src_install pkg_postinst
