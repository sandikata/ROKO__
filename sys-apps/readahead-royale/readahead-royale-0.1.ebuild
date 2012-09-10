# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="royale readahead after http://forums.gentoo.org/viewtopic-t-478491-start-0.html"
#SRC_URI="http://gentoo.j-schmitz.net/portage-overlay/sys-apps/readahead-royale/${P}.tar.bz2"
SRC_URI="https://repos.j-schmitz.net/svn/pub/portage-overlay/!svn/bc/1784/distfiles/ALL/${P}.tar.bz2"
HOMEPAGE="http://forums.gentoo.org/viewtopic-t-478491.html"
RESTRICT="mirror"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RDEPEND="sys-process/lsof
		sys-apps/gawk"
DEPEND=""
RESTRICT="mirror"

src_install() {
	insinto /etc/
	doins readahead-royale.conf
	doinitd readahead-royale
	exeinto /usr/sbin/
	doexe uniquer sample-init-process
	touch "${D}"/forcesampler
}

pkg_postinst(){
	einfo
	einfo "Remember to add readahead-royale to the default runlevel"
	einfo "rc-update add readahead-royale default"
	einfo
	einfo "To create a new list just"
	einfo "touch /forcesampler"
}
