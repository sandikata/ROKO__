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
#  https://github.com/init6/init_6/blob/master/eclass/geek-squeue.eclass
#
#  Bugs: https://github.com/init6/init_6/issues
#
#  Wiki: https://github.com/init6/init_6/wiki/geek-sources
#

inherit geek-patch

EXPORT_FUNCTIONS src_unpack src_prepare pkg_postinst

# @FUNCTION: init_variables
# @INTERNAL
# @DESCRIPTION:
# Internal function initializing all variables.
# We define it in function scope so user can define
# all the variables before and after inherit.
geek-squeue_init_variables() {
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

	: ${GEEK_STORE_DIR:=${GEEK_STORE_DIR:-"${PORTAGE_ACTUAL_DISTDIR:-${DISTDIR}}/geek"}}
	addwrite "${GEEK_STORE_DIR}" # Disable the sandbox for this dir

	: ${SQUEUE_VER:=${SQUEUE_VER:-"${KMV}"}}

	: ${SQUEUE_SRC:=${SQUEUE_SRC:-"git://git.kernel.org/pub/scm/linux/kernel/git/stable/stable-queue.git"}}

	: ${SQUEUE_URL:=${SQUEUE_URL:-"http://git.kernel.org/scm/linux/kernel/git/stable/stable-queue.git"}}

	: ${SQUEUE_INF:=${SQUEUE_INF:-"${YELLOW}Stable-queue patch-set - ${SQUEUE_URL}${NORMAL}"}}

	: ${HOMEPAGE:="${HOMEPAGE} ${SQUEUE_URL}"}

	: ${cfg_file:="/etc/portage/kernel.conf"}

	local skip_squeue_cfg=$(source $cfg_file 2>/dev/null; echo ${skip_squeue})
	: ${skip_squeue:=${skip_squeue_cfg:-no}} # skip_squeue=yes/no
	einfo "${BLUE}Skip stable-queue -->${NORMAL} ${RED}$skip_squeue${NORMAL}"
}

# @FUNCTION: src_unpack
# @USAGE:
# @DESCRIPTION: Extract source packages and do any necessary patching or fixes.
geek-squeue_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	geek-squeue_init_variables

	local CSD="${GEEK_STORE_DIR}/squeue"
	local CWD="${T}/squeue"

	if [ -d ${CSD} ]; then
		cd ${CSD} || die "${RED}cd ${CSD} failed${NORMAL}"
		git pull > /dev/null 2>&1
#		cd "${S}" || die "${RED}cd ${S} failed${NORMAL}"
	else
		git clone ${SQUEUE_SRC} ${CSD} > /dev/null 2>&1
	fi

#	test -d "${CWD}" >/dev/null 2>&1 || mkdir -p "${CWD}"

	if [ -d ${CSD}/queue-${SQUEUE_VER} ] ; then
		cp -r "${CSD}/queue-${SQUEUE_VER}" "${CWD}" #|| die "${RED}cp -r ${CSD}/queue-${SQUEUE_VER} ${CWD} failed${NORMAL}"
		mv "${CWD}/series" "${CWD}/patch_list" #|| die "${RED}mv ${CWD}/series ${CWD}/patch_list failed${NORMAL}"
	elif [ -d ${CSD}/releases/${PV} ]; then
		cp -r "${CSD}/releases/${PV}" "${CWD}" #|| die "${RED}cp -r ${CSD}/releases/${PV} ${CWD} failed${NORMAL}"
		mv "${CWD}/series" "${CWD}/patch_list" #|| die "${RED}mv ${CWD}/series ${CWD}/patch_list failed${NORMAL}"
	else
		ewarn "There is no stable-queue patch-set this time"
	fi
}

# @FUNCTION: src_prepare
# @USAGE:
# @DESCRIPTION: Prepare source packages and do any necessary patching or fixes.
geek-squeue_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

	if [ "${skip_squeue}" = "yes" ]; then
			ewarn "${RED}Skipping update to latest stable queue ...${NORMAL}"
		else
			ApplyPatch "${T}/squeue/patch_list" "${SQUEUE_INF}"
			mv "${T}/squeue" "${S}/patches/squeue" || die "${RED}mv ${T}/squeue ${S}/patches/squeue failed${NORMAL}"
	fi
}

# @FUNCTION: pkg_postinst
# @USAGE:
# @DESCRIPTION: Called after image is installed to ${ROOT}
geek-squeue_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	einfo "${SQUEUE_INF}"
}
