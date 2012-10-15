# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit git-2

DESCRIPTION="A most excellent portage wrapper"
HOMEPAGE="http://weaver.gentooexperimental.org/update.html"
EGIT_REPO_URI="git://weaver.gentooexperimental.org/update.git"
RESTRICT="mirror"

LICENSE="CCPL-Attribution-ShareAlike-NonCommercial-3.0"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=""
RDEPEND=">app-shells/bash-3.1
   sys-apps/ed
   dev-util/dialog
   app-portage/portage-utils
   app-portage/gentoolkit
   net-misc/curl"


src_install() {
   insinto /etc || die
   doins warning || die
   insinto /usr || die
   dosbin update || die
   dolib libIgli || die
}
