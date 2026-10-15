# Copyright 2023-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="A free and open-source typeface for developers"
HOMEPAGE="https://github.com/githubnext/monaspace"

SRC_BASE="https://github.com/githubnext/monaspace/releases/download/v${PV}"

SRC_URI="
	frozen? ( ${SRC_BASE}/monaspace-frozen-v${PV}.zip )
	otf? ( ${SRC_BASE}/monaspace-static-v${PV}.zip )
	variable? ( ${SRC_BASE}/monaspace-variable-v${PV}.zip )
"

S="${WORKDIR}"
LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64"

FONT_S="${WORKDIR}/total"
FONT_SUFFIX=""
IUSE="frozen +otf variable"
REQUIRED_USE="|| ( frozen otf variable )"

BDEPEND="app-arch/unzip"

src_prepare() {
	default

	mkdir -p "${FONT_S}" || die

	if use frozen ; then
		# В zip архива файловете са директно в корена или в monaspace-frozen-v1.400/
		find "${WORKDIR}" -maxdepth 2 -type f \( -name "*.ttf" -o -name "*.otf" \) -exec mv {} "${FONT_S}/" \;
		FONT_SUFFIX="${FONT_SUFFIX} ttf otf"
	fi

	if use otf ; then
		find "${WORKDIR}" -maxdepth 3 -type f \( -name "*.otf" -o -name "*.ttf" \) -exec mv {} "${FONT_S}/" \;
		FONT_SUFFIX="${FONT_SUFFIX} otf ttf"
	fi

	if use variable ; then
		find "${WORKDIR}" -maxdepth 3 -type f -name "*.ttf" -exec mv {} "${FONT_S}/" \;
		FONT_SUFFIX="${FONT_SUFFIX} ttf"
	fi
}
