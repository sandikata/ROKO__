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
#  https://github.com/init6/init_6/blob/master/eclass/linux-geek.eclass
#
#  Wiki: https://github.com/init6/init_6/wiki/linux-geek.eclass
#

# Functional part
# Purpose: Installing linux.
# Apply patches, build the kernel from source.
#
# Bugs to sudormrfhalt@gmail.com
#

EXPORT_FUNCTIONS ApplyPatch SmartApplyPatch src_unpack get_config src_prepare src_compile src_install pkg_postinst

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

case ${EAPI} in
	0|1)
		die "${BLUE}Unsupported${NORMAL} ${RED}EAPI=${EAPI}${NORMAL} ${BLUE}(too old) for linux-geek.eclass${NORMAL}" ;;
	2|3) ;;
	4|5)
		# S is no longer automatically assigned when it doesn't exist.
		S="${WORKDIR}"
		;;
	*)
		die "${BLUE}Unknown${NORMAL} ${RED}EAPI=${EAPI}${NORMAL} ${BLUE}for linux-geek.eclass${NORMAL}"
esac

# No need to run scanelf/strip on kernel sources/headers (bug #134453).
RESTRICT="mirror binchecks strip"

: ${LICENSE:="GPL-2"}

# *.gz       -> gunzip -dc    -> app-arch/gzip-1.5
# *.bz|*.bz2 -> bunzip -dc    -> app-arch/bzip2-1.0.6-r3
# *.lrz      -> lrunzip -dc   -> app-arch/lrzip-0.614 <- now only for ck
# *.xz       -> xz -dc        -> app-arch/xz-utils-5.0.4-r1
# *.zip      -> unzip -d      -> app-arch/unzip-6.0-r3
# *.Z        -> uncompress -c -> app-arch/gzip-1.5

# Even though xz-utils are in @system, they must still be added to DEPEND; see
# http://archives.gentoo.org/gentoo-dev/msg_a0d4833eb314d1be5d5802a3b710e0a4.xml
DEPEND="${DEPEND}
app-arch/bzip2
app-arch/gzip
app-arch/unzip
app-arch/xz-utils"

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

# 0 for 3.4.0
if [ "${SUBLEVEL}" = "0" ] || [ "${PV}" = "${KMV}" ] ; then
	PV="${KMV}" # default PV=3.4.0 new PV=3.4
	if [[ "${PR}" == "r0" ]] ; then
		SKIP_UPDATE=1 # Skip update to latest upstream
	fi
fi

# ebuild default values setup settings
DEFEXTRAVERSION="-geek"
EXTRAVERSION=${EXTRAVERSION:-$DEFEXTRAVERSION}
KV_FULL="${PVR}${EXTRAVERSION}"
S="${WORKDIR}"/linux-"${KV_FULL}"
SLOT=${SLOT:-${KMV}}
IUSE="symlink build"

# @FUNCTION: linux-geek_init_variables
# @INTERNAL
# @DESCRIPTION:
# Internal function initializing all git variables.
# We define it in function scope so user can define
# all the variables before and after inherit.
linux-geek_init_variables() {
	debug-print-function ${FUNCNAME} "$@"

	: ${GEEK_STORE_DIR:="${PORTAGE_ACTUAL_DISTDIR-${DISTDIR}}/geek"}
	# Disable the sandbox for this dir
	addwrite "${GEEK_STORE_DIR}"

	: ${cfg_file:="/etc/portage/kernel.conf"}

	local crap_patch_cfg=$(source $cfg_file 2>/dev/null; echo ${crap_patch})
	: ${crap_patch:=${crap_patch_cfg:-ignore}} # crap_patch=ignore/will_not_pass
	: ${crap:="0"}

	case "$crap_patch" in
	ignore) : ${patch_cmd:="patch -p1 -g1 --no-backup-if-mismatch"} ;;
	will_not_pass) : ${patch_cmd:="patch -p1 -g1"} ;;
	esac

	local rm_unneeded_arch_cfg=$(source $cfg_file 2>/dev/null; echo ${rm_unneeded_arch})
	: ${rm_unneeded_arch:=${rm_unneeded_arch_cfg:-no}} # rm_unneeded-arch=yes/no

	local skip_squeue_cfg=$(source $cfg_file 2>/dev/null; echo ${skip_squeue})
	: ${skip_squeue:=${skip_squeue_cfg:-no}} # skip_squeue=yes/no
}

