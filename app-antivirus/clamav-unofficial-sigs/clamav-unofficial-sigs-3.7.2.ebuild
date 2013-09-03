# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="Downloads and installs third-party clamav signatures"
HOMEPAGE="http://sourceforge.net/projects/unofficial-sigs"
SRC_URI="mirror://sourceforge/unofficial-sigs/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="app-antivirus/clamav"

# The script relies on either net-misc/socat, or Perl's
# IO::Socket::UNIX. We already depend on Perl, and Gentoo's Perl ships
# with IO::Socket::UNIX, so we can leave out net-misc/socat here.
RDEPEND="${DEPEND}
	app-crypt/gnupg
	dev-lang/perl
	net-dns/bind-tools
	net-misc/curl"

src_compile() {
	# First, fix the paths contained in the configuration file.
	sed -i  -e '$a\pkg_mgr="emerge"' \
		-e "\$a\\pkg_rm=\"emerge -C ${PN}\"" \
		-e 's~/var/run/clamd.socket~/var/run/clamav/clamd.sock~' \
		-e 's~/var/run/clamd.pid~/var/run/clamav/clamd.pid~' \
		${PN}.conf \
		|| die "failed to update paths in the ${PN}.conf file"

	# Now, change the script's working directory to point to
	# /var/lib/${PN}. We'll need to make this writable by the clamav
	# user during install.
	sed -i  -e "s~/usr/unofficial-dbs~/var/lib/${PN}~" ${PN}.conf \
		|| die 'failed to update the work_dir variable'
}

src_install() {
	dosbin ${PN}.sh || die

	# We set the script's working directory to /var/lib/${PN} in
	# src_compile, so make sure that the permissions are set correctly
	# here. By default, it runs as clamav/clamav.
	diropts -m0755 -o clamav -g clamav
	dodir /var/lib/${PN} || die "failed to create working directory"

	insinto /etc/logrotate.d
	doins ${PN}-logrotate || die

	insinto /etc
	doins ${PN}.conf || die

	doman ${PN}.8  || die
	dodoc CHANGELOG INSTALL README  || die
}

pkg_postinst() {
	elog "You will need to set up your /etc/${PN}.conf file."
	elog "For details, please see the ${PN}(8) manual page."
	elog ""
	elog "Don't forget to set user_configuration_complete=\"yes\"."
}
