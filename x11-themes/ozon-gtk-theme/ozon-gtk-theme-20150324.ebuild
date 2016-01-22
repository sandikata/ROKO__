# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Ozon OS gtk theme"
HOMEPAGE="https://github.com/ozonos/${PN}"

if [[ ${PV} == "9999" ]] ; then
	inherit git-r3
	SRC_URI=""
	EGIT_REPO_URI="https://github.com/ozonos/${PN}.git"
	KEYWORDS=""
else
        inherit git-r3
	SRC_URI=""
        EGIT_REPO_URI="https://github.com/ozonos/${PN}.git"
	EGIT_COMMIT="adf550ebd4f68f2733d50d10810b04456ddcf870"
	KEYWORDS="~amd64 ~arm ~x86"
fi

LICENSE="GPL-3.0+"
SLOT="0"

DEPEND=">=x11-libs/gtk+-3.14
	x11-themes/gtk-engines-murrine
	>=dev-ruby/sass-3.2"
RDEPEND="${DEPEND}"

src_install() {
	emake DESTDIR="${D}" install
	dodoc README.md
}