case "$PR" in
	r0)	case "$VERSION" in
		2)	extension="bz2"
			kurl="mirror://kernel/linux/kernel/v${KMV}"
			kversion="${PV}"
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

kname="linux-${kversion}.tar.${extension}"
SRC_URI="${SRC_URI} ${kurl}/${kname}"

# Bug #266157, deblob for libre support
if [[ -z ${PREDEBLOBBED} ]]; then
	if [[ ${DEBLOB_AVAILABLE} == "1" ]]; then
		IUSE="${IUSE} deblob"
		# Reflect that kernels contain firmware blobs unless otherwise
		# stripped
		LICENSE="${LICENSE} !deblob? ( freedist )"

		if [[ -n PATCHLEVEL ]]; then
			DEBLOB_PV="${VERSION}.${PATCHLEVEL}.${SUBLEVEL}"
		else
			DEBLOB_PV="${VERSION}.${SUBLEVEL}"
		fi

		if [[ ${VERSION} -ge 3 ]]; then
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
		HOMEPAGE="${HOMEPAGE} ${DEBLOB_HOMEPAGE}"

		SRC_URI="${SRC_URI}
			deblob? (
				${DEBLOB_URI}
				${DEBLOB_CHECK_URI}
			)"
	else
		# We have no way to deblob older kernels, so just mark them as
		# tainted with non-libre materials.
		LICENSE="${LICENSE} freedist"
	fi
fi

# iternal function
#
# @FUNCTION: ExtractApply
# @USAGE: ExtractApply "<patch>"
# @DESCRIPTION: Extract patch from *.gz, *.bz, *.bz2, *.lrz, *.xz, *.zip, *.Z
ExtractApply() {
	debug-print-function ${FUNCNAME} "$@"

	local patch=$1
	shift
	case "$patch" in
	*.gz)       gunzip -dc    < "$patch" | $patch_cmd ${1+"$@"} ;; # app-arch/gzip
	*.bz|*.bz2) bunzip2 -dc   < "$patch" | $patch_cmd ${1+"$@"} ;; # app-arch/bzip2
	*.lrz)      lrunzip -dc   < "$patch" | $patch_cmd ${1+"$@"} ;; # app-arch/lrzip
	*.xz)       xz -dc        < "$patch" | $patch_cmd ${1+"$@"} ;; # app-arch/xz-utils
	*.zip)      unzip -d      < "$patch" | $patch_cmd ${1+"$@"} ;; # app-arch/unzip
	*.Z)        uncompress -c < "$patch" | $patch_cmd ${1+"$@"} ;; # app-arch/gzip
	*) $patch_cmd ${1+"$@"} < "$patch" ;;
	esac
}

# iternal function
#
# @FUNCTION: find_crap
# @USAGE:
# @DESCRIPTION: Find *.orig or *.rej files
find_crap() {
	debug-print-function ${FUNCNAME} "$@"

	if [ $(find "${S}" \( -name \*.orig -o -name \*.rej \) | wc -c) -eq 0 ]; then
		crap="0"
	else
		crap="1"
	fi
}

# iternal function
#
# @FUNCTION: rm_crap
# @USAGE:
# @DESCRIPTION: Remove *.orig or *.rej files
rm_crap() {
	debug-print-function ${FUNCNAME} "$@"

	find "${S}" \( -name \*~ -o -name \.gitignore -o -name \*.orig -o -name \.*.orig -o -name \*.rej -o -name \*.old -o -name \.*.old \) -delete
}

