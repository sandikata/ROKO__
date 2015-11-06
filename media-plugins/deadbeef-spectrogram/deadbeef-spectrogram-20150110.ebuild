# Distributed under the terms of the GNU General Public License v2

EAPI="5"

DEADBEEF_GUI="yes"

inherit deadbeef-plugins

GITHUB_COMMIT="8d1b3713f3a3a8a93b4934a4782fb3db7f744fb7"

DESCRIPTION="DeaDBeeF spectrogram plugin"
HOMEPAGE="https://github.com/cboxdoerfer/ddb_spectrogram"
SRC_URI="https://github.com/cboxdoerfer/ddb_spectrogram/archive/${GITHUB_COMMIT}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~*"

RDEPEND+=" sci-libs/fftw:3.0="

DEPEND="${RDEPEND}"

S="${WORKDIR}/ddb_spectrogram-${GITHUB_COMMIT}"

src_prepare() {
	epatch "${FILESDIR}/${PN}-cflags.patch"
}

src_compile() {
	use gtk2 && emake gtk2
	use gtk3 && emake gtk3
}
