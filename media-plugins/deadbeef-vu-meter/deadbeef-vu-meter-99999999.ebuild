# Distributed under the terms of the GNU General Public License v2

EAPI="5"

DEADBEEF_GUI="yes"

inherit deadbeef-plugins git-r3

DESCRIPTION="DeaDBeeF vu meter plugin"
HOMEPAGE="https://github.com/cboxdoerfer/ddb_vu_meter"
EGIT_REPO_URI="https://github.com/cboxdoerfer/ddb_vu_meter.git"

LICENSE="GPL-2"
KEYWORDS=""

src_compile() {
	use gtk2 && emake gtk2
	use gtk3 && emake gtk3
}
