# Lara Maia <dev@lara.click> 2014~2016
# Distributed under the terms of the GNU General Public License v2

EAPI=5
inherit git-r3 autotools

DESCRIPTION="Provides CPU identification for x86 (and x86_64)"
HOMEPAGE="https://github.com/anrieff/libcpuid"
LICENSE="BSD-2"

EGIT_REPO_URI="git://github.com/anrieff/$PN.git"

KEYWORDS="~amd64 ~x86"
SLOT=0
RESTRICT="mirror"

DEPEND="dev-vcs/git
		 sys-devel/libtool
		 sys-devel/autoconf"
RDEPEND="sys-libs/glibc"

src_prepare() {
	_elibtoolize
	eautoreconf
}
