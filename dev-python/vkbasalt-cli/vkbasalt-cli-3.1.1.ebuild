# Copyright 2022-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..12} )
inherit distutils-r1

DESCRIPTION="Command-line utility for vkBasalt"
HOMEPAGE="https://gitlab.com/TheEvilSkeleton/vkbasalt-cli"
SRC_URI="https://gitlab.com/TheEvilSkeleton/vkbasalt-cli/-/archive/v${PV}/vkbasalt-cli-v${PV}.tar.bz2 -> ${P}.tar.bz2"
S="${WORKDIR}/${PN}-v${PV}"

LICENSE="GPL-3 LGPL-3"
SLOT="0"
KEYWORDS="~amd64"

# No tests
RESTRICT="test"

RDEPEND="media-libs/vkBasalt"
