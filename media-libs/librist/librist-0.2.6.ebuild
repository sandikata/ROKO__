# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson-multilib

DESCRIPTION="Reliable Internet Streaming Transport"
HOMEPAGE="https://code.videolan.org/rist/librist/"
SRC_URI="https://code.videolan.org/rist/librist/-/archive/v${PV}/${PN}-v${PV}.tar.bz2"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

S="${WORKDIR}/${PN}-v${PV}"
