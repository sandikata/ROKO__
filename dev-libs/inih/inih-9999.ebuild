# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit meson multilib-minimal ninja-utils

DESCRIPTION="Simple .INI file parser for C/C++"
HOMEPAGE="https://github.com/benhoyt/inih"

if [[ ${PV} = "9999" ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/benhoyt/inih.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/benhoyt/inih/archive/r${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="BSD"
SLOT="0"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

if ! [[ ${PV} = "9999" ]]; then
	S="${WORKDIR}/${PN}-r${PV}"
fi

multilib_src_configure() {
	local emesonargs=(
		-Ddistro_install=true
		-Dwith_INIReader=true
		--default-library=shared
	)
	meson_src_configure
}

multilib_src_compile() {
	meson_src_compile
}

multilib_src_install() {
	meson_src_install
}
