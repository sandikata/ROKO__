# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit deadbeef-plugins

GITORIOUS_COMMIT="d3990d772b02cdc6206f067748f5d1f9650616fb"

DESCRIPTION="DeaDBeeF simple stereo widener plugin"
HOMEPAGE="https://gitorious.org/deadbeef-sm-plugins/stereo-widener"
SRC_URI="https://gitorious.org/deadbeef-sm-plugins/stereo-widener/archive/${GITORIOUS_COMMIT}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
KEYWORDS="~*"

S="${WORKDIR}/deadbeef-sm-plugins-stereo-widener"

src_prepare() {
	epatch "${FILESDIR}/${PN}.patch"
}
