# Distributed under the terms of the GNU General Public License v2

EAPI="5"

DEADBEEF_GUI="yes"

inherit deadbeef-plugins git-r3

DESCRIPTION="DeaDBeeF spectrogram plugin"
HOMEPAGE="https://github.com/cboxdoerfer/ddb_spectrogram"
EGIT_REPO_URI="https://github.com/cboxdoerfer/ddb_spectrogram.git"

LICENSE="GPL-2"
KEYWORDS=""

RDEPEND+=" sci-libs/fftw:3.0="

DEPEND="${RDEPEND}"

src_prepare() {
	epatch "${FILESDIR}/${PN}-cflags.patch"
}

src_compile() {
	use gtk2 && emake gtk2
	use gtk3 && emake gtk3
}
