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
#  https://github.com/init6/init_6/blob/master/eclass/geek-linux.eclass
#
#  Bugs: https://github.com/init6/init_6/issues
#

inherit geek-build geek-deblob geek-patch geek-utils

EXPORT_FUNCTIONS src_unpack src_prepare src_compile src_install pkg_postinst

# No need to run scanelf/strip on kernel sources/headers (bug #134453).
RESTRICT="mirror binchecks strip"

LICENSE="GPL-2"

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

# Color
BR="\x1b[0;01m"
#BLUEDARK="\x1b[34;0m"
BLUE="\x1b[34;01m"
#CYANDARK="\x1b[36;0m"
CYAN="\x1b[36;01m"
#GRAYDARK="\x1b[30;0m"
#GRAY="\x1b[30;01m"
#GREENDARK="\x1b[32;0m"
#GREEN="\x1b[32;01m"
#LIGHT="\x1b[37;01m"
#MAGENTADARK="\x1b[35;0m"
#MAGENTA="\x1b[35;01m"
NORMAL="\x1b[0;0m"
#REDDARK="\x1b[31;0m"
RED="\x1b[31;01m"
YELLOW="\x1b[33;01m"

# 0 for 3.4.0
if [ "${SUBLEVEL}" = "0" ] || [ "${PV}" = "${KMV}" ] ; then
	PV="${KMV}" # default PV=3.4.0 new PV=3.4
	if [[ "${PR}" == "r0" ]] ; then
		SKIP_UPDATE=1 # Skip update to latest upstream
	fi
fi

# ebuild default values setup settings
EXTRAVERSION=${EXTRAVERSION:-"-geek"}
KV_FULL="${PVR}${EXTRAVERSION}"
S="${WORKDIR}"/linux-"${KV_FULL}"

DEPEND="!build? ( sys-apps/sed
		  >=sys-devel/binutils-2.11.90.0.31 )"
RDEPEND="!build? ( >=sys-libs/ncurses-5.2
		   sys-devel/make
		   dev-lang/perl
		   sys-devel/bc )"
PDEPEND="!build? ( virtual/dev-manager )"

SLOT=${SLOT:-${KMV}}
IUSE="${IUSE} symlink"

case "$PR" in
	r0)	case "$VERSION" in
		2)	extension="xz"
			kurl="mirror://kernel/linux/kernel/v${KMV}/longterm/v${KMV}.${SUBLEVEL}"
			kversion="${KMV}.${SUBLEVEL}"
			if [ "${SUBLEVEL}" != "0" ] || [ "${PV}" != "${KMV}" ]; then
				pversion="${PV}"
				pname="patch-${pversion}.${extension}"
				SRC_URI="${SRC_URI} ${kurl}/${pname}"
			fi
		;;
		3)	extension="xz"
			kurl="mirror://kernel/linux/kernel/v${VERSION}.0"
			kversion="${KMV}"
			if [ "${SUBLEVEL}" != "0" ] || [ "${PV}" != "${KMV}" ]; then
				pversion="${PV}"
				pname="patch-${pversion}.${extension}"
				SRC_URI="${SRC_URI} ${kurl}/${pname}"
			fi
		;;
		esac
	;;
	*)	extension="xz"
		kurl="mirror://kernel/linux/kernel/v${VERSION}.0/testing"
		kversion="${VERSION}.$((${PATCHLEVEL} - 1))"
		if [ "${SUBLEVEL}" != "0" ] || [ "${PV}" != "${KMV}" ]; then
			pversion="${PVR//r/rc}"
			pname="patch-${pversion}.${extension}"
			SRC_URI="${SRC_URI} ${kurl}/${pname}"
		fi
	;;
esac

case "$VERSION" in
	2)	kurl="mirror://kernel/linux/kernel/v${KMV}" ;;
esac

kname="linux-${kversion}.tar.${extension}"
SRC_URI="${SRC_URI} ${kurl}/${kname}"

