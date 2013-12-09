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
#  https://github.com/init6/init_6/blob/master/eclass/geek-xenomai.eclass
#
#  Bugs: https://github.com/init6/init_6/issues
#
#  Wiki: https://github.com/init6/init_6/wiki/geek-sources
#

# https://bugs.gentoo.org/show_bug.cgi?id=438236

inherit geek-patch geek-utils

EXPORT_FUNCTIONS src_unpack src_prepare pkg_postinst

# @FUNCTION: init_variables
# @INTERNAL
# @DESCRIPTION:
# Internal function initializing all variables.
# We define it in function scope so user can define
# all the variables before and after inherit.
geek-xenomai_init_variables() {
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

	: ${XENOMAI_VER:=${XENOMAI_VER:-"2.6.3"}}

	: ${XENOMAI_NAME:=${XENOMAI_NAME:-xenomai-${XENOMAI_VER}.tar.bz2}}

	: ${XENOMAI_SRC:=${XENOMAI_SRC:-"http://download.gna.org/xenomai/stable/${XENOMAI_NAME}"}}

	: ${XENOMAI_URL:=${XENOMAI_URL:-"http://www.xenomai.org"}}

	: ${XENOMAI_INF:="${YELLOW}Real-Time Framework for Linux - ${XENOMAI_URL}${NORMAL}"}

	: ${ADEOS_VER:=${ADEOS_VER:-"2.6.38.8-x86-2.11-03"}}

	: ${ADEOS_NAME:=${ADEOS_NAME:-adeos-ipipe-${ADEOS_VER}.patch}}

	: ${ADEOS_SRC:=${ADEOS_SRC:-"http://download.gna.org/adeos/patches/v2.6/x86/${ADEOS_NAME}"}}

	: ${ADEOS_URL:=${ADEOS_URL:-"http://gna.org/projects/adeos"}}

	: ${ADEOS_INF:="${YELLOW}Interrupt pipeline patches for the Linux kernel - ${ADEOS_URL}${NORMAL}"}
}

geek-xenomai_init_variables

HOMEPAGE="${HOMEPAGE} ${XENOMAI_URL} ${ADEOS_URL}"

SRC_URI="${SRC_URI}
	xenomai?	( ${XENOMAI_SRC} ${ADEOS_SRC} )"

# @FUNCTION: src_unpack
# @USAGE:
# @DESCRIPTION: Extract source packages and do any necessary patching or fixes.
geek-xenomai_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	local CWD="${T}/xenomai"
	shift
	test -d "${CWD}" >/dev/null 2>&1 && cd "${CWD}" || mkdir -p "${CWD}"; cd "${CWD}"

	unpack ${XENOMAI_NAME} || die "unpack failed"
	cd ${CWD}/xenomai-${XENOMAI_VER}
}

# @FUNCTION: src_prepare
# @USAGE:
# @DESCRIPTION: Prepare source packages and do any necessary patching or fixes.
geek-xenomai_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

#	ApplyPatch "${FILESDIR}/prepare-kernel.patch" "${XENOMAI_INF}" || die "patch failed"

	einfo "${ADEOS_INF}\n${XENOMAI_INF}"
	"${T}/xenomai/xenomai-${XENOMAI_VER}/"scripts/prepare-kernel.sh --linux=${S} --adeos=${DISTDIR}/${ADEOS_NAME} --default || die "prepare kernel failed"

#	cd ${S}
#	ApplyPatch ${FILESDIR}/discontinued_latency_watchdog.patch || die "patch failed"

#	mv "${T}/xenomai" "${WORKDIR}/linux-${KV_FULL}-patches/xenomai" || die "${RED}mv ${T}/xenomai ${WORKDIR}/linux-${KV_FULL}-patches/xenomai failed${NORMAL}"
#	rsync -avhW --no-compress --progress "${T}/xenomai/" "${WORKDIR}/linux-${KV_FULL}-patches/xenomai" || die "${RED}rsync -avhW --no-compress --progress ${T}/xenomai/ ${WORKDIR}/linux-${KV_FULL}-patches/xenomai failed${NORMAL}"

	rm -rf "${T}/xenomai" || die "${RED}rm -rf ${T}/xenomai failed${NORMAL}"
}

# @FUNCTION: pkg_postinst
# @USAGE:
# @DESCRIPTION: Called after image is installed to ${ROOT}
geek-xenomai_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	einfo "${XENOMAI_INF} ${ADEOS_INF}"
}
