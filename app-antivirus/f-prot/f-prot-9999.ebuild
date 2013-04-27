# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
#Based on: $Header: /var/cvsroot/gentoo-x86/app-antivirus/f-prot/f-prot-4.6.7.ebuild,v 1.4 2007/01/23 15:28:33 genone Exp $

inherit eutils

IUSE=""

MY_P="fp-Linux.x86.32-ws"
S=${WORKDIR}/${PN}

DESCRIPTION="Frisk Software's f-prot virus scanner"
HOMEPAGE="http://www.f-prot.com/"
SRC_URI="http://files.f-prot.com/files/unix-trial/${MY_P}.tar.gz"
DEPEND=""
# unzip and perl are needed for the check-updates.pl script
RDEPEND=">=app-arch/unzip-5.42-r1
	dev-lang/perl
	dev-perl/libwww-perl
	amd64? ( >=app-emulation/emul-linux-x86-baselibs-1.0 )"
PROVIDE="virtual/antivirus"

SLOT="current"
LICENSE="F-PROT"
KEYWORDS="amd64 -ppc -sparc x86"

src_install() {
	cd ${S}

	dodoc doc/*
	dodoc README
	dohtml doc/html/*
	doman doc/man/*
	insinto /opt/f-prot
	insopts -m 755 
	doins fpscan
	doins fpupdate
	insopts -m 644
	doins license.key
	doins product.data
	doins product.data.default
	doins *.def
	dodir /usr/bin
	dosym /opt/f-prot/fpscan /usr/bin/fpscan
	newins f-prot.conf.default f-prot.conf
	dodir /etc
	dosym /opt/f-prot/f-prot.conf /etc/f-prot.conf

	dodir /opt/f-prot/tools /var/tmp/f-prot
	keepdir /var/tmp/f-prot
	min=$( date +%S )
	echo  "#Start fpupdate, every hour, distribute over the hour" >fp-update.cron
	echo  "$min * * * *  /opt/f-prot/fpupdate >/dev/null " >>fp-update.cron
	insinto /etc/cron.d
	doins	fp-update.cron
}

pkg_postinst() {
	elog
	elog "We've generated the following crontab entries to update the"
	elog "antivir.def file via fpupdate. Updates will be run hourly at a"
	elog "randomly picked minute to distribute load, and thus make your updates"
	elog "faster than if they were run during obvious high load times, e.g. on"
	elog "the hour."
	elog
	elog  "$min * * * *  /opt/f-prot/fpupdate >/dev/null " 
}

