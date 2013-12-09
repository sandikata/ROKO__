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
#  https://github.com/init6/init_6/blob/master/eclass/geek-reiser4.eclass
#
#  Bugs: https://github.com/init6/init_6/issues
#
#  Wiki: https://github.com/init6/init_6/wiki/geek-sources
#

inherit geek-patch geek-utils

EXPORT_FUNCTIONS src_prepare pkg_postinst

# @FUNCTION: init_variables
# @INTERNAL
# @DESCRIPTION:
# Internal function initializing all variables.
# We define it in function scope so user can define
# all the variables before and after inherit.
geek-reiser4_init_variables() {
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

	: ${REISER4_VER:=${REISER4_VER:-$KMV}}

	: ${REISER4_SRC:=${REISER4_SRC:-"mirror://sourceforge/project/reiser4/reiser4-for-linux-3.x/reiser4-for-${REISER4_VER/PV/$PV}.patch.gz"}}

	: ${REISER4_URL:=${REISER4_URL:-"http://sourceforge.net/projects/reiser4"}}

	: ${REISER4_INF:=${REISER4_INF:-"${YELLOW}ReiserFS v4 - ${REISER4_URL}${NORMAL}"}}
}

geek-reiser4_init_variables

HOMEPAGE="${HOMEPAGE} ${REISER4_URL}"

DEPEND="${RDEPEND}
	>=sys-fs/reiser4progs-1.0.6"

SRC_URI="${SRC_URI}
	reiser4?	( ${REISER4_SRC} )"

# @FUNCTION: src_prepare
# @USAGE:
# @DESCRIPTION: Prepare source packages and do any necessary patching or fixes.
geek-reiser4_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

	ApplyPatch "${PORTAGE_ACTUAL_DISTDIR:-${DISTDIR}}/reiser4-for-${REISER4_VER}.patch.gz" "${REISER4_INF}"
}


# @FUNCTION: pkg_postinst
# @USAGE:
# @DESCRIPTION: Called after image is installed to ${ROOT}
geek-reiser4_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	if ! has_version sys-fs/reiser4progs; then
		ewarn
		ewarn "${BLUE}In order to use Reiser4 FS you need to install${NORMAL} ${RED}sys-fs/reiser4progs${NORMAL}"
		ewarn
	fi
}