# internal function
#
# @FUNCTION: Handler
# @USAGE:
# @DESCRIPTION:
# Check the availability of a patch on the path passed
# Check that the patch was not an empty
# Test run patch with 'patch -p1 --dry-run'
# All tests completed successfully? run ExtractApply
Handler() {
	debug-print-function ${FUNCNAME} "$@"

	local patch=$1
	local patch_base_name=$(basename "$patch")
	shift
	if [ ! -f "$patch" ]; then
		ewarn "${BLUE}Patch${NORMAL} ${RED}$patch${NORMAL} ${BLUE}does not exist.${NORMAL}"
	fi
	case "$patch" in
	*.gz|*.bz|*.bz2|*.lrz|*.xz|*.zip|*.Z)
		if [ -s "$patch" ]; then # !=0
			case "$crap_patch" in # test argument to patch
			ignore) patch_cmd="patch -p1 -g1 --dry-run --no-backup-if-mismatch" ;;
			will_not_pass) patch_cmd="patch -p1 -g1 --dry-run" ;;
			esac
			if ExtractApply "$patch" &>/dev/null; then
				case "$crap_patch" in
				ignore) patch_cmd="patch -p1 -g1 --no-backup-if-mismatch" ;;
				will_not_pass) patch_cmd="patch -p1 -g1" ;;
				esac
				ExtractApply "$patch" &>/dev/null
			else
				ewarn "${BLUE}Skipping patch -->${NORMAL} ${RED}$patch_base_name${NORMAL}"
				return 1
			fi
		else
			ewarn "${BLUE}Skipping empty patch -->${NORMAL} ${RED}$patch_base_name${NORMAL}"
		fi
	;;
	*)
		local C=$(wc -l "$patch" | awk '{print $1}')
		if [ "$C" -gt 8 ]; then # 8 lines
			case "$crap_patch" in # test argument to patch
			ignore) patch_cmd="patch -p1 -g1 --dry-run --no-backup-if-mismatch" ;;
			will_not_pass) patch_cmd="patch -p1 -g1 --dry-run" ;;
			esac
			if ExtractApply "$patch" &>/dev/null; then
				case "$crap_patch" in
				ignore) patch_cmd="patch -p1 -g1 --no-backup-if-mismatch" ;;
				will_not_pass) patch_cmd="patch -p1 -g1" ;;
				esac
				ExtractApply "$patch" &>/dev/null
			else
				ewarn "${BLUE}Skipping patch -->${NORMAL} ${RED}$patch_base_name${NORMAL}"
				return 1
			fi
		else
			ewarn "${BLUE}Skipping empty patch -->${NORMAL} ${RED}$patch_base_name${NORMAL}"
		fi
	;;
	esac

	case "$crap_patch" in
	will_not_pass) find_crap
	if [[ "${crap}" == 1 ]]; then
		ebegin "${BLUE}Reversing crap patch <--${NORMAL} ${RED}$patch_base_name${NORMAL}"
			patch_cmd="patch -p1 -g1 -R"; # reverse argument to patch
			ExtractApply "$patch" &>/dev/null
			rm_crap
		eend
	fi

	;;
	esac
}

# @FUNCTION: ApplyPatch
# @USAGE:
# ApplyPatch "${FILESDIR}/${PVR}/patch_list" "Patch set description"
# ApplyPatch "${FILESDIR}/<patch>" "Patch description"
# @DESCRIPTION:
# Main function
linux-geek_ApplyPatch() {
	debug-print-function ${FUNCNAME} "$@"

	local patch=$1
	local msg=$2
	shift
	echo
	einfo "${msg}"
	patch_base_name=$(basename "$patch")
	patch_dir_name=$(dirname "$patch")
	case $patch_base_name in
	patch_list) # list of patches
		while read -r line; do
			# skip empty lines
			[[ -z "$line" ]] && continue
			# skip comments
			[[ $line =~ ^\ {0,}# ]] && continue
			ebegin "Applying $line"
				Handler "$patch_dir_name/$line"
			eend $?
		done < "$patch"
	;;
	*) # else is patch
		ebegin "Applying $patch_base_name"
			Handler "$patch"
		eend $?
	;;
	esac
}

