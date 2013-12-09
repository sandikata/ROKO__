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
#  https://github.com/init6/init_6/blob/master/eclass/geek-ice.eclass
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
geek-ice_init_variables() {
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

	: ${ICE_VER:=${ICE_VER:-$KMV}}

	: ${ICE_SRC:=${ICE_SRC:-"https://github.com/NigelCunningham/tuxonice-kernel/compare/vanilla-${ICE_VER/KMV/$KMV}...tuxonice-${ICE_VER/KMV/$KMV}.diff"}}

	: ${ICE_URL:=${ICE_URL:-"http://tuxonice.net"}}

	: ${ICE_INF:=${ICE_INF:-"${YELLOW}TuxOnIce - ${ICE_URL}${NORMAL}"}}
}

geek-ice_init_variables

HOMEPAGE="${HOMEPAGE} ${ICE_URL}"

DEPEND="${DEPEND}
	ice?	( dev-vcs/git
		>=sys-apps/tuxonice-userui-1.0
		|| ( >=sys-power/hibernate-script-2.0 sys-power/pm-utils ) )"

#SRC_URI="${SRC_URI}
#	ice?	( ${ICE_SRC} )"

# @FUNCTION: src_unpack
# @USAGE:
# @DESCRIPTION: Extract source packages and do any necessary patching or fixes.
geek-ice_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	local CSD="${GEEK_STORE_DIR}/ice"
	local CWD="${T}/ice"
	shift
	test -d "${CWD}" >/dev/null 2>&1 && cd "${CWD}" || mkdir -p "${CWD}"; cd "${CWD}"
	dest="${CWD}"/tuxonice-kernel-"${PV}"-`date +"%Y%m%d"`.patch
	wget "${ICE_SRC}" -O "${dest}" > /dev/null 2>&1
	cd "${CWD}" || die "${RED}cd ${CWD} failed${NORMAL}"
	ls -1 | grep ".patch" | xargs -I{} xz "{}" | xargs -I{} cp "{}" "${CWD}"
	ls -1 "${CWD}" | grep ".patch.xz" > "${CWD}"/patch_list
}

# @FUNCTION: src_prepare
# @USAGE:
# @DESCRIPTION: Prepare source packages and do any necessary patching or fixes.
geek-ice_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

	ApplyPatch "${T}/ice/patch_list" "${ICE_INF}"
	mv "${T}/ice" "${WORKDIR}/linux-${KV_FULL}-patches/ice" || die "${RED}mv ${T}/ice ${WORKDIR}/linux-${KV_FULL}-patches/ice failed${NORMAL}"
#	rsync -avhW --no-compress --progress "${T}/ice/" "${WORKDIR}/linux-${KV_FULL}-patches/ice" || die "${RED}rsync -avhW --no-compress --progress ${T}/ice/ ${WORKDIR}/linux-${KV_FULL}-patches/ice failed${NORMAL}"
}

# @FUNCTION: pkg_postinst
# @USAGE:
# @DESCRIPTION: Called after image is installed to ${ROOT}
geek-ice_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

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
}
