# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="wireplumber"

LUA_COMPAT=( lua5-{3,4} )

inherit lua-single meson

DESCRIPTION="Compatibility version 4.x of libwireplumber - client library"
HOMEPAGE="https://gitlab.freedesktop.org/pipewire/wireplumber"
SRC_URI="https://gitlab.freedesktop.org/pipewire/${MY_PN}/-/archive/${PV}/${MY_PN}-${PV}.tar.bz2"

S="${WORKDIR}/${MY_PN}-${PV}"

LICENSE="MIT"
SLOT="0.4"
KEYWORDS="~amd64"
IUSE="elogind systemd"
IUSE+=" +lua_single_target_lua5-4"

REQUIRED_USE="
	${LUA_REQUIRED_USE}
	?? ( elogind systemd )
"

BDEPEND="
	dev-libs/glib
	dev-util/gdbus-codegen
	dev-util/glib-utils
	sys-devel/gettext
"

DEPEND=">=media-video/wireplumber-0.5[elogind?,systemd?]"
RDEPEND="${DEPEND}"

DOCS=( {NEWS,README}.rst )

src_prepare() {
	eapply "${FILESDIR}"/disable-endpoint-test.patch
	eapply_user
}

src_configure() {
	local emesonargs=(
		-Ddaemon=false
		-Dtools=false
		-Dmodules=true
		-Ddoc=disabled # Ebuild not wired up yet (Sphinx, Doxygen?)
		-Dintrospection=disabled # Only used for Sphinx doc generation
		-Dsystem-lua=true # We always unbundle everything we can
		-Dsystem-lua-version=$(ver_cut 1-2 $(lua_get_version))
		$(meson_feature elogind)
		$(meson_feature systemd)
	)

	meson_src_configure
}

src_install() {
	meson_src_install

	rm -rf "${D}/usr/share/locale/"
}

