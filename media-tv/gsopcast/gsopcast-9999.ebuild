# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

inherit subversion eutils autotools 

ESVN_REPO_URI="http://gsopcast.googlecode.com/svn/trunk"
ESVN_PROJECT="gsopcast"

DESCRIPTION="a gtk front-end of p2p TV sopcast" 
SRC_URI=""
HOMEPAGE="http://lianwei3.googlepages.com/home2"

IUSE=""
SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~x86"

DEPEND="
    net-misc/curl
    media-libs/alsa-lib
    >=x11-libs/gtk+-2"
RDEPEND="${DEPEND}" 

pkg_setup() {
   ewarn "This is a LIVE SVN ebuild."
   ewarn "That means there are NO promises it will work."
}

src_compile() {
        eautoreconf
	./autogen.sh
	econf || die "configure failed"
	emake || die "make failed"
}


src_install() {
        einstall || die
}

