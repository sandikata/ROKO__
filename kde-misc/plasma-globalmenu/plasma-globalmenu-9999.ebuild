# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

inherit cmake-utils
inherit git-2

EGIT_REPO_URI="git://gitorious.org/plasma-globalmenu-mod/plasma-globalmenu-mod.git"

DESCRIPTION="Plasma Global Menu support for GTK/GTK+ Applications"
HOMEPAGE="http://kde-apps.org/content/show.php?content=129006"

LICENSE="GPLv3"
SLOT="0"
KEYWORDS="~x86"
IUSE=""

DEPEND=">kde-base/plasma-workspace-4
		gnome-extra/gnome-globalmenu
"
RDEPEND="${DEPEND}"

