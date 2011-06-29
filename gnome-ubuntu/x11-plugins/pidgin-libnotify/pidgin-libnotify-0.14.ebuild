# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils autotools

DESCRIPTION="pidgin-libnotify provides popups for pidgin via a libnotify interface"
HOMEPAGE="http://gaim-libnotify.sourceforge.net/"
SRC_URI="mirror://sourceforge/gaim-libnotify/${P}.tar.gz
	mirror://ubuntu/pool/main/p/${PN}/${PN}_${PV}-1ubuntu14.diff.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 hppa ppc x86"
IUSE="nls debug indicate ubuntu"

RDEPEND=">=x11-libs/libnotify-0.3.2
	net-im/pidgin[gtk]
	indicate? ( dev-libs/libindicate[gtk] )
	>=x11-libs/gtk+-2"

DEPEND="${RDEPEND}
	dev-util/pkgconfig"

RESTRICT="mirror"

src_prepare() {
	if use indicate; then
		cd "${WORKDIR}"
		epatch ${PN}_${PV}-1ubuntu14.diff
		cd "${S}"
		EPATCH_SOURCE="${S}/debian/patches" EPATCH_SUFFIX="patch" \
			EPATCH_FORCE="yes" epatch
		eautoreconf
	else
		epatch "${FILESDIR}"/pidgin-libnotify-showbutton.patch
		use ubuntu && epatch "${FILESDIR}"/no-action.patch
	fi
}

src_configure() {
	local myconf

	myconf="$(use_enable debug) \
			$(use_enable nls)"

	econf ${myconf} || die "configure failed"
}

src_install() {
	emake install DESTDIR="${D}" || die "make install failed"
	dodoc AUTHORS ChangeLog INSTALL NEWS README TODO VERSION || die
}
