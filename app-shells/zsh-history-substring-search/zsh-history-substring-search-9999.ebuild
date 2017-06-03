# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils git-r3

DESCRIPTION="A ZSH plugin to search history, a clean-room implementation of the Fish shell feature"
HOMEPAGE="https://github.com/zsh-users/zsh-history-substring-search"
SRC_URI=""
EGIT_REPO_URI="${HOMEPAGE}"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="app-shells/zsh"
RDEPEND="${DEPEND}"

S="$WORKDIR"/"$PN"-"$PV"

src_install() {
	dodir /usr/share/zsh/site-contrib/zsh-history-substring-search
	insinto /usr/share/zsh/site-contrib/zsh-history-substring-search
	doins "${S}"/zsh-history-substring-search.zsh
	dodoc "${S}"/README.md
}
