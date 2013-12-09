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
#  https://github.com/init6/init_6/blob/master/eclass/geek-brand.eclass
#
#  Bugs: https://github.com/init6/init_6/issues
#
#  Wiki: https://github.com/init6/init_6/wiki/geek-sources
#

inherit geek-patch

EXPORT_FUNCTIONS src_prepare pkg_postinst

# @FUNCTION: init_variables
# @INTERNAL
# @DESCRIPTION:
# Internal function initializing all variables.
# We define it in function scope so user can define
# all the variables before and after inherit.
geek-brand_init_variables() {
	debug-print-function ${FUNCNAME} "$@"

	: ${IUSE:="${IUSE} brand"}

	: ${BRAND_URL:=${BRAND_URL:-"https://github.com/init6/init_6/wiki/geek-sources"}}

	: ${BRAND_INF:=${BRAND_INF:-"${YELLOW}Branding - ${BRAND_URL}${NORMAL}"}}
}

geek-brand_init_variables

HOMEPAGE="${HOMEPAGE} ${BRAND_URL}"

# @FUNCTION: src_prepare
# @USAGE:
# @DESCRIPTION: Prepare source packages and do any necessary patching or fixes.
geek-brand_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

	ApplyPatch "${FILESDIR}/${PV}/brand/patch_list" "${BRAND_INF}"
}

# @FUNCTION: pkg_postinst
# @USAGE:
# @DESCRIPTION: Called after image is installed to ${ROOT}
geek-brand_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	einfo "${BRAND_INF}"
}