# @FUNCTION: SmartApplyPatch
# @USAGE:
# SmartApplyPatch "${FILESDIR}/${PVR}/spatch_list" "Patch set description"
# @DESCRIPTION:
# Main function
linux-geek_SmartApplyPatch() {
	debug-print-function ${FUNCNAME} "$@"

	local patch=$1
	local msg=$2
	shift
	echo
	einfo "${msg}"
	patch_base_name=$(basename "${patch}")
	patch_dir_name=$(dirname "${patch}")
	case ${patch_base_name} in
	spatch_list) # list of patches
		for var in $(grep -v '^#' "${patch}"); do
			ebegin "Applying $var"
				Handler "${patch_dir_name}/${var}" || no_luck="1"
				[ "${no_luck}" = "1" ] && break
			eend
		done
		if [ "${no_luck}" = "1" ]; then
			local vars=($(grep -v '^#' ${patch}))
			for var in $(seq $((${#vars[@]} - 1)) -1 0); do
				ebegin "${BLUE}Reversing patch <--${NORMAL} ${RED}${vars[$var]}${NORMAL}"
					patch_cmd="patch -p1 -g1 -R" # reverse argument to patch
					ExtractApply "${patch_dir_name}/${vars[$var]}" &>/dev/null
				eend $?
			done
		fi
	;;
	*) continue ;;
	esac
}

# @FUNCTION: gen_squeue
# @USAGE:
# @DESCRIPTION:
linux-geek_gen_squeue() {
	debug-print-function ${FUNCNAME} "$@"

	local CSD="${GEEK_STORE_DIR}/squeue"
	local CWD="${S}/patches/squeue"

	if [ -d ${CSD} ]; then
		cd ${CSD} || die "${RED}cd ${CSD} failed${NORMAL}"
		git pull > /dev/null 2>&1
		cd "${S}" || die "${RED}cd ${S} failed${NORMAL}"
	else
		git clone "git://git.kernel.org/pub/scm/linux/kernel/git/stable/stable-queue.git" ${CSD} > /dev/null 2>&1
	fi

	test -d "${S}/patches" >/dev/null 2>&1 || mkdir -p "${S}/patches"

	if [ -d ${CSD}/queue-${KMV} ] ; then
		cp -r "${CSD}/queue-${KMV}" "${CWD}" || die "${RED}cp -r ${CSD}/queue-${KMV} ${CWD} failed${NORMAL}"
		mv "${CWD}/series" "${CWD}/patch_list" || die "${RED}mv ${CWD}/series ${CWD}/patch_list failed${NORMAL}"
	elif [ -d ${CSD}/releases/${PV} ]; then
		cp -r "${CSD}/releases/${PV}" "${CWD}" || die "${RED}cp -r ${CSD}/releases/${PV} ${CWD} failed${NORMAL}"
		mv "${CWD}/series" "${CWD}/patch_list" || die "${RED}mv ${CWD}/series ${CWD}/patch_list failed${NORMAL}"
	else
		ewarn "There is no stable-queue patch-set this time"
	fi
}

# @FUNCTION: src_unpack
# @USAGE:
# @DESCRIPTION: Extract source packages and do any necessary patching or fixes.
linux-geek_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	linux-geek_init_variables

	einfo "${BLUE}Crap patch -->${NORMAL} ${RED}$crap_patch${NORMAL}"
	einfo "${BLUE}Remove unneeded architectures -->${NORMAL} ${RED}$rm_unneeded_arch${NORMAL}"
	einfo "${BLUE}Skip stable-queue -->${NORMAL} ${RED}$skip_squeue${NORMAL}"

	if [ "${A}" != "" ]; then
		ebegin "Extract the sources"
			tar xvJf "${DISTDIR}/${kname}" &>/dev/null
		eend $?
		cd "${WORKDIR}" || die "${RED}cd ${WORKDIR} failed${NORMAL}"
		mv "linux-${kversion}" "${S}" || die "${RED}mv linux-${kversion} ${S} failed${NORMAL}"
	fi
	cd "${S}" || die "${RED}cd ${S} failed${NORMAL}"
	case "$VERSION" in
		2) continue
	#	if  [ "${SUBLEVEL}" != "0" ]; then
	#		ApplyPatch "${DISTDIR}/${pname}" "${YELLOW}Update to latest upstream ...${NORMAL}"
	#	fi
		;;
		3) if [ "${SKIP_UPDATE}" = "1" ] ; then
				ewarn "${RED}Skipping update to latest upstream ...${NORMAL}"
			else
				ApplyPatch "${DISTDIR}/${pname}" "${YELLOW}Update to latest upstream ...${NORMAL}"
		fi
		;;
	esac

	if [[ $DEBLOB_AVAILABLE == 1 ]] && use deblob; then
		cp "${DISTDIR}/${DEBLOB_A}" "${T}" || die "${RED}cp ${DEBLOB_A} failed${NORMAL}"
		cp "${DISTDIR}/${DEBLOB_CHECK_A}" "${T}/deblob-check" || die "${RED}cp ${DEBLOB_CHECK_A} failed${NORMAL}"
		chmod +x "${T}/${DEBLOB_A}" "${T}/deblob-check" || die "${RED}chmod deblob scripts failed${NORMAL}"
	fi
}

