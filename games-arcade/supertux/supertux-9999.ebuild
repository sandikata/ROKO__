# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

ESVN_REPO_URI="http://supertux.lethargik.org/svn/supertux/trunk/supertux"

inherit cmake-utils games subversion

DESCRIPTION="Classic 2D jump'n run sidescroller game similar to SuperMario: Milestone 2"
HOMEPAGE="http://supertux.lethargik.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="2"
KEYWORDS=""
IUSE=""

DEPEND="dev-games/physfs
	dev-libs/boost
	media-libs/glew
	media-libs/libsdl
	media-libs/libvorbis
	media-libs/sdl-image
	media-libs/openal
	virtual/opengl"
RDEPEND="${DEPEND}"

S=${WORKDIR}/${PN}

src_configure() {
	epatch "${FILESDIR}/9999-fs-layout.patch"
	mycmakeargs=( "-DCMAKE_INSTALL_PREFIX=${GAMES_PREFIX}"
		"-DINSTALL_SUBDIR_SHARE=${GAMES_DATADIR}/${PN}/data"
		"-DAPPDATADIR=${GAMES_DATADIR}/${PN}" )
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}

src_install() {
	DOCS="CODINGSTYLE README TODO" cmake-utils_src_install
	doman man/man6/${PN}2.6
	prepgamesdirs
}
