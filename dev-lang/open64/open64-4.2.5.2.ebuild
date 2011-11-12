# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/open64/open64-4.2.1.ebuild,v 1.1 2009/04/28 13:11:03 patrick Exp $

EAPI="2"
SLOT="4.2.5"
LICENSE="GPL-2"

KEYWORDS="~amd64 ~x86"

IUSE=""
DESCRIPTION="The AMD open64 compiler suite."
HOMEPAGE="http://developer.amd.com/tools/open64/Pages/default.aspx"

# we build the fortran bits unconditionally for now. Makefile does autodetection.
#DEPEND="app-shells/tcsh
#	app-shells/zsh
#	=sys-devel/bison-2.5*
#	=sys-devel/gcc-4.2*"
#RDEPEND=""

#SRC_URI="mirror://sourceforge/${PN}/${P}-1.src.tar.bz2"
SRC_URI="http://download2-developer.amd.com/amd/open64/x86_open64-4.2.5.2-1.src.tar.bz2"
S=$WORKDIR/${P}-0

src_install() {
	export TOOLROOT="${D}"
	emake install || die
}