# @FUNCTION: get_config
# @USAGE:
# @DESCRIPTION:
linux-geek_get_config() {
	debug-print-function ${FUNCNAME} "$@"

	ebegin "Searching for best availiable kernel config"
		if [ -e "/proc/config.gz" ]; then test -d .config >/dev/null 2>&1 || zcat /proc/config.gz > .config
			einfo " ${BLUE}Foung config from running kernel, updating to match target kernel${NORMAL}"
		elif [ -e "/boot/config-${FULLVER}" ]; then test -d .config >/dev/null 2>&1 || cat "/boot/config-${FULLVER}" > .config
			einfo " ${BLUE}Found${NORMAL} ${RED}/boot/config-${FULLVER}${NORMAL}"
		elif [ -e "/etc/portage/savedconfig/${CATEGORY}/${PN}/config" ]; then test -d .config >/dev/null 2>&1 || cat /etc/portage/savedconfig/${CATEGORY}/${PN}/config > .config
			einfo " ${BLUE}Found${NORMAL} ${RED}/etc/portage/savedconfig/${CATEGORY}/${PN}/config${NORMAL}"
		elif [ -e "/usr/src/linux/.config" ]; then test -d .config >/dev/null 2>&1 || cat /usr/src/linux/.config > .config
			einfo " ${BLUE}Found${NORMAL} ${RED}/usr/src/linux/.config${NORMAL}"
		elif [ -e "/usr/src/linux-${KV_FULL}/.config" ]; then test -d .config >/dev/null 2>&1 || cat /usr/src/linux-${KV_FULL}/.config > .config
			einfo " ${BLUE}Found${NORMAL} ${RED}/usr/src/linux-${KV_FULL}/.config${NORMAL}"
		else test -d .config >/dev/null 2>&1 || cp arch/${ARCH}/defconfig .config \
			einfo " ${BLUE}No suitable custom config found, defaulting to defconfig${NORMAL}"
		fi
	eend $?
}

