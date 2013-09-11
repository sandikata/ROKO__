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
#  https://github.com/init6/init_6/blob/master/eclass/geek-grsec.eclass
#
#  Bugs: https://github.com/init6/init_6/issues
#
#  Wiki: https://github.com/init6/init_6/wiki/geek-sources
#

inherit geek-patch geek-utils

EXPORT_FUNCTIONS src_unpack src_prepare pkg_postinst

# @FUNCTION: init_variables
# @INTERNAL
# @DESCRIPTION:
# Internal function initializing all variables.
# We define it in function scope so user can define
# all the variables before and after inherit.
geek-grsec_init_variables() {
	debug-print-function ${FUNCNAME} "$@"

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

	: ${GEEK_STORE_DIR:="${PORTAGE_ACTUAL_DISTDIR:-${DISTDIR}}/geek"}
	addwrite "${GEEK_STORE_DIR}" # Disable the sandbox for this dir

	: ${GRSEC_VER:=${GRSEC_VER:-$KMV}}

	: ${GRSEC_SRC:=${GRSEC_SRC:-"git://git.overlays.gentoo.org/proj/hardened-patchset.git"}}

	: ${GRSEC_URL:=${GRSEC_URL:-"http://hardened.gentoo.org"}}

	: ${GRSEC_INF:=${GRSEC_INF:-"${YELLOW}GrSecurity patches - ${GRSEC_URL}${NORMAL}"}}

	: ${HOMEPAGE:="${HOMEPAGE} ${GRSEC_URL}"}

	: ${DEPEND:="${DEPEND}
		grsec?	( >=sys-apps/gradm-2.2.2 )"}
}

# @FUNCTION: src_unpack
# @USAGE:
# @DESCRIPTION: Extract source packages and do any necessary patching or fixes.
geek-grsec_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	geek-grsec_init_variables

	local CSD="${GEEK_STORE_DIR}/grsec"
	local CWD="${T}/grsec"
	local CTD="${T}/grsec"$$
	shift
	cd "${CSD}" >/dev/null 2>&1
	test -d "${CWD}" >/dev/null 2>&1 || mkdir -p "${CWD}"
	if [ -d ${CSD} ]; then
	cd "${CSD}" || die "${RED}cd ${CSD} failed${NORMAL}"
		if [ -e ".git" ]; then # git
			git fetch --all && git pull --all
		fi
	else
		git clone "${GRSEC_SRC}" "${CSD}" > /dev/null 2>&1; cd "${CSD}" || die "${RED}cd ${CSD} failed${NORMAL}"; git_get_all_branches
	fi

	cp -r "${CSD}" "${CTD}" || die "${RED}cp -r ${CSD} ${CTD} failed${NORMAL}"

	cd "${CTD}"/"${GRSEC_VER}" || die "${RED}cd ${CTD}/${GRSEC_VER} failed${NORMAL}"

	ls -1 | xargs -I{} cp "{}" "${CWD}"

	rm -rf "${CTD}" || die "${RED}rm -rf ${CTD} failed${NORMAL}"

	ls -1 "${CWD}" | grep ".patch" > "${CWD}"/patch_list
}

# @FUNCTION: src_prepare
# @USAGE:
# @DESCRIPTION: Prepare source packages and do any necessary patching or fixes.
geek-grsec_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

	ApplyPatch "${T}/grsec/patch_list" "${GRSEC_INF}"
	mv "${T}/grsec" "${S}/patches/grsec" || die "${RED}mv ${T}/grsec ${S}/patches/grsec failed${NORMAL}"
}

# @FUNCTION: pkg_postinst
# @USAGE:
# @DESCRIPTION: Called after image is installed to ${ROOT}
geek-grsec_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	local GRADM_COMPAT="sys-apps/gradm-2.9.1"
	einfo "${BLUE}Hardened Gentoo provides three different predefined grsecurity level:${NORMAL}"
	einfo "${BLUE}[server], [workstation], and [virtualization].  Those who intend to${NORMAL}"
	einfo "${BLUE}use one of these predefined grsecurity levels should read the help${NORMAL}"
	einfo "${BLUE}associated with the level.  Because some options require >=gcc-4.5,${NORMAL}"
	einfo "${BLUE}users with more, than one version of gcc installed should use gcc-config${NORMAL}"
	einfo "${BLUE}to select a compatible version.${NORMAL}"
	einfo
	einfo "${BLUE}Users of grsecurity's RBAC system must ensure they are using${NORMAL}"
	einfo "${RED}${GRADM_COMPAT}${NORMAL}${BLUE}, which is compatible with${NORMAL} ${RED}${PF}${NORMAL}${BLUE}.${NORMAL}"
	einfo "${BLUE}It is strongly recommended that the following command is issued${NORMAL}"
	einfo "${BLUE}prior to booting a${NORMAL} ${RED}${PF}${NORMAL} ${BLUE}kernel for the first time:${NORMAL}"
	einfo
	einfo "${RED}emerge -na =${GRADM_COMPAT}*${NORMAL}"
}
