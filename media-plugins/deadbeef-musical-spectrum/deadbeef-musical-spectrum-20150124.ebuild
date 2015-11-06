# Distributed under the terms of the GNU General Public License v2=

EAPI="5"

DEADBEEF_GUI="yes"

inherit deadbeef-plugins

GITHUB_COMMIT="ce0f4daaf295186d9d89787870997bbd8e93c674"

DESCRIPTION="DeaDBeeF musical spectrum plugin"
HOMEPAGE="https://github.com/cboxdoerfer/ddb_musical_spectrum"
SRC_URI="https://github.com/cboxdoerfer/ddb_musical_spectrum/archive/${GITHUB_COMMIT}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~*"

RDEPEND+=" sci-libs/fftw:3.0="

DEPEND="${RDEPEND}"

S="${WORKDIR}/ddb_musical_spectrum-${GITHUB_COMMIT}"

src_prepare() {
	epatch "${FILESDIR}/${PN}-cflags.patch"
}

src_compile() {
	use gtk2 && emake gtk2
	use gtk3 && emake gtk3
}
