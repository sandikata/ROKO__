# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit qt4-r2 subversion

DESCRIPTION="UMPlayer is the multimedia player that fills all your needs"
HOMEPAGE="http://www.umplayer.com/"
SRC_URI=""
ESVN_REPO_URI="https://umplayer.svn.sourceforge.net/svnroot/umplayer/umplayer/trunk"
ESVN_PROJECT="umplayer"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="debug"

DEPEND="x11-libs/qt-gui:4
	>=dev-libs/quazip-0.4.3-r1"
RDEPEND="${DEPEND}
	media-video/mplayer[ass,png]"

S="${WORKDIR}/${PN}"

PATCHES=("${FILESDIR}/${PN}-unbundle-quazip.patch")

src_prepare() {
	# Upstream Makefile sucks
	sed -i -e "/^PREFIX=/s:/usr/local:/usr:" \
		-e "/^DOC_PATH=/s:packages/umplayer:${PF}:" \
		-e '/\.\/get_svn_revision\.sh/,+2c\
	cd src && $(DEFS) $(MAKE)' \
		"${S}"/Makefile || die "sed failed"

	# Turn debug message flooding off
	if ! use debug ; then
		sed -i 's:# \(DEFINES += NO_DEBUG_ON_CONSOLE\):\1:g' \
			"${S}"/src/umplayer.pro || die "sed failed"
	fi

	qt4-r2_src_prepare
}

src_configure() {
	cd "${S}"/src
	eqmake4
}

src_install() {
	# remove unneeded copies of GPL
	rm -f Copying.txt gpl.txt docs/{cs,en,hu,it,ja,ru}/gpl.html
	rm -rf docs/{de,es,nl,ro}

	# remove windows-only files
	rm "${S}"/*.bat

	emake DESTDIR="${D}" install || die
	prepalldocs
}
