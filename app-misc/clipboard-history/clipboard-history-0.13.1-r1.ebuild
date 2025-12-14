# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
"

RUST_MIN_VER="9999"
inherit cargo desktop rust systemd xdg

DESCRIPTION="A clipboard history manager with server and multiple clients (Ringboard)"
HOMEPAGE="https://github.com/SUPERCILEX/clipboard-history"

SRC_URI="
	https://github.com/SUPERCILEX/clipboard-history/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/sandikata/ROKO__/releases/download/current/${PN}-${PV}-crates.tar.xz
"

LICENSE="Apache-2.0"

# Dependent crate licenses
LICENSE+="
	Apache-2.0 BSD-2 BSD Boost-1.0 CC0-1.0 ISC MIT MPL-2.0 UoI-NCSA
	Unicode-3.0 ZLIB
"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="egui ratatui cli systemd X wayland"

# Runtime dependencies needed by the compiled binaries
RDEPEND="
	systemd? ( >=sys-apps/systemd-232 )
	X? ( x11-libs/libxcb )
	wayland? ( dev-libs/wayland )
"
DEPEND="${RDEPEND}"
# Build dependencies for underlying C libraries (like wayland-client/server C libs)
BDEPEND="
	virtual/pkgconfig
"

RESTRICT="test mirror"

src_configure() {
	local myfeatures=(
		$(usev systemd)
	)

	if use egui; then
		myfeatures+=(
			$(usev wayland)
			$(usex X x11 '')
		)
	fi

	local mycargoconf=(
		--exclude "clipboard-history-client-sdk"
		$(usex cli "" "--exclude clipboard-history")
		$(usex egui "" "--exclude clipboard-history-egui")
		$(usex ratatui "" "--exclude clipboard-history-tui")
		$(usex X "" "--exclude clipboard-history-x11")
		$(usex wayland "" "--exclude clipboard-history-wayland")
	)

	cargo_src_configure --no-default-features --workspace "${mycargoconf[@]}"
}

src_install() {
	# TODO Try this
	# cargo_src_install

	# TODO to avoid this {{{
	# Install all compiled binaries to /usr/bin/
	dobin ${WORKDIR}/${PN}-${PV}/target/release/ringboard-server
	use egui && {
		dobin ${WORKDIR}/${PN}-${PV}/target/release/ringboard-egui
		domenu ${FILESDIR}/ringboard-egui.desktop
		newicon ${WORKDIR}/${PN}-${PV}/logo.jpeg ringboard.jpeg
	}
	use ratatui && dobin ${WORKDIR}/${PN}-${PV}/target/release/ringboard-tui
	use cli && dobin ${WORKDIR}/${PN}-${PV}/target/release/ringboard
	use X && dobin ${WORKDIR}/${PN}-${PV}/target/release/ringboard-x11
	use wayland && dobin ${WORKDIR}/${PN}-${PV}/target/release/ringboard-wayland
	# }}}

	# Install systemd user services
	if use systemd; then
		# NOTE: You must ensure the .service files are present in the source repo
		# or copied into the ebuild's FILESDIR. The `systemd` eclass handles
		# installation to the correct system paths (/usr/lib/systemd/user/).
		systemd_douserunit ${FILESDIR}/ringboard-server.service
		use X && systemd_douserunit ${FILESDIR}/ringboard-x11.service
		use wayland && systemd_douserunit ${FILESDIR}/ringboard-wayland.service
	fi
}
