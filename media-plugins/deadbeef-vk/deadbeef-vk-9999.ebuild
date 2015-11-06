# Distributed under the terms of the GNU General Public License v2

EAPI="5"

DEADBEEF_GUI="yes"

inherit cmake-utils deadbeef-plugins git-r3

DESCRIPTION="DeaDBeeF plugin for listening music from vkontakte.com"
HOMEPAGE="https://github.com/scorpp/db-vk"
EGIT_REPO_URI="https://github.com/scorpp/db-vk.git"

LICENSE="GPL-2"
KEYWORDS=""

RDEPEND+=" dev-libs/json-glib:0
	media-sound/deadbeef:0[curl]"

DEPEND="${RDEPEND}"

S="${WORKDIR}/db-vk-${PV}"

src_configure() {
	local mycmakeargs="
		$(cmake-utils_use_with gtk2 GTK2)
		$(cmake-utils_use_with gtk3 GTK3)"

	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}
