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
#  https://github.com/init6/init_6/blob/master/eclass/geek-exfat.eclass
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
geek-exfat_init_variables() {
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

	: ${EXFAT_VER:=${EXFAT_VER:-$KMV}}

	: ${EXFAT_SRC:=${EXFAT_SRC:-"https://github.com/damentz/zen-kernel/compare/torvalds:v${EXFAT_VER/KMV/$KMV}...${EXFAT_VER/KMV/$KMV}/exfat.diff"}}

	: ${EXFAT_URL:=${EXFAT_URL:-"http://opensource.samsung.com/reception/receptionSub.do?method=search&searchValue=exfat"}}

	: ${EXFAT_INF:=${EXFAT_INF:-"${YELLOW}Samsung’s exFAT fs Linux driver - ${EXFAT_URL}${NORMAL}"}}
}

geek-exfat_init_variables

HOMEPAGE="${HOMEPAGE} ${EXFAT_URL}"

#SRC_URI="${SRC_URI}
#	exfat?	( ${EXFAT_SRC} )"

# @FUNCTION: src_unpack
# @USAGE:
# @DESCRIPTION: Extract source packages and do any necessary patching or fixes.
geek-exfat_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	local CSD="${GEEK_STORE_DIR}/exfat"
	local CWD="${T}/exfat"
	local CTD="${T}/exfat"$$
	shift
	test -d "${CWD}" >/dev/null 2>&1 && cd "${CWD}" || mkdir -p "${CWD}"; cd "${CWD}"
	dest="${CWD}"/exfat-"${PV}"-`date +"%Y%m%d"`.patch
	wget "${EXFAT_SRC}" -O "${dest}" > /dev/null 2>&1
	cd "${CWD}" || die "${RED}cd ${CWD} failed${NORMAL}"
	ls -1 | grep ".patch" | xargs -I{} xz "{}" | xargs -I{} cp "{}" "${CWD}"
	ls -1 "${CWD}" | grep ".patch.xz" > "${CWD}"/patch_list
}

# @FUNCTION: src_prepare
# @USAGE:
# @DESCRIPTION: Prepare source packages and do any necessary patching or fixes.
geek-exfat_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

	ApplyPatch "${T}/exfat/patch_list" "${EXFAT_INF}"
	mv "${T}/exfat" "${WORKDIR}/linux-${KV_FULL}-patches/exfat" || die "${RED}mv ${T}/exfat ${WORKDIR}/linux-${KV_FULL}-patches/exfat failed${NORMAL}"
#	rsync -avhW --no-compress --progress "${T}/exfat/" "${WORKDIR}/linux-${KV_FULL}-patches/exfat" || die "${RED}rsync -avhW --no-compress --progress ${T}/exfat/ ${WORKDIR}/linux-${KV_FULL}-patches/exfat failed${NORMAL}"
}

# @FUNCTION: pkg_postinst
# @USAGE:
# @DESCRIPTION: Called after image is installed to ${ROOT}
geek-exfat_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	einfo "${EXFAT_INF}"
}
