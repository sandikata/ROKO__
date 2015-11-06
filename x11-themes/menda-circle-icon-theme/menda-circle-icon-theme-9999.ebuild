# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils git-r3

DESCRIPTION="Menda Circle Icon Theme"
HOMEPAGE="https://github.com/manjaro/menda-icon-themes"
SRC_URI=""
EGIT_REPO_URI="${HOMEPAGE}"

LICENSE="LGPL-3.0"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND="
	x11-themes/hicolor-icon-theme
	gnome-base/librsvg
"
RDEPEND="${DEPEND}"

src_prepare(){
	#Delete all broken symlinks
	rm Menda-Circle/apps/48x48/apps/chrome-pkclgpgponpjmpfokoepglboejdobkpl-Default.svg
    rm Menda-Circle/apps/scalable/chrome-pkclgpgponpjmpfokoepglboejdobkpl-Default.svg
 	rm Menda-Circle/places/scalable/edittrash.svg
 	rm Menda-Circle/places/scalable/stock_trash_full.svg
 	rm Menda-Circle/places/scalable/trashcan_full-new.svg
 	rm Menda-Circle/places/scalable/trashcan_full.svg

}

src_install(){
	insinto /usr/share/icons
	doins -r Menda-Circle
}
