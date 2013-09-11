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
#  https://github.com/init6/init_6/blob/master/eclass/geek-suse.eclass
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
geek-suse_init_variables() {
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

	: ${SUSE_VER:=${SUSE_VER:-stable}}

	: ${SUSE_SRC:=${SUSE_SRC:-"git://kernel.opensuse.org/kernel-source.git"}}

	: ${SUSE_URL:=${SUSE_URL:-"http://www.opensuse.org"}}

	: ${SUSE_INF:=${SUSE_INF:-"${YELLOW}OpenSuSE - ${SUSE_URL}${NORMAL}"}}

	: ${HOMEPAGE:="${HOMEPAGE} ${SUSE_URL}"}
}

# @FUNCTION: src_unpack
# @USAGE:
# @DESCRIPTION: Extract source packages and do any necessary patching or fixes.
geek-suse_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	geek-suse_init_variables

	local CSD="${GEEK_STORE_DIR}/suse"
	local CWD="${T}/suse"
	local CTD="${T}/suse"$$
	shift
	cd "${CSD}" >/dev/null 2>&1
	test -d "${CWD}" >/dev/null 2>&1 || mkdir -p "${CWD}"
	if [ -d ${CSD} ]; then
	cd "${CSD}" || die "${RED}cd ${CSD} failed${NORMAL}"
		if [ -e ".git" ]; then # git
			git fetch --all && git pull --all
		fi
	else
		git clone "${SUSE_SRC}" "${CSD}" > /dev/null 2>&1; cd "${CSD}" || die "${RED}cd ${CSD} failed${NORMAL}"; git_get_all_branches
	fi

	cp -r "${CSD}" "${CTD}" || die "${RED}cp -r ${CSD} ${CTD} failed${NORMAL}"

	cd "${CTD}" || die "${RED}cd ${CTD} failed${NORMAL}"

	git_checkout "${SUSE_VER}" > /dev/null 2>&1 git pull > /dev/null 2>&1

	[ -e "patches.kernel.org" ] && rm -rf patches.kernel.org > /dev/null 2>&1
	[ -e "patches.rpmify" ] && rm -rf patches.rpmify > /dev/null 2>&1

	awk '!/(#|^$)/ && !/^(\+(needs|tren|hare|xen|jbeulich|jeffm))|patches\.(kernel|rpmify|xen).*/{gsub(/[ \t]/,"") ; print $1}' series.conf > patch_list
	grep patches.xen series.conf > spatch_list

	cp -r patches.*/ "${CWD}" || die "${RED}cp -r patches.*/ ${CWD} failed${NORMAL}"
	cp patch_list "${CWD}" || die "${RED}cp patch_list ${CWD} failed${NORMAL}"
	cp spatch_list "${CWD}" || die "${RED}cp spatch_list ${CWD} failed${NORMAL}"

	rm -rf "${CTD}" || die "${RED}rm -rf ${CTD} failed${NORMAL}"
}

# @FUNCTION: src_prepare
# @USAGE:
# @DESCRIPTION: Prepare source packages and do any necessary patching or fixes.
geek-suse_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

	ApplyPatch "${T}/suse/patch_list" "${SUSE_INF}"
	SmartApplyPatch "${T}/suse/spatch_list" "${YELLOW}OpenSuSE xen - ${SUSE_URL}${NORMAL}"
	mv "${T}/suse" "${S}/patches/suse" || die "${RED}mv ${T}/suse ${S}/patches/suse failed${NORMAL}"
}

# @FUNCTION: pkg_postinst
# @USAGE:
# @DESCRIPTION: Called after image is installed to ${ROOT}
geek-suse_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	einfo "${SUSE_INF}"
}
