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
#  https://github.com/init6/init_6/blob/master/eclass/geek-utils.eclass
#
#  Bugs: https://github.com/init6/init_6/issues
#

EXPORT_FUNCTIONS use_if_iuse get_from_url git_get_all_branches git_checkout find_crap rm_crap get_config

# @FUNCTION: in_iuse
# @USAGE: <flag>
# @DESCRIPTION:
# Determines whether the given flag is in IUSE. Strips IUSE default prefixes
# as necessary.
#
# Note that this function should not be used in the global scope.
in_iuse() {
	debug-print-function ${FUNCNAME} "${@}"

	[[ ${#} -eq 1 ]] || die "Invalid args to ${FUNCNAME}()"

	local flag=${1}
	local liuse=( ${IUSE} )

	has "${flag}" "${liuse[@]#[+-]}"
}

# @FUNCTION: use_if_iuse
# @USAGE: <flag>
# @DESCRIPTION:
# Return true if the given flag is in USE and IUSE.
#
# Note that this function should not be used in the global scope.
geek-utils_use_if_iuse() {
	debug-print-function ${FUNCNAME} "$@"

	in_iuse $1 || return 1
	use $1
}

# @FUNCTION: get_from_url
# @USAGE:
# @DESCRIPTION:
geek-utils_get_from_url() {
	debug-print-function ${FUNCNAME} "$@"

	local url="$1"
	local release="$2"
	shift
	wget -nd --no-parent --level 1 -r -R "*.html*" --reject "$release" \
	"$url/$release" > /dev/null 2>&1
}

# @FUNCTION: git_get_all_branches
# @USAGE:
# @DESCRIPTION:
geek-utils_git_get_all_branches(){
	debug-print-function ${FUNCNAME} "$@"

	for branch in `git branch -a | grep remotes | grep -v HEAD | grep -v master`; do
		git branch --track ${branch##*/} ${branch} > /dev/null 2>&1
	done
}

# @FUNCTION: git_checkout
# @USAGE:
# @DESCRIPTION:
geek-utils_git_checkout(){
	debug-print-function ${FUNCNAME} "$@"

	local branch_name=${1:-master}

	pushd "${EGIT_SOURCEDIR}" > /dev/null

	debug-print "${FUNCNAME}: git checkout ${branch_name}"
	git checkout ${branch_name}

	popd > /dev/null
}

# iternal function
#
# @FUNCTION: find_crap
# @USAGE:
# @DESCRIPTION: Find *.orig or *.rej files
geek-utils_find_crap() {
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
geek-utils_rm_crap() {
	debug-print-function ${FUNCNAME} "$@"

	find "${S}" \( -name \*~ -o -name \.gitignore -o -name \*.orig -o -name \.*.orig -o -name \*.rej -o -name \*.old -o -name \.*.old \) -delete
}

# @FUNCTION: get_config
# @USAGE:
# @DESCRIPTION:
geek-utils_get_config() {
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
