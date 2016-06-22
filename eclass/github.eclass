# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: github.eclass
# @MAINTAINER:
# Jan Chren (rindeal) <dev.rindeal+gentoo-overlay@gmail.com>
# @BLURB: Support eclass for packages hosted on Github
# @DESCRIPTION:
# Support eclass for packages hosted on Github
# Based on https://github.com/mrueg/mrueg-overlay/blob/master/eclass/github.eclass

if [ -z "${_GH_ECLASS}" ] ; then

case "${EAPI:-0}" in
	5|6) ;;
	*) die "Unsupported EAPI='${EAPI}' (unknown) for '${ECLASS}'" ;;
esac


# @ECLASS-VARIABLE: GH_REPO
# @DESCRIPTION:
# Github repository name or a string in the format: `<user_name>/<repository_name>`
: ${GH_REPO:="${PN}"}

if [[ "${GH_REPO}" == *'/'* ]] ; then
	GH_USER="${GH_REPO%%/*}"
	GH_REPO="${GH_REPO##*/}"
fi

# @ECLASS-VARIABLE: GH_USER
# @DESCRIPTION:
# Github user/group name
: ${GH_USER:="${PN}"}

# @ECLASS-VARIABLE: GH_TAG
# @DESCRIPTION:
# Tag/commit that is fetched from Github

# @ECLASS-VARIABLE: GH_BUILD_TYPE
# @DEFAULT_UNSET
# @DESCRIPTION:
# Defines if fetched from git ("live") or tarball ("release")
if [ -z "${GH_BUILD_TYPE}" ] ; then
	if [[ "${PV}" == *9999* ]] ; then
		GH_BUILD_TYPE='live'
	else
		GH_BUILD_TYPE='release'
	fi
fi


case "${GH_BUILD_TYPE}" in
	'release')
		inherit vcs-snapshot

		# a research conducted on April 2016 among the first 700 repos with >10000 stars shows:
		# - no tags: 158
		# - `v` prefix: 350
		# - no prefix: 192
		: ${GH_TAG:="${PV}"}
		SRC_URI="https://github.com/${GH_USER}/${GH_REPO}/archive/${GH_TAG}.tar.gz -> ${P}.tar.gz"
		;;
	'live')
		inherit git-r3

		[ -n "${GH_TAG}" ] && [ -z "${EGIT_COMMIT}" ] && \
			EGIT_COMMIT="${GH_TAG}"
		EGIT_REPO_URI="https://github.com/${GH_USER}/${GH_REPO}.git"
		;;
	*)
		die "Invalid GH_BUILD_TYPE: '${GH_BUILD_TYPE}'"
		;;
esac


HOMEPAGE="https://github.com/${GH_USER}/${GH_REPO}"

# prefer GitHub servers over mirrors
RESTRICT+=' primaryuri'


EXPORT_FUNCTIONS src_unpack


# @FUNCTION: github_src_unpack
# @DESCRIPTION:
# Function for unpacking Github packages
github_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	case "${GH_BUILD_TYPE}" in
		'live') git-r3_src_unpack ;;
		'release') vcs-snapshot_src_unpack ;;
		*) die ;;
	esac
}

_GH_ECLASS=1
fi
