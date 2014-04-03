# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"
GCONF_DEBUG="no"
GNOME2_LA_PUNT="yes"

inherit autotools eutils gnome2

if [[ ${PV} == "9999" ]]; then
	ESVN_REPO_URI="http://gnome2-globalmenu.googlecode.com/svn/trunk/"
	SRC_URI=""
	inherit subversion
else
	MY_P=${P/_p/_}
	S="${WORKDIR}/${MY_P}"
	SRC_URI="http://gnome2-globalmenu.googlecode.com/files/${MY_P}.tar.bz2"
	KEYWORDS="~amd64"
fi

DESCRIPTION="Global menubar applet for Gnome2."
HOMEPAGE="http://code.google.com/p/gnome2-globalmenu/"

LICENSE="GPL-2"
SLOT="0"
IUSE="gnome +introspection xfce"

RDEPEND=">=x11-libs/gtk+-2.10:2
	>=dev-libs/glib-2.10:2
	gnome-base/gconf:2
	>=x11-libs/libwnck-2.16:1
	>=gnome-base/gnome-menus-2.16:0
	>=x11-libs/libX11-1.1.0
	gnome? (
		>=gnome-base/gnome-panel-2.16
		>=x11-libs/libnotify-0.4.4 )
	xfce? (
		>=xfce-base/xfce4-panel-4.4.3 )
"
DEPEND="${RDEPEND}
	dev-util/intltool
	virtual/pkgconfig
	>=dev-lang/vala-0.7.7:0.10"

src_unpack() {
	if [[ ${PV} == "9999" ]]; then
		subversion_src_unpack
	else
		unpack ${A}
	fi
	cd "${S}"
}

src_prepare() {
	G2CONF="${G2CONF}
		--docdir=/usr/share/doc/${PF}
		--without-gir
		$(use_with gnome gnome-panel)
		$(use_with xfce xfce4-panel)
		VALAC_BIN=$(type -P valac-0.10)"
		# Does not enable anything
		#$(use_with introspection gir)

	# INSTALL is not useful or existing depending on version
	sed 's/\(doc_DATA.*\)INSTALL/\1/' \
		-i Makefile.am || die "sed failed"

	# Fix compilation problem with --as-needed
	epatch "${FILESDIR}/${PN}-0.7.7-as-needed.patch"

	AT_M4DIR="autotools" eautoreconf

	gnome2_src_prepare
}