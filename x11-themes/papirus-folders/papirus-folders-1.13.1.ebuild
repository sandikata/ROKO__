# Copyright 2018-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Allows changing the color of folders in Papirus icon theme"
HOMEPAGE="https://github.com/PapirusDevelopmentTeam/papirus-folders"
SRC_URI="https://github.com/PapirusDevelopmentTeam/papirus-folders/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="x11-themes/papirus-icon-theme"

src_install() {
	ZSHCOMPDIR="/usr/share/zsh/site-functions" default
}
