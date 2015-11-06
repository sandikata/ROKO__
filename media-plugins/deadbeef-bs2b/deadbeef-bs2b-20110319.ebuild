# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit deadbeef-plugins

GITORIOUS_COMMIT="a1961cd2f0686a7bdf0915f1fc7d62b5aba369bd"

DESCRIPTION="DeaDBeeF bs2b dsp plugin"
HOMEPAGE="https://gitorious.org/deadbeef-sm-plugins/bs2b"
SRC_URI="https://gitorious.org/deadbeef-sm-plugins/bs2b/archive/${GITORIOUS_COMMIT}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
KEYWORDS="~*"

RDEPEND+=" media-libs/libbs2b:0"

DEPEND="${RDEPEND}"

S="${WORKDIR}/deadbeef-sm-plugins-bs2b"

src_prepare() {
	epatch "${FILESDIR}/${PN}.patch"
}
