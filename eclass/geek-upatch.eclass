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
#  https://github.com/init6/init_6/blob/master/eclass/geek-upatch.eclass
#
#  Bugs: https://github.com/init6/init_6/issues
#
#  Wiki: https://github.com/init6/init_6/wiki/geek-sources
#

inherit geek-patch

EXPORT_FUNCTIONS src_prepare

# @FUNCTION: init_variables
# @INTERNAL
# @DESCRIPTION:
# Internal function initializing all variables.
# We define it in function scope so user can define
# all the variables before and after inherit.
geek-upatch_init_variables() {
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

	: ${PATCH_USER_DIR:=${PATCH_USER_DIR:-"/etc/portage/patches/sys-kernel/${PN}"}}
}

geek-upatch_init_variables

# @FUNCTION: src_prepare
# @USAGE:
# @DESCRIPTION: Prepare source packages and do any necessary patching or fixes.
geek-upatch_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

	if [ -d "${PATCH_USER_DIR}" ]; then
		if [ -e "${PATCH_USER_DIR}/patch_list" ]; then
			ApplyPatch "${PATCH_USER_DIR}/patch_list" "${YELLOW}Applying user patches from${NORMAL} ${RED}${PATCH_USER_DIR}${NORMAL}"
		else
			ewarn "${BLUE}File${NORMAL} ${RED}${PATCH_USER_DIR}/patch_list${NORMAL} ${BLUE}not found!${NORMAL}"
			ewarn "${BLUE}Try to apply the patches if they are there…${NORMAL}"
			for i in `ls ${PATCH_USER_DIR}/*.{patch,gz,bz,bz2,lrz,xz,zip,Z} 2> /dev/null`; do
				ApplyPatch "${i}" "${YELLOW}Applying user patches from${NORMAL} ${RED}${PATCH_USER_DIR}${NORMAL}"
			done
		fi
	fi
}
