# Distributed under the terms of the GNU General Public License v2

EAPI="5"

DEADBEEF_GUI="yes"

inherit autotools deadbeef-plugins git-r3

EGIT_REPO_URI="git://git.code.sf.net/p/${PN}/code"
EGIT_BRANCH="master"

DESCRIPTION="DeaDBeeF filebrowser plugin"
HOMEPAGE="http://sourceforge.net/projects/deadbeef-fb"

LICENSE="GPL-2"
KEYWORDS=""

IUSE+=" debug"

RDEPEND+=" !media-plugins/deadbeef-librarybrowser:0"

DEPEND="${RDEPEND}"

src_prepare() {
	epatch "${FILESDIR}/${PN}-avoid-version.patch"

	eautoreconf
}

src_configure() {
	econf --disable-static \
		$(use_enable debug) \
		$(use_enable gtk2) \
		$(use_enable gtk3)
}
