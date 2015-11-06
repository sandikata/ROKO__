# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit deadbeef-plugins

GITHUB_COMMIT="8e95cd380ba457fe6b666e5e704aa823d5eca1fa"

DESCRIPTION="DeaDBeeF gnome (via dbus) multimedia keys plugin"
HOMEPAGE="https://github.com/barthez/deadbeef-gnome-mmkeys"
SRC_URI="https://github.com/barthez/${PN}/archive/${GITHUB_COMMIT}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~*"

RDEPEND+=" sys-apps/dbus:0"

S="${WORKDIR}/${PN}-${GITHUB_COMMIT}"

src_prepare() {
	epatch "${FILESDIR}/${PN}.patch"
}
