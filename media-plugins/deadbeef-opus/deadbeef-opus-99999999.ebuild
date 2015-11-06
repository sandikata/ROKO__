# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit deadbeef-plugins git-r3

DESCRIPTION="DeaDBeeF ogg opus decoder plugin"
HOMEPAGE="https://bitbucket.org/Lithopsian/deadbeef-opus"
EGIT_REPO_URI="https://bitbucket.org/Lithopsian/${PN}.git"

RESTRICT+=" strip"

LICENSE="GPL-2"
KEYWORDS=""

RDEPEND+=" >=media-libs/opusfile-0.5:0[float,http]
	media-libs/libogg:0"

DEPEND="${RDEPEND}"
