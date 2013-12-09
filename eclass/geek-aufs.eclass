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

EXPORT_FUNCTIONS src_unpack src_prepare pkg_postinst

# @FUNCTION: init_variables
# @INTERNAL
# @DESCRIPTION:
# Internal function initializing all variables.
# We define it in function scope so user can define
# all the variables before and after inherit.
geek-aufs_init_variables() {
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

	: ${AUFS_VER:=${AUFS_VER:-"${KMV}"}}

	: ${AUFS_SRC:=${AUFS_SRC:-"git://git.code.sf.net/p/aufs/aufs3-standalone"}}

	: ${AUFS_URL:=${AUFS_URL:-"http://aufs.sourceforge.net"}}

	: ${AUFS_INF:="${YELLOW}Another UnionFS - ${AUFS_URL}${NORMAL}"}
}

geek-aufs_init_variables

HOMEPAGE="${HOMEPAGE} ${AUFS_URL}"

DEPEND="${DEPEND}
	aufs?	( dev-vcs/git
		sys-fs/aufs-util
		sys-fs/squashfs-tools )"

# @FUNCTION: src_unpack
# @USAGE:
# @DESCRIPTION: Extract source packages and do any necessary patching or fixes.
geek-aufs_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	local CSD="${GEEK_STORE_DIR}/aufs"
	local CWD="${T}/aufs"
	local CTD="${T}/aufs"$$
	shift
	test -d "${CWD}" >/dev/null 2>&1 && cd "${CWD}" || mkdir -p "${CWD}"; cd "${CWD}"
	if [ -d "${CSD}" ]; then
		cd "${CSD}"
		if [ -e ".git" ]; then # git
			git fetch --all && git pull --all
		fi
	else
		git clone "${AUFS_SRC}" "${CSD}"
		cd "${CSD}"
		git_get_all_branches
	fi

#	cp -r "${CSD}" "${CTD}" || die "${RED}cp -r ${CSD} ${CTD} failed${NORMAL}"
#	rsync -avhW --no-compress --progress "${CSD}/" "${CTD}" || die "${RED}rsync -avhW --no-compress --progress ${CSD}/ ${CTD} failed${NORMAL}"
	test -d "${CTD}" >/dev/null 2>&1 || mkdir -p "${CTD}"; (cd "${CSD}"; tar cf - .) | (cd "${CTD}"; tar xpf -)
	cd "${CTD}"

	dir=( "Documentation" "fs" "include" )
	local dest="${CWD}"/aufs3-${AUFS_VER}-`date +"%Y%m%d"`.patch

	git_checkout "origin/aufs${AUFS_VER}" > /dev/null 2>&1 git pull > /dev/null 2>&1

	mkdir ../a ../b || die "${RED}mkdir ../a ../b failed${NORMAL}"
	cp -r {Documentation,fs,include} ../b || die "${RED}cp -r {Documentation,fs,include} ../b failed${NORMAL}"
	if [ ${KMV} == "3.0" -o ${KMV} == "3.2" -o ${KMV} == "3.4" ]; then
		rm ../b/include/linux/Kbuild || die "${RED}rm ../b/include/linux/Kbuild failed${NORMAL}"
	else
		rm ../b/include/uapi/linux/Kbuild || die "${RED}rm ../b/include/uapi/linux/Kbuild failed${NORMAL}"
	fi
	cd .. || die "${RED}cd .. failed${NORMAL}"

	for i in "${dir[@]}"; do
		diff -U 3 -dHrN -- a/ b/"${i}"/ >> "${dest}"
		sed -i "s:a/:a/"${i}"/:" "${dest}"
		sed -i "s:b:b:" "${dest}"
	done
	rm -rf a b || die "${RED}rm -rf a b failed${NORMAL}"

	[[ -r "${CTD}/aufs3-base.patch" ]] && (cp "${CTD}"/aufs3-base.patch "${CWD}"/aufs3-base-${AUFS_VER}-`date +"%Y%m%d"`.patch || die "${RED}cp ${CTD}/aufs3-base.patch ${CWD}/aufs3-base-${aufs_ver}-`date +"%Y%m%d"`.patch failed${NORMAL}")
	[[ -r "${CTD}/aufs3-standalone.patch" ]] && (cp "${CTD}"/aufs3-standalone.patch "${CWD}"/aufs3-standalone-${AUFS_VER}-`date +"%Y%m%d"`.patch || die "${RED}cp ${CTD}/aufs3-standalone.patch ${CWD}/aufs3-standalone-${aufs_ver}-`date +"%Y%m%d"`.patch failed${NORMAL}")
	[[ -r "${CTD}/aufs3-kbuild.patch" ]] && (cp "${CTD}"/aufs3-kbuild.patch "${CWD}"/aufs3-kbuild-${AUFS_VER}-`date +"%Y%m%d"`.patch || die "${RED}cp ${CTD}/aufs3-kbuild.patch ${CWD}/aufs3-kbuild-${aufs_ver}-`date +"%Y%m%d"`.patch failed${NORMAL}")
	[[ -r "${CTD}/aufs3-proc_map.patch" ]] && (cp "${CTD}"/aufs3-proc_map.patch "${CWD}"/aufs3-proc_map-${AUFS_VER}-`date +"%Y%m%d"`.patch || die "${RED}cp ${CTD}/aufs3-proc_map.patch ${CWD}/aufs3-proc_map-${aufs_ver}-`date +"%Y%m%d"`.patch failed${NORMAL}")
	[[ -r "${CTD}/aufs3-mmap.patch" ]] && (cp "${CTD}"/aufs3-mmap.patch "${CWD}"/aufs3-mmap-${AUFS_VER}-`date +"%Y%m%d"`.patch || die "${RED}cp ${CTD}/aufs3-mmap.patch ${CWD}/aufs3-mmap-${aufs_ver}-`date +"%Y%m%d"`.patch failed${NORMAL}")
	[[ -r "${CTD}/aufs3-loopback.patch" ]] && (cp "${CTD}"/aufs3-loopback.patch "${CWD}"/aufs3-loopback-${AUFS_VER}-`date +"%Y%m%d"`.patch || die "${RED}cp ${CTD}/aufs3-loopback.patch ${CWD}/aufs3-loopback-${aufs_ver}-`date +"%Y%m%d"`.patch failed${NORMAL}")

	rm -rf "${CTD}" || die "${RED}rm -rf ${CTD} failed${NORMAL}"

	ls -1 "${CWD}" | grep ".patch" > "${CWD}"/patch_list
}

# @FUNCTION: src_prepare
# @USAGE:
# @DESCRIPTION: Prepare source packages and do any necessary patching or fixes.
geek-aufs_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

	ApplyPatch "${T}/aufs/patch_list" "${AUFS_INF}"
	mv "${T}/aufs" "${WORKDIR}/linux-${KV_FULL}-patches/aufs" || die "${RED}mv ${T}/aufs ${WORKDIR}/linux-${KV_FULL}-patches/aufs failed${NORMAL}"
#	rsync -avhW --no-compress --progress "${T}/aufs/" "${WORKDIR}/linux-${KV_FULL}-patches/aufs" || die "${RED}rsync -avhW --no-compress --progress ${T}/aufs/ ${WORKDIR}/linux-${KV_FULL}-patches/aufs failed${NORMAL}"
}

# @FUNCTION: pkg_postinst
# @USAGE:
# @DESCRIPTION: Called after image is installed to ${ROOT}
geek-aufs_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	einfo "${AUFS_INF}"
}
