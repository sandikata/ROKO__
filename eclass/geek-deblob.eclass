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
#  https://github.com/init6/init_6/blob/master/eclass/geek-deblob.eclass
#
#  Bugs: https://github.com/init6/init_6/issues
#
#  Wiki: https://github.com/init6/init_6/wiki/geek-sources
#

EXPORT_FUNCTIONS src_unpack src_compile pkg_postinst

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

if [[ ${DEBLOB_AVAILABLE} == "1" ]]; then
	: ${IUSE:="${IUSE} deblob"}
	# Reflect that kernels contain firmware blobs unless otherwise
	# stripped
	: ${LICENSE:="${LICENSE} !deblob? ( freedist )"}

	if [[ -n PATCHLEVEL ]]; then
		DEBLOB_PV="${VERSION}.${PATCHLEVEL}.${SUBLEVEL}"
	else
		DEBLOB_PV="${VERSION}.${SUBLEVEL}"
	fi

	if [[ "${VERSION}" -ge 3 ]]; then
		DEBLOB_PV="${VERSION}.${PATCHLEVEL}"
	fi

	DEBLOB_A="deblob-${DEBLOB_PV}"
	DEBLOB_CHECK_A="deblob-check-${DEBLOB_PV}"
	DEBLOB_HOMEPAGE="http://www.fsfla.org/svnwiki/selibre/linux-libre/"
	DEBLOB_URI_PATH="download/releases/LATEST-${DEBLOB_PV}.N"
	if ! has "${EAPI:-0}" 0 1; then
		DEBLOB_CHECK_URI="${DEBLOB_HOMEPAGE}/${DEBLOB_URI_PATH}/deblob-check -> ${DEBLOB_CHECK_A}"
	else
		DEBLOB_CHECK_URI="mirror://gentoo/${DEBLOB_CHECK_A}"
	fi
	DEBLOB_URI="${DEBLOB_HOMEPAGE}/${DEBLOB_URI_PATH}/${DEBLOB_A}"
	: ${HOMEPAGE:="${HOMEPAGE} ${DEBLOB_HOMEPAGE}"}

	: ${SRC_URI:="${SRC_URI}
		deblob? (
			${DEBLOB_URI}
			${DEBLOB_CHECK_URI}
		)"}
else
	# We have no way to deblob older kernels, so just mark them as
	# tainted with non-libre materials.
	: ${LICENSE:="${LICENSE} freedist"}
fi

# @FUNCTION: src_unpack
# @USAGE:
# @DESCRIPTION: Extract source packages and do any necessary patching or fixes.
geek-deblob_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	if [[ $DEBLOB_AVAILABLE == 1 ]] && use deblob; then
		cp "${PORTAGE_ACTUAL_DISTDIR:-${DISTDIR}}/${DEBLOB_A}" "${T}" || die "${RED}cp ${DEBLOB_A} failed${NORMAL}"
		cp "${PORTAGE_ACTUAL_DISTDIR:-${DISTDIR}}/${DEBLOB_CHECK_A}" "${T}/deblob-check" || die "${RED}cp ${DEBLOB_CHECK_A} failed${NORMAL}"
		chmod +x "${T}/${DEBLOB_A}" "${T}/deblob-check" || die "${RED}chmod deblob scripts failed${NORMAL}"
	fi
}

# @FUNCTION: src_compile
# @USAGE:
# @DESCRIPTION: Configure and build the package.
geek-deblob_src_compile() {
	debug-print-function ${FUNCNAME} "$@"

	if [[ $DEBLOB_AVAILABLE == 1 ]] && use deblob; then
		echo ">>> Running deblob script ..."
		sh "${T}/${DEBLOB_A}" --force || \
			die "${RED}Deblob script failed to run!!!${NORMAL}"
	fi
}

# @FUNCTION: pkg_postinst
# @USAGE:
# @DESCRIPTION: Called after image is installed to ${ROOT}
geek-deblob_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	einfo " ${BLUE}Deblobbed kernels are UNSUPPORTED by Gentoo Security.${NORMAL}"
}
