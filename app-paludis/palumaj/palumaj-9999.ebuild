# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"
inherit git-2

DESCRIPTION="Tool to keep your Gentoo/GNU/Linux up to date using cave"
HOMEPAGE="https://github.com/Keruspe/palumaj"
SRC_URI=""
EGIT_REPO_URI="git://github.com/Keruspe/palumaj"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="ask"

DEPEND=""
RDEPEND="sys-apps/paludis[ask?]"

src_install() {
	dosbin ${S}/palumaj 
}
