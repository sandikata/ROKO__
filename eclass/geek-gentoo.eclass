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
#  https://github.com/init6/init_6/blob/master/eclass/geek-gentoo.eclass
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
geek-gentoo_init_variables() {
	debug-print-function ${FUNCNAME} "$@"

	: ${GEEK_STORE_DIR:=${GEEK_STORE_DIR:-"${PORTAGE_ACTUAL_DISTDIR:-${DISTDIR}}/geek"}}
	# Disable the sandbox for this dir
	addwrite "${GEEK_STORE_DIR}"

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

	: ${GENTOO_VER:=${GENTOO_VER:-$KMV}}

	: ${GENTOO_SRC:=${GENTOO_SRC:-"svn://anonsvn.gentoo.org/linux-patches/genpatches-2.6/trunk"}}

	: ${GENTOO_URL:=${GENTOO_URL:-"http://dev.gentoo.org/~mpagano/genpatches"}}

	: ${GENTOO_INF:=${GENTOO_INF:-"${YELLOW}Gentoo patches - ${GENTOO_URL}${NORMAL}"}}

	: ${HOMEPAGE:="${HOMEPAGE} ${GENTOO_URL}"}
}

# @FUNCTION: src_unpack
# @USAGE:
# @DESCRIPTION: Extract source packages and do any necessary patching or fixes.
geek-gentoo_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	geek-gentoo_init_variables

	local CSD="${GEEK_STORE_DIR}/gentoo"
	local CWD="${T}/gentoo"
	local CTD="${T}/gentoo"$$
	shift
	test -d "${CWD}" >/dev/null 2>&1 || mkdir -p "${CWD}"
	if [ -d ${CSD} ]; then
		cd "${CSD}" || die "${RED}cd ${CSD} failed${NORMAL}"
		if [ -e ".svn" ]; then # git
			svn up
		fi
	else
		svn co "${GENTOO_SRC}" "${CSD}" > /dev/null 2>&1
	fi

	cp -r "${CSD}" "${CTD}" || die "${RED}cp -r ${CSD} ${CTD} failed${NORMAL}"
	cd "${CTD}"/${KMV} || die "${RED}cd ${CTD}/${KMV} failed${NORMAL}"

	find -name .svn -type d -exec rm -rf {} \ > /dev/null 2>&1
	find -type d -empty -delete

	ls -1 | grep "linux" | xargs -I{} rm -rf "{}"
	ls -1 | grep ".patch" > "$CWD"/patch_list

	cp -r "${CTD}"/${KMV}/* "${CWD}" || die "${RED}cp -r ${CTD}/${KMV}/* ${CWD} failed${NORMAL}"

	rm -rf "${CTD}" || die "${RED}rm -rf ${CTD} failed${NORMAL}"
}

# @FUNCTION: src_prepare
# @USAGE:
# @DESCRIPTION: Prepare source packages and do any necessary patching or fixes.
geek-gentoo_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

	ApplyPatch "${T}/gentoo/patch_list" "${GENTOO_INF}"
	mv "${T}/gentoo" "${S}/patches/gentoo" || die "${RED}mv ${T}/gentoo ${S}/patches/gentoo failed${NORMAL}"
}

# @FUNCTION: pkg_postinst
# @USAGE:
# @DESCRIPTION: Called after image is installed to ${ROOT}
geek-gentoo_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	einfo "${GENTOO_INF}"
}