# @FUNCTION: init_variables
# @INTERNAL
# @DESCRIPTION:
# Internal function initializing all variables.
# We define it in function scope so user can define
# all the variables before and after inherit.
geek-linux_init_variables() {
	debug-print-function ${FUNCNAME} "$@"

	: ${cfg_file:="/etc/portage/kernel.conf"}

	local rm_unneeded_arch_cfg=$(source $cfg_file 2>/dev/null; echo ${rm_unneeded_arch})
	: ${rm_unneeded_arch:=${rm_unneeded_arch_cfg:-no}} # rm_unneeded-arch=yes/no
}

geek-linux_init_variables

# @FUNCTION: src_unpack
# @USAGE:
# @DESCRIPTION: Extract source packages and do any necessary patching or fixes.
geek-linux_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	if [ "${A}" != "" ]; then
		ebegin "Extract the sources"
			tar xvJf "${PORTAGE_ACTUAL_DISTDIR:-${DISTDIR}}/${kname}" &>/dev/null
		eend $?
		cd "${WORKDIR}" || die "${RED}cd ${WORKDIR} failed${NORMAL}"
		mv "linux-${kversion}" "${S}" || die "${RED}mv linux-${kversion} ${S} failed${NORMAL}"
	fi
	cd "${S}" || die "${RED}cd ${S} failed${NORMAL}"
	if [ "${SKIP_UPDATE}" = "1" ] ; then
		ewarn "${RED}Skipping update to latest upstream ...${NORMAL}"
	else
		ApplyPatch "${PORTAGE_ACTUAL_DISTDIR:-${DISTDIR}}/${pname}" "${YELLOW}Update to latest upstream ...${NORMAL}"
	fi

	if use deblob; then
		geek-deblob_src_unpack
	fi
}

# @FUNCTION: src_prepare
# @USAGE:
# @DESCRIPTION: Prepare source packages and do any necessary patching or fixes.
geek-linux_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

	ebegin "Set extraversion in Makefile" # manually set extraversion
		sed -i -e "s:^\(EXTRAVERSION =\).*:\1 ${EXTRAVERSION}:" Makefile
	eend

	get_config

	ebegin "Cleanup backups after patching"
		rm_crap
	eend

	case "$rm_unneeded_arch" in
	yes)	ebegin "Remove unneeded architectures"
			if use x86 || use amd64; then
				rm -rf "${WORKDIR}"/linux-"${KV_FULL}"/arch/{alpha,arc,arm,arm26,arm64,avr32,blackfin,c6x,cris,frv,h8300,hexagon,ia64,m32r,m68k,m68knommu,metag,mips,microblaze,mn10300,openrisc,parisc,powerpc,ppc,s390,score,sh,sh64,sparc,sparc64,tile,unicore32,um,v850,xtensa}
				sed -i 's/include/#include/g' "${WORKDIR}"/linux-"${KV_FULL}"/fs/hostfs/Makefile
			else
				rm -rf "${WORKDIR}"/linux-"${KV_FULL}"/arch/{avr32,blackfin,c6x,cris,frv,h8300,hexagon,m32r,m68k,m68knommu,microblaze,mn10300,openrisc,score,tile,unicore32,um,v850,xtensa}
			fi
		eend ;;
	no)	einfo "Skipping remove unneeded architectures ..." ;;
	esac

	ebegin "Compile ${RED}gen_init_cpio${NORMAL}"
		make -C "${WORKDIR}"/linux-"${KV_FULL}"/usr/ gen_init_cpio > /dev/null 2>&1
		chmod +x "${WORKDIR}"/linux-"${KV_FULL}"/usr/gen_init_cpio "${WORKDIR}"/linux-"${KV_FULL}"/scripts/gen_initramfs_list.sh > /dev/null 2>&1
	eend

	cd "${WORKDIR}"/linux-"${KV_FULL}" || die "${RED}cd ${WORKDIR}/linux-${KV_FULL} failed${NORMAL}"
	local GENTOOARCH="${ARCH}"
	unset ARCH
	ebegin "Running ${RED}make oldconfig${NORMAL}"
		make oldconfig </dev/null &>/dev/null
	eend $? "Failed oldconfig"
	ebegin "Running ${RED}modules_prepare${NORMAL}"
		make modules_prepare &>/dev/null
	eend $? "Failed ${RED}modules prepare${NORMAL}"
	ARCH="${GENTOOARCH}"

	echo
	einfo "${RED}Live long and prosper.${NORMAL}"
	echo
}

