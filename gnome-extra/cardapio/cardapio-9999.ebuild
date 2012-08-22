# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
inherit bzr

DESCRIPTION="A lean application menu and launcher."
HOMEPAGE="https://launchpad.net/cardapio"
unset SRC_URI
EBZR_REPO_URI="lp:cardapio"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="all +stand-alone gnomepanel docky awn gnomeshell"

DEPEND="
	dev-python/pygtk
	x11-misc/xdg-user-dirs-gtk
	dev-libs/keybinder[python]
	gnome-base/gnome-menus[python]
	dev-python/gnome-applets-python
	gnomepanel? ( 
		gnome-base/gnome-control-center
		)
	docky? (
		gnome-extra/docky
	)
	awn? (
		gnome-extra/avant-window-navigator
	)
	gnomeshell? (
		gnome-base/gnome-shell
	)
"
RDEPEND="${DEPEND}"

REQUIRED_USE="	all? ( gnomepanel docky awn gnomeshell )
				all? ( !stand-alone )
				stand-alone? ( !gnomepanel !docky !awn !gnomeshell )
				|| ( stand-alone gnomepanel docky awn gnomeshell )
"

src_install() {
	if use all; then
		emake DESTDIR="${D}" install || die "Install failed"
	elif use gnomepanel; then
		emake DESTDIR="${D}" install-panel || die "Install failed"
	elif use docky; then
		emake DESTDIR="${D}" install-docky || die "Install failed"
	elif use awn; then
		emake DESTDIR="${D}" install-awn || die "Install failed"
	elif use gnomeshell; then
		emake DESTDIR="${D}" install-shell || die "Install failed"
	else
		emake DESTDIR="${D}" install-alone || die "Install failed"
	fi
	dodoc README AUTHORS || die
}
