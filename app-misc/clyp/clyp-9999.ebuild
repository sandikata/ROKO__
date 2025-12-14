# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit desktop git-r3 go-module golang-build xdg

DESCRIPTION="A clipboard manager written in Go using Gtk4/libadwaita"
HOMEPAGE="https://github.com/murat-cileli/clyp"
EGIT_REPO_URI="https://github.com/murat-cileli/clyp.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS=""

RDEPEND="
	>=gui-libs/gtk-4.18
	dev-libs/glib
	dev-libs/gobject-introspection
	media-libs/graphene
	x11-libs/cairo
	x11-libs/pango
	x11-libs/gdk-pixbuf
	app-shells/bash
"
DEPEND="${RDEPEND}
	dev-lang/go
	dev-vcs/git
	dev-util/pkgconf
	sys-devel/gcc
"

EGO_PN="github.com/murat-cileli/clyp"

src_unpack() {
    git-r3_src_unpack
}

src_compile() {

	# Ensure CGO is enabled to link against Gtk4 C libraries
	export CGO_ENABLED=1

	golang-build_src_compile
}

src_install() {
	dobin "${PN}"

	insinto /usr/share/applications/
	domenu ${FILESDIR}/clyp.desktop

	insinto /etc/xdg/autostart
	doins ${FILESDIR}/clyp-watcher.desktop

	local size
	for size in 16x16 32x32 48x48 128x128 256x256 512x512; do
		# Replace "icons/clyp-${size}.png" with the actual path to your icon files in the source tree
		newicon -s "${size}" "${WORKDIR}/${PN}-${PV}/data/icons/hicolor/${size}/apps/bio.murat.clyp.png" "bio.murat.clyp.png"
	done
}

pkg_postinst() {
        xdg_pkg_postinst
}

