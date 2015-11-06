# Distributed under the terms of the GNU General Public License v2

EAPI="5"

DEADBEEF_GUI="yes"

inherit autotools deadbeef-plugins

GITHUB_COMMIT="68e1a92339be65cbeda09304e74f1744ff1c127d"

DESCRIPTION="DeaDBeeF filebrowser plugin that resemble foobar2k music library"
HOMEPAGE="https://github.com/JesseFarebro/deadbeef-librarybrowser"
SRC_URI="https://github.com/JesseFarebro/${PN}/archive/${GITHUB_COMMIT}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~*"

RDEPEND+=" !media-plugins/deadbeef-fb:0"

DEPEND="${RDEPEND}"

S="${WORKDIR}/${PN}-${GITHUB_COMMIT}"

src_prepare() {
	epatch "${FILESDIR}/${PN}-avoid-version.patch"

	eautoreconf
}

src_configure() {
	econf --disable-static \
		$(use_enable gtk2) \
		$(use_enable gtk3)
}
