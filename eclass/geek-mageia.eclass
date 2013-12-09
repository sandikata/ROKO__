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
#  https://github.com/init6/init_6/blob/master/eclass/geek-mageia.eclass
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
geek-mageia_init_variables() {
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

	: ${MAGEIA_VER:=${MAGEIA_VER:-$KMV}}

	: ${MAGEIA_SRC:=${MAGEIA_SRC:-"svn://svn.mageia.org/svn/packages/cauldron/kernel"}}

	: ${MAGEIA_URL:=${MAGEIA_URL:-"http://www.mageia.org"}}

	: ${MAGEIA_INF:=${MAGEIA_INF:-"${YELLOW}Mageia - ${MAGEIA_URL}${NORMAL}"}}
}

geek-mageia_init_variables

HOMEPAGE="${HOMEPAGE} ${MAGEIA_URL}"

DEPEND="${DEPEND}
	mageia?	( dev-vcs/subversion )"

# @FUNCTION: src_unpack
# @USAGE:
# @DESCRIPTION: Extract source packages and do any necessary patching or fixes.
geek-mageia_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	local CSD="${GEEK_STORE_DIR}/mageia"
	local CWD="${T}/mageia"
	local CTD="${T}/mageia"$$
	shift
	test -d "${CWD}" >/dev/null 2>&1 && cd "${CWD}" || mkdir -p "${CWD}"; cd "${CWD}"
	if [ -d ${CSD} ]; then
	cd "${CSD}" || die "${RED}cd ${CSD} failed${NORMAL}"
		if [ -e ".svn" ]; then # subversion
			svn up
		fi
	else
		svn co "${MAGEIA_SRC}" "${CSD}" > /dev/null 2>&1
	fi

#	cp -r "${CSD}" "${CTD}" || die "${RED}cp -r ${CSD} ${CTD} failed${NORMAL}"
#	rsync -avhW --no-compress --progress "${CSD}/" "${CTD}" || die "${RED}rsync -avhW --no-compress --progress ${CSD}/ ${CTD} failed${NORMAL}"
	test -d "${CTD}" >/dev/null 2>&1 || mkdir -p "${CTD}"; (cd "${CSD}"; tar cf - .) | (cd "${CTD}"; tar xpf -)
	cd "${CTD}"/"${MAGEIA_VER}"/PATCHES || die "${RED}cd ${CTD}/${MAGEIA_VER}/PATCHES failed${NORMAL}"

	find . -name "*.patch" | xargs -i cp "{}" "${CWD}"

	awk '{gsub(/3rd/,"#3rd") ;print $0}' patches/series > "${CWD}"/patch_list

	rm -rf "${CTD}" || die "${RED}rm -rf ${CTD} failed${NORMAL}"
}

# @FUNCTION: src_prepare
# @USAGE:
# @DESCRIPTION: Prepare source packages and do any necessary patching or fixes.
geek-mageia_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

	ApplyPatch "${T}/mageia/patch_list" "${MAGEIA_INF}"
	mv "${T}/mageia" "${WORKDIR}/linux-${KV_FULL}-patches/mageia" || die "${RED}mv ${T}/mageia ${WORKDIR}/linux-${KV_FULL}-patches/mageia failed${NORMAL}"
#	rsync -avhW --no-compress --progress "${T}/mageia/" "${WORKDIR}/linux-${KV_FULL}-patches/mageia" || die "${RED}rsync -avhW --no-compress --progress ${T}/mageia/ ${WORKDIR}/linux-${KV_FULL}-patches/mageia failed${NORMAL}"
}

# @FUNCTION: pkg_postinst
# @USAGE:
# @DESCRIPTION: Called after image is installed to ${ROOT}
geek-mageia_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	einfo "${MAGEIA_INF}"
}
