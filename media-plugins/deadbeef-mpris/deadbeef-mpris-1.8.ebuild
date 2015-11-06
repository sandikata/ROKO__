# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit autotools deadbeef-plugins

DESCRIPTION="DeaDBeeF MPRIS plugin"
HOMEPAGE="https://github.com/Serranya/deadbeef-mpris2-plugin"
SRC_URI="https://github.com/Serranya/deadbeef-mpris2-plugin/releases/download/v${PV}/deadbeef-mpris2-plugin-${PV}.tar.xz -> ${P}.tar.xz"

LICENSE="GPL-3"
KEYWORDS="~*"
IUSE=""

S="${WORKDIR}/${P/-mpris/}"

src_prepare() {
	eautoreconf
}

src_configure() {
	econf --disable-static
}
