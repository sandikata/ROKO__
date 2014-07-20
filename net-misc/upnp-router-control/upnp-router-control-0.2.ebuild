# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

DESCRIPTION="Control UPnP of a router"
HOMEPAGE="https://launchpad.net/upnp-router-control"
SRC_URI="http://launchpad.net/${PN}/trunk/${PV}/+download/${P}.tar.gz"

LICENSE="|| ( GPL-2 GPL-3 )"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+curl"

RDEPEND=">=net-libs/gupnp-0.14.1
	curl? ( net-misc/curl )
	x11-libs/gtk+:2"

DEPEND="${RDEPEND}
	dev-util/intltool"

src_configure() {
	econf $(use_enable curl libcurl)
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc README ChangeLog || die
}
