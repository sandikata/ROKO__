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
#  https://github.com/init6/init_6/blob/master/eclass/geek-patch.eclass
#
#  Bugs: https://github.com/init6/init_6/issues
#

EXPORT_FUNCTIONS ApplyPatch SmartApplyPatch

# *.gz       -> gunzip -dc    -> app-arch/gzip
# *.bz|*.bz2 -> bunzip -dc    -> app-arch/bzip2
# *.lrz      -> lrunzip -dc   -> app-arch/lrzip
# *.xz       -> xz -dc        -> app-arch/xz-utils
# *.zip      -> unzip -d      -> app-arch/unzip
# *.Z        -> uncompress -c -> app-arch/gzip

DEPEND="${DEPEND}
	app-arch/bzip2
	app-arch/gzip
	app-arch/lrzip
	app-arch/unzip
	app-arch/xz-utils"


# @FUNCTION: init_variables
# @INTERNAL
# @DESCRIPTION:
# Internal function initializing all variables.
# We define it in function scope so user can define
# all the variables before and after inherit.
geek-patch_init_variables() {
	debug-print-function ${FUNCNAME} "$@"

	: ${patch_cmd:=${patch_cmd:-"patch -p1 -g1 --no-backup-if-mismatch"}}

	: ${cfg_file:="/etc/portage/kernel.conf"}

	local crap_patch_cfg=$(source $cfg_file 2>/dev/null; echo ${crap_patch})
	: ${crap_patch:=${crap_patch_cfg:-ignore}} # crap_patch=ignore/will_not_pass
}

geek-patch_init_variables

# iternal function
#
# @FUNCTION: get_patch_cmd
# @USAGE: get_patch_cmd
# @DESCRIPTION: Get argument to patch
get_patch_cmd () {
	debug-print-function ${FUNCNAME} "$@"
	debug-print "$FUNCNAME: crap_patch=$crap_patch"
	debug-print "$FUNCNAME: patch_cmd=$patch_cmd"

	case "$crap_patch" in
	ignore) patch_cmd="patch -p1 -g1 --no-backup-if-mismatch" ;;
	will_not_pass) patch_cmd="patch -p1 -g1" ;;
	esac
}

# iternal function
#
# @FUNCTION: get_test_patch_cmd
# @USAGE: get_test_patch_cmd
# @DESCRIPTION: Get test argument to patch
get_test_patch_cmd () {
	debug-print-function ${FUNCNAME} "$@"
	debug-print "$FUNCNAME: crap_patch=$crap_patch"
	debug-print "$FUNCNAME: patch_cmd=$patch_cmd"

	case "$crap_patch" in # test argument to patch
	ignore) patch_cmd="patch -p1 -g1 --dry-run --no-backup-if-mismatch" ;;
	will_not_pass) patch_cmd="patch -p1 -g1 --dry-run" ;;
	esac
}

# iternal function
#
# @FUNCTION: ExtractApply
# @USAGE: ExtractApply "<patch>"
# @DESCRIPTION: Extract patch from *.gz, *.bz, *.bz2, *.lrz, *.xz, *.zip, *.Z
ExtractApply() {
	debug-print-function ${FUNCNAME} "$@"

	local patch=$1
	debug-print "$FUNCNAME: patch=$patch"
	debug-print "$FUNCNAME: patch_cmd=$patch_cmd"

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
			get_test_patch_cmd
			if ExtractApply "$patch" &>/dev/null; then
				get_patch_cmd
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
			get_test_patch_cmd
			if ExtractApply "$patch" &>/dev/null; then
				get_patch_cmd
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

	get_patch_cmd
}

# @FUNCTION: ApplyPatch
# @USAGE:
# ApplyPatch "${FILESDIR}/${PVR}/patch_list" "Patch set description"
# ApplyPatch "${FILESDIR}/<patch>" "Patch description"
# @DESCRIPTION:
# Main function
geek-patch_ApplyPatch() {
	debug-print-function ${FUNCNAME} "$@"

	local patch=$1
	debug-print "$FUNCNAME: patch=$patch"
	debug-print "$FUNCNAME: patch_cmd=$patch_cmd"
	local msg=$2
	debug-print "$FUNCNAME: msg=$msg"
	shift
	echo
	einfo "${msg}"
	patch_base_name=$(basename "$patch")
	patch_dir_name=$(dirname "$patch")
	case $patch_base_name in
	patch_list) # list of patches
		while read -r line; do
			[[ -z "$line" ]] && continue # skip empty lines
			[[ $line =~ ^\ {0,}# ]] && continue # skip comments
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
geek-patch_SmartApplyPatch() {
	debug-print-function ${FUNCNAME} "$@"

	geek-patch_init_variables

	local patch=$1
	debug-print "$FUNCNAME: patch=$patch"
	debug-print "$FUNCNAME: patch_cmd=$patch_cmd"
	local msg=$2
	debug-print "$FUNCNAME: msg=$msg"
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
