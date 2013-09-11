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
#  https://github.com/init6/init_6/blob/master/eclass/geek-fedora.eclass
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
geek-fedora_init_variables() {
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

	: ${FEDORA_VER:=${FEDORA_VER:-f19}}

	: ${FEDORA_SRC:=${FEDORA_SRC:-"git://pkgs.fedoraproject.org/kernel.git"}}

	: ${FEDORA_URL:=${FEDORA_URL:-"http://fedoraproject.org"}}

	: ${FEDORA_INF:=${FEDORA_INF:-"${YELLOW}Fedora - ${FEDORA_URL}${NORMAL}"}}

	: ${HOMEPAGE:="${HOMEPAGE} ${FEDORA_URL}"}
}

# @FUNCTION: src_unpack
# @USAGE:
# @DESCRIPTION: Extract source packages and do any necessary patching or fixes.
geek-fedora_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	geek-fedora_init_variables

	local CSD="${GEEK_STORE_DIR}/fedora"
	local CWD="${T}/fedora"
	local CTD="${T}/fedora"$$
	shift
	cd "${CSD}" >/dev/null 2>&1
	test -d "${CWD}" >/dev/null 2>&1 || mkdir -p "${CWD}"
	if [ -d ${CSD} ]; then
		cd "${CSD}" || die "${RED}cd ${CSD} failed${NORMAL}"
		if [ -e ".git" ]; then # git
			git fetch --all && git pull --all
		fi
	else
		git clone "${FEDORA_SRC}" "${CSD}" > /dev/null 2>&1; cd "${CSD}" || die "${RED}cd ${CSD} failed${NORMAL}"; git_get_all_branches
	fi

	cp -r "${CSD}" "${CTD}" || die "${RED}cp -r ${CSD} ${CTD} failed${NORMAL}"
	cd "${CTD}" || die "${RED}cd ${CTD} failed${NORMAL}"

	git_checkout "${FEDORA_VER}" > /dev/null 2>&1 git pull > /dev/null 2>&1

	ls -1 | grep ".patch" | xargs -I{} cp "{}" "${CWD}"

	awk '/^Apply.*Patch.*\.patch/{print $2}' kernel.spec > "$CWD"/patch_list

	rm -rf "${CTD}" || die "${RED}rm -rf ${CTD} failed${NORMAL}"
}

# @FUNCTION: src_prepare
# @USAGE:
# @DESCRIPTION: Prepare source packages and do any necessary patching or fixes.
geek-fedora_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

	ApplyPatch "${T}/fedora/patch_list" "${FEDORA_INF}"
	mv "${T}/fedora" "${S}/patches/fedora" || die "${RED}mv ${T}/fedora ${S}/patches/fedora failed${NORMAL}"
}

# @FUNCTION: pkg_postinst
# @USAGE:
# @DESCRIPTION: Called after image is installed to ${ROOT}
geek-fedora_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	einfo "${FEDORA_INF}"
}
