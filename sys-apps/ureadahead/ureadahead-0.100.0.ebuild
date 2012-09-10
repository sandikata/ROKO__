# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2
inherit eutils linux-info

DESCRIPTION="Ureadahead - Read files in advance during boot"
HOMEPAGE="https://launchpad.net/ureadahead"
SRC_URI="http://launchpad.net/ureadahead/trunk/${PV}/+download/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="sys-libs/libnih
	sys-apps/util-linux
	>=sys-fs/e2fsprogs-1.41"

DEPEND="${RDEPEND}
	sys-devel/gettext
	dev-util/pkgconfig"

CONFIG_CHECK="~FTRACE ~DEBUG_FS"

src_prepare() {
	epatch "${FILESDIR}"/${P}-5.patch   # Downloaded from upstream
	epatch "${FILESDIR}"/${P}-gold.patch
}

src_configure() {
	econf --sbindir=/sbin
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	rm -r "${D}/etc/init"
	newinitd "${FILESDIR}"/ureadahead.initd ureadahead
	keepdir /var/lib/ureadahead
	dodoc TODO 0001-trace-add-trace-events-for-open-exec-an.patch
}

pkg_postinst() {
	elog "ureadahead needs some kernel tuning to work"
	elog "Kernel hacking -> Tracers (FTRACE)"
	elog "Kernel hacking -> Tracers -> Trace process context switches and events (ENABLE_DEFAULT_TRACERS)"
	elog "which should also select 'Kernel hacking -> Debug Filesystem' (DEBUG_FS))"
	elog "Also, you MAY have to apply 0001-trace-add-trace-events-for-open-exec-an.patch"
	elog "from /usr/share/doc/${PF}/ on your kernel source."
}
