# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit deadbeef-plugins git-r3

DESCRIPTION="DeaDBeeF bs2b dsp plugin"
HOMEPAGE="https://gitorious.org/deadbeef-sm-plugins/bs2b"
EGIT_REPO_URI="https://gitorious.org/deadbeef-sm-plugins/bs2b.git"

LICENSE="MIT"
KEYWORDS=""

RDEPEND+=" media-libs/libbs2b:0"

DEPEND="${RDEPEND}"

src_prepare() {
	epatch "${FILESDIR}/${PN}.patch"
}
