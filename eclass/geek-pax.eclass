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
#  https://github.com/init6/init_6/blob/master/eclass/geek-aufs.eclass
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
geek-pax_init_variables() {
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

	: ${PAX_VER:=${PAX_VER:-$KMV}}

	: ${PAX_SRC:=${PAX_SRC:-"http://grsecurity.net/test/pax-linux-${PAX_VER/KMV/$KMV}.patch"}}

	: ${PAX_URL:=${PAX_URL:-"http://pax.grsecurity.net"}}

	: ${PAX_INF=${PAX_INF:-"${YELLOW}PAX patches - ${PAX_URL}${NORMAL}"}}

	: ${HOMEPAGE:="${HOMEPAGE} ${PAX_URL}"}

	: ${SRC_URI:="${SRC_URI}
		pax?( ${PAX_SRC} )"}
}

# @FUNCTION: src_prepare
# @USAGE:
# @DESCRIPTION: Prepare source packages and do any necessary patching or fixes.
geek-pax_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

	geek-pax_init_variables

	ApplyPatch "${PORTAGE_ACTUAL_DISTDIR:-${DISTDIR}}/pax-linux-${PAX_VER/KMV/$KMV}.patch" "${PAX_INF}"
}

# @FUNCTION: pkg_postinst
# @USAGE:
# @DESCRIPTION: Called after image is installed to ${ROOT}
geek-pax_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	einfo "${PAX_INF}"
}