# @FUNCTION: src_compile
# @USAGE:
# @DESCRIPTION: Configure and build the package.
geek-linux_src_compile() {
	debug-print-function ${FUNCNAME} "$@"

	if use deblob; then
		geek-deblob_src_compile
	fi
}

# @FUNCTION: src_install
# @USAGE:
# @DESCRIPTION: Install a package to ${D}
geek-linux_src_install() {
	debug-print-function ${FUNCNAME} "$@"

	if use build; then
		geek-build_src_compile
	fi

	local version_h_name="usr/src/linux-${KV_FULL}/include/linux"
	local version_h="${ROOT}${version_h_name}"

	if [ -f "${version_h}" ]; then
		einfo "Discarding previously installed version.h to avoid collisions"
		addwrite "/${version_h_name}"
		rm -f "${version_h}"
	fi

	cd "${S}" || die "${RED}cd ${S} failed${NORMAL}"
	dodir /usr/src
	echo ">>> Copying sources ..."

#	mv ${WORKDIR}/linux* "${D}"/usr/src || die "${RED}mv ${WORKDIR}/linux* ${D}/usr/src failed${NORMAL}"
#	rsync -avhW --no-compress --progress ${WORKDIR}/linux*/ "${D}"/usr/src || die "${RED}rsync -avhW --no-compress --progress ${WORKDIR}/linux*/ ${D}/usr/src failed${NORMAL}"
	test -d "${D}/usr/src/linux-${KV_FULL}" >/dev/null 2>&1 || mkdir -p "${D}/usr/src/linux-${KV_FULL}"; (cd "${WORKDIR}/linux-${KV_FULL}"; tar cf - .) | (cd "${D}/usr/src/linux-${KV_FULL}"; tar xpf -)
	test -d "${D}/usr/src/linux-${KV_FULL}-patches" >/dev/null 2>&1 || mkdir -p "${D}/usr/src/linux-${KV_FULL}-patches"; (cd "${WORKDIR}/linux-${KV_FULL}-patches"; tar cf - .) | (cd "${D}/usr/src/linux-${KV_FULL}-patches"; tar xpf -)

	if use symlink; then
		if [ -h "/usr/src/linux" ]; then
			addwrite "/usr/src/linux"
			unlink "/usr/src/linux" || die "${RED}unlink /usr/src/linux failed${NORMAL}"
		elif [ -d "/usr/src/linux" ]; then
			mv "/usr/src/linux" "/usr/src/linux-old" || die "${RED}mv /usr/src/linux /usr/src/linux-old failed${NORMAL}"
		fi
		dosym linux-${KV_FULL} \
			"/usr/src/linux" ||
			die "${RED}cannot install kernel symlink${NORMAL}"
	fi
}

# @FUNCTION: pkg_postinst
# @USAGE:
# @DESCRIPTION: Called after image is installed to ${ROOT}
geek-linux_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	einfo " ${BLUE}If you are upgrading from a previous kernel, you may be interested${NORMAL}"
	einfo " ${BLUE}in the following document:${NORMAL}"
	einfo "   ${BLUE}- General upgrade guide:${NORMAL} ${RED}http://www.gentoo.org/doc/en/kernel-upgrade.xml${NORMAL}"
	einfo " ${RED}${CATEGORY}/${PN}${NORMAL} ${BLUE}is UNSUPPORTED Gentoo Security.${NORMAL}"
	einfo " ${BLUE}This means that it is likely to be vulnerable to recent security issues.${NORMAL}"
	einfo " ${BLUE}For specific information on why this kernel is unsupported, please read:${NORMAL}"
	einfo " ${RED}http://www.gentoo.org/proj/en/security/kernel.xml${NORMAL}"
	einfo
	einfo " ${BLUE}Now is the time to configure and build the kernel.${NORMAL}"
	einfo

	if use deblob; then
		geek-deblob_pkg_postinst
	fi
}
