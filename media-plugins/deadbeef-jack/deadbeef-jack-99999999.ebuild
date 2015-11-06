# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit deadbeef-plugins git-r3

DESCRIPTION="DeaDBeeF jack output plugin"
HOMEPAGE="https://gitorious.org/deadbeef-sm-plugins/jack"
EGIT_REPO_URI="https://gitorious.org/deadbeef-sm-plugins/jack.git"

LICENSE="MIT"
KEYWORDS=""

RDEPEND="media-sound/jack-audio-connection-kit:0"

DEPEND="${RDEPEND}"

src_prepare() {
	epatch "${FILESDIR}/${PN}.patch"
}
