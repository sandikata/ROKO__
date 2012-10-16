# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

inherit mercurial

DESCRIPTION="This is a program to update all files from various live repositories in portage"
HOMEPAGE="http://code.google.com/p/arcon/source/"
EHG_REPO_URI="http://ule.arcon.googlecode.com/hg/"
LICENSE="GPL-2"

KEYWORDS=""
SLOT="0"
IUSE=""

DEPENDS=">=app-shells/bash-3*
	sys-apps/findutils"

src_install() {
	insinto /etc/ule
	doins ule.conf
	dobin update-live-ebuilds
	doman doc/update-live-ebuilds.8
}
