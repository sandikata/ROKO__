# Distributed under the terms of the GNU General Public License v2

EAPI="5"

DEADBEEF_GUI="yes"

inherit deadbeef-plugins

DESCRIPTION="DeaDBeeF waveform seekbar plugin"
HOMEPAGE="https://github.com/cboxdoerfer/ddb_waveform_seekbar"
SRC_URI="https://github.com/cboxdoerfer/ddb_waveform_seekbar/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~*"

RDEPEND+=" dev-db/sqlite:3"

DEPEND="${RDEPEND}"

S="${WORKDIR}/ddb_waveform_seekbar-${PV}"

src_prepare() {
	epatch "${FILESDIR}/${PN}-cflags-lm.patch"
}

src_compile() {
	use gtk2 && emake gtk2
	use gtk3 && emake gtk3
}
