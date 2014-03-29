# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
#
# polyc_ebuilds.eclass: eclass for all _pre ebuilds created by me, Polynomial-C

MY_PV="${PV%_*}"
MY_P="${PN}-${MY_PV}"

S="${WORKDIR}/${MY_P}"

RESTRICT="mirror"
