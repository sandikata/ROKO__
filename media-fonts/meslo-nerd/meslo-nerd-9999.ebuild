# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit font

DESCRIPTION="Customized version of Apple's Menlo font, patched by romkatv"
HOMEPAGE="https://github.com/romkatv/powerlevel10k-media"
SRC_URI="
	https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
	https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
	https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
	https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
"

LICENSE="Apache-2.0"
SLOT="0"

KEYWORDS="~amd64 ~x86 live"

FONT_SUFFIX="ttf"

S="${DISTDIR}"