# @FUNCTION: src_prepare
# @USAGE:
# @DESCRIPTION: Prepare source packages and do any necessary patching or fixes.
linux-geek_src_prepare() {
	debug-print-function ${FUNCNAME} "$@"

	if [ "${skip_squeue}" = "yes" ]; then
			ewarn "${RED}Skipping update to latest stable queue ...${NORMAL}"
		else
			linux-geek_gen_squeue
			ApplyPatch "${S}/patches/squeue/patch_list" "${YELLOW}Update to latest stable queue ...${NORMAL}"
	fi

	echo
	ebegin "Set extraversion in Makefile" # manually set extraversion
		sed -i -e "s:^\(EXTRAVERSION =\).*:\1 ${EXTRAVERSION}:" Makefile
	eend

	linux-geek_get_config

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
linux-geek_src_compile() {
	debug-print-function ${FUNCNAME} "$@"

	if [[ $DEBLOB_AVAILABLE == 1 ]] && use deblob; then
		echo ">>> Running deblob script ..."
		sh "${T}/${DEBLOB_A}" --force || \
			die "${RED}Deblob script failed to run!!!${NORMAL}"
	fi
}

# @FUNCTION: src_install
# @USAGE:
# @DESCRIPTION: Install a package to ${D}
linux-geek_src_install() {
	debug-print-function ${FUNCNAME} "$@"

	# Disable the sandbox for this dir
	addwrite "/boot"

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

	mv ${WORKDIR}/linux* "${D}"/usr/src || die "${RED}mv ${WORKDIR}/linux* ${D}/usr/src failed${NORMAL}"

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

	if use build; then
		# Find out some info..
		eval $(head -n 4 Makefile | sed -e 's/ //g')
		local ARCH=$(uname -m | sed -e s/i.86/i386/g)
		local FULLVER=${VERSION}.${PATCHLEVEL}.${SUBLEVEL}${EXTRAVERSION}
		local MODULESUPPORT=$(grep "CONFIG_MODULES=y" .config 2>/dev/null)

		if [[ -e .config && -e arch/${ARCH}/boot/bzImage ]]; then
			ISNEWER=$(find .config -newer arch/${ARCH}/boot/bzImage 2>/dev/null)
		else
			if ! [[ -e .config ]]; then
				ISNEWER="noconfig"
			else
				ISNEWER="yes"
			fi
		fi

		if [[ -e .version ]]; then
			BUILDNO=$(cat .version)
		else
			BUILDNO="0"
		fi

		ebegin "Beginning installation procedure for ${RED}\"${FULLVER}\"${NORMAL}"
			if [[ ${ISNEWER} == "noconfig" ]]; then
				if [[ $(cat /proc/mounts | grep /boot) == "" && $(cat /etc/fstab | grep /boot) != "" ]]; then
					ebegin "  Boot partition unmounted, mounting"
						mount /boot
					eend $?
				fi

				linux-geek_get_config

			fi

			if [[ ${ISNEWER} != "" ]]; then
				ebegin " No kernel version found"
					if [[ -e /usr/src/linux/.version ]]; then
						einfo "  Foung kernel version /usr/src/linux/.version"
							cat /usr/src/linux/.version > .version
					elif [[ -e /usr/src/linux-${KV_FULL}/.version ]]; then
						einfo "  Foung kernel version /usr/src/linux-${KV_FULL}/.version"
							cat /usr/src/linux-${KV_FULL}/.version > .version
					fi
				eend $
				ebegin " Kernel build not uptodate, compiling"
					make bzImage 2>/dev/null
					if [[ ${MODULESUPPORT} != "" ]]; then
						einfo "  Module support in kernel detected, building modules"
							make modules 2>/dev/null
					fi
				eend $?
				BUILDNO=$(cat .version)
			fi

			ebegin " Merging kernel to system (Buildnumber: ${RED}${BUILDNO}${NORMAL})"
				einfo "  Copying bzImage to ${RED}\"/boot/vmlinuz-${FULLVER}-${BUILDNO}\"${NORMAL}"
					cp arch/${ARCH}/boot/bzImage /boot/vmlinuz-${FULLVER}-${BUILDNO}
				einfo "  Copying System.map to ${RED}\"/boot/System.map-${FULLVER}\"${NORMAL}"
					cp System.map /boot/System.map-${FULLVER}
				einfo "  Copying .config to ${RED}\"/boot/config-${FULLVER}\"${NORMAL}"
					cp .config /boot/config-${FULLVER}
				if [[ ${MODULESUPPORT} != "" ]]; then
					einfo "  Installing modules to ${RED}\"/lib/modules/${FULLVER}/\"${NORMAL}"
						make modules_install 2>/dev/null
				fi
				ebegin " Editing kernel entry in GRUB"
					if [[ -e "/etc/grub.d/10_linux" ]]; then
						grub2-mkconfig -o /boot/grub2/grub.cfg
					elif [[ -e "/etc/boot.conf" ]]; then
						boot-update
					fi
				eend $?
			eend $?

			if [[ -e /var/lib/module-rebuild/moduledb && $(cat /var/lib/module-rebuild/moduledb | wc -l) -ge 1 ]]; then
				ebegin " Looking for external kernel modules that need rebuilding"
					for EXTKERNMOD in $(sed -e 's/.:.://g' /var/lib/module-rebuild/moduledb); do
						if [[ $(find /boot/vmlinuz-${FULLVER}-${BUILDNO} -newer /var/db/pkg/${EXTKERNMOD}/environment.bz2 2>/dev/null) != "" ]]; then
							ebegin "  Recompiling outdated module ${RED}\"${EXTKERNMOD}\"${NORMAL}"
								emerge --oneshot =${EXTKERNMOD} 2>/dev/null
							eend $?
						fi
					done
				eend $?
			fi
		eend $?
	fi
}

# @FUNCTION: pkg_postinst
# @USAGE:
# @DESCRIPTION: Called after image is installed to ${ROOT}
linux-geek_pkg_postinst() {
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
}
