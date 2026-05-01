# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson cargo gnome2-utils

WIREPLUMBER_RS_COMMIT="6e48383a85aecfca22dac3ffc589fb3f25404eda"

DESCRIPTION="Pipewire Volume Control"
HOMEPAGE="https://github.com/saivert/pwvucontrol"
SRC_URI="https://github.com/saivert/${PN}/releases/download/${PV}/${P}.tar.xz"

LICENSE="GPL-3"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD ISC MIT MPL-2.0
	Unicode-DFS-2016
"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	>=dev-libs/glib-2.66
	gui-libs/gtk:4
	>=gui-libs/libadwaita-1.2
	media-video/pipewire
	>=media-video/libwireplumber-compat-0.4.15:0.4
"
RDEPEND="${DEPEND}"

RUST_MIN_VER="1.80.0"

src_configure() {
	meson_src_configure

	# Use vendored crates with gentoo cargo config for offline build
	rm -rf "${WORKDIR}/cargo_home/gentoo"
	ln -s "${WORKDIR}/${P}/vendor" "${WORKDIR}/cargo_home/gentoo"
	ln -s "${WORKDIR}/cargo_home" "${BUILD_DIR}/cargo-home"

	# Added from .cargo/config to also replace git crates
	cat <<-EOF >> "${WORKDIR}/cargo_home/config.toml"
		[source."git+https://github.com/arcnmx/wireplumber.rs.git?rev=${WIREPLUMBER_RS_COMMIT}"]
		git = "https://github.com/arcnmx/wireplumber.rs.git"
		rev = "${WIREPLUMBER_RS_COMMIT}"
		replace-with = "gentoo"
		EOF
}

src_compile() {
	meson_src_compile
}

src_install() {
	meson_src_install
}

pkg_postinst() {
	gnome2_gconf_install
	gnome2_schemas_update
	xdg_icon_cache_update
}

pkg_postrm() {
	gnome2_gconf_uninstall
	gnome2_schemas_update
	xdg_icon_cache_update
}
