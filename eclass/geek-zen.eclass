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
#  https://github.com/init6/init_6/blob/master/eclass/geek-zen.eclass
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
geek-zen_init_variables() {
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

	: ${ZEN_VER:=${ZEN_VER:-$KMV}}

	: ${ZEN_SRC:=${ZEN_SRC:-"https://github.com/damentz/zen-kernel/compare/torvalds:v${ZEN_VER/KMV/$KMV}...${ZEN_VER/KMV/$KMV}/master.diff"}}

	: ${ZEN_URL:=${ZEN_URL:-"https://github.com/damentz/zen-kernel"}}

	: ${ZEN_INF:=${ZEN_INF:-"${YELLOW}The Zen Kernel - ${ZEN_URL}${NORMAL}"}}
}

geek-zen_init_variables

HOMEPAGE="${HOMEPAGE} ${ZEN_URL}"

#SRC_URI="${SRC_URI}
#	zen?	( ${ZEN_SRC} )"

# @FUNCTION: src_unpack
# @USAGE:
# @DESCRIPTION: Extract source packages and do any necessary patching or fixes.
geek-zen_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	local CSD="${GEEK_STORE_DIR}/zen"
	local CWD="${T}/zen"
	local CTD="${T}/zen"$$
	shift
	test -d "${CWD}" >/dev/null 2>&1 && cd "${CWD}" || mkdir -p "${CWD}"; cd "${CWD}"
	dest="${CWD}"/zen-kernel-"${PV}"-`date +"%Y%m%d"`.patch
	wget "${ZEN_SRC}" -O "${dest}" > /dev/null 2>&1
	cd "${CWD}" || die "${RED}cd ${CWD} failed${NORMAL}"
	ls -1 | grep ".patch" | xargs -I{} xz "{}" | xargs -I{} cp "{}" "${CWD}"
	ls -1 "${CWD}" | grep ".patch.xz" > "${CWD}"/patch_list
}

# @FUNCTION: src_prepare
# @USAGE:
# @DESCRIPTION: Prepare source packages and do any necessary patching or fixes.
geek-zen_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

	ApplyPatch "${T}/zen/patch_list" "${ZEN_INF}"
	mv "${T}/zen" "${WORKDIR}/linux-${KV_FULL}-patches/zen" || die "${RED}mv ${T}/zen ${WORKDIR}/linux-${KV_FULL}-patches/zen failed${NORMAL}"
#	rsync -avhW --no-compress --progress "${T}/zen/" "${WORKDIR}/linux-${KV_FULL}-patches/zen" || die "${RED}rsync -avhW --no-compress --progress ${T}/zen/ ${WORKDIR}/linux-${KV_FULL}-patches/zen failed${NORMAL}"
}

# @FUNCTION: pkg_postinst
# @USAGE:
# @DESCRIPTION: Called after image is installed to ${ROOT}
geek-zen_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	einfo "${ZEN_INF}"
}
