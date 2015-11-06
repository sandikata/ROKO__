# Distributed under the terms of the GNU General Public License v2

EAPI="5"

DEADBEEF_GUI="yes"

inherit deadbeef-plugins

GITHUB_COMMIT="940d8d72a46993619c3fba4cde5e30c95f5a4b82"

DESCRIPTION="DeaDBeeF vu meter plugin"
HOMEPAGE="https://github.com/cboxdoerfer/ddb_vu_meter"
SRC_URI="https://github.com/cboxdoerfer/ddb_vu_meter/archive/${GITHUB_COMMIT}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~*"

S="${WORKDIR}/ddb_vu_meter-${GITHUB_COMMIT}"

src_compile() {
	use gtk2 && emake gtk2
	use gtk3 && emake gtk3
}
