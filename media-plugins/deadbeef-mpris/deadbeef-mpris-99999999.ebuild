# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit autotools deadbeef-plugins git-r3

DESCRIPTION="DeaDBeeF MPRIS plugin"
HOMEPAGE="https://github.com/Serranya/deadbeef-mpris2-plugin"
EGIT_REPO_URI="https://github.com/Serranya/deadbeef-mpris2-plugin.git"

LICENSE="GPL-3"
KEYWORDS=""
IUSE=""

src_prepare() {
	eautoreconf
}

src_configure() {
	econf --disable-static
}
