# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python2_7 )
inherit git-r3 distutils-r1

DESCRIPTION="Quickly check the weather with this stylish web app"
HOMEPAGE="https://github.com/kd8bny/cumulus/"
#SRC_URI=""
EGIT_REPO_URI="https://github.com/kd8bny/cumulus"

LICENSE=""
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND="dev-python/python-distutils-extra"
RDEPEND="${DEPEND}"
BDEPEND=""

src_prepare() {
	distutils-r1_src_prepare
}

src_configure() {
	distutils-r1_src_configure
}

src_install() {
	distutils-r1_src_install
}
