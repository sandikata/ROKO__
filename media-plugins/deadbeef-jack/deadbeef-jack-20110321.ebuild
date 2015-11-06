# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit deadbeef-plugins

GITORIOUS_COMMIT="62d1e6ac0452b7baa92fcc75b59bcb960df06da8"

DESCRIPTION="DeaDBeeF jack output plugin"
HOMEPAGE="https://gitorious.org/deadbeef-sm-plugins/jack"
SRC_URI="https://gitorious.org/deadbeef-sm-plugins/jack/archive/${GITORIOUS_COMMIT}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
KEYWORDS="~*"

RDEPEND+=" media-sound/jack-audio-connection-kit:0"

DEPEND="${RDEPEND}"

S="${WORKDIR}/deadbeef-sm-plugins-jack"

src_prepare() {
	epatch "${FILESDIR}/${PN}.patch"
}
