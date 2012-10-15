# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-irc/hexchat/hexchat-2.9.1.ebuild,v 1.1 2012/08/25 14:34:49 yngwin Exp $

EAPI=4

inherit eutils gnome2 git-2

DESCRIPTION="Graphical IRC client based on XChat"
#SRC_URI="https://github.com/downloads/hexchat/hexchat/${P}.tar.xz"
SRC_URI=""
EGIT_REPO_URI="https://github.com/hexchat/hexchat.git"
HOMEPAGE="http://www.hexchat.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="dbus fastscroll +gtk ipv6 libnotify mmx nls ntlm perl python spell ssl tcl"

RDEPEND=">=dev-libs/glib-2.6.0:2
	x11-libs/pango
	!<net-irc/xchat-gnome-0.9
	dbus? ( >=dev-libs/dbus-glib-0.71 )
	gtk? ( >=x11-libs/gtk+-2.10.0:2 )
	libnotify? ( x11-libs/libnotify )
	ntlm? ( net-libs/libntlm )
	perl? ( >=dev-lang/perl-5.8.0 )
	python? ( =dev-lang/python-2* )
	tcl? ( dev-lang/tcl )
	spell? ( app-text/gtkspell:2 )
	ssl? ( >=dev-libs/openssl-0.9.6d )"
DEPEND="${RDEPEND}
	sys-devel/gettext
	virtual/pkgconfig"

pkg_setup() {
	# Added for to fix a sparc seg fault issue by Jason Wever <weeve@gentoo.org>
	if [[ ${ARCH} = sparc ]] ; then
		replace-flags "-O[3-9]" "-O2"
	fi
}

src_prepare() {
#	epatch  "${FILESDIR}"/${PN}-2.9.1-input-box.patch \
#		"${FILESDIR}"/${PN}-2.8.8-cflags.patch
	epatch	"${FILESDIR}"/${PN}-2.9.3-cflags.patch

	# use $libdir/hexchat/plugins as the plugin directory
	if [[ $(get_libdir) != "lib" ]] ; then
		sed -e 's:${prefix}/lib/hexchat:${libdir}/hexchat:' \
			-i configure.ac || die 'sed failed'
	fi

	# QA: remove deprecated line from desktop file
	sed -e '/Encoding=UTF-8/d' -i ${PN}.desktop || die 'sed failed'

	./autogen.sh
}

src_configure() {
	econf --enable-shm \
		$(use_enable dbus) \
		$(use_enable ipv6) \
		$(use_enable mmx) \
		$(use_enable nls) \
		$(use_enable ntlm) \
		$(use_enable perl) \
		$(use_enable python) \
		$(use_enable spell spell gtkspell) \
		$(use_enable ssl openssl) \
		$(use_enable tcl) \
		$(use_enable gtk gtkfe) \
		$(use_enable !gtk textfe) \
		$(use_enable fastscroll xft)
}

src_install() {
	default
	prune_libtool_files --all

	# install plugin development header
	insinto /usr/include/hexchat
	doins src/common/xchat-plugin.h

	dodoc ChangeLog README*

	# remove useless desktop entry when gtk USE flag is unset
	if ! use gtk ; then
		rm "${ED}"/usr/share/applications -rf
	fi
}

pkg_postinst() {
	if use !gtk ; then
		elog "You have disabled the gtk USE flag. This means you don't have"
		elog "the GTK-GUI for HexChat but only a text interface called \"hexchat-text\"."
	fi
	gnome2_icon_cache_update
}
