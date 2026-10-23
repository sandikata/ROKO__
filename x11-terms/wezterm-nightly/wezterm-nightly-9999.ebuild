# Copyright 2026 Rosen Aleksandrov
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RUST_MIN_VER="1.93"

inherit cargo desktop git-r3 shell-completion xdg-utils

DESCRIPTION="A GPU-accelerated cross-platform terminal emulator and multiplexer"
HOMEPAGE="https://wezterm.org/"

EGIT_REPO_URI="https://github.com/wezterm/wezterm.git"
# wezterm vendors freetype, harfbuzz, libpng, zlib, finl_unicode and
# xcb-imdkit as git submodules; fetch them all
EGIT_SUBMODULES=( '*' )

LICENSE="MIT OFL-1.1"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 BSD-2 BSD CC0-1.0 ISC LGPL-2.1 MIT MPL-2.0 UoI-NCSA
	Unicode-3.0 Unicode-DFS-2016 WTFPL-2 ZLIB
"
SLOT="0"
IUSE="wayland"
PROPERTIES="live"
# live ebuild: cargo fetches crates from the network; tests need network too
RESTRICT="test"

DEPEND="
	dev-libs/libgit2
	dev-libs/openssl
	wayland? ( dev-libs/wayland )
	media-fonts/jetbrains-mono
	media-fonts/noto
	media-fonts/noto-emoji
	media-fonts/roboto
	media-libs/fontconfig
	media-libs/libpng
	media-libs/mesa
	sys-apps/dbus
	x11-libs/cairo[X]
	x11-libs/libX11
	x11-libs/libxkbcommon[X,wayland?]
	x11-libs/xcb-imdkit
	x11-libs/xcb-util
	x11-libs/xcb-util-image
	x11-libs/xcb-util-keysyms
	x11-libs/xcb-util-wm
	x11-themes/hicolor-icon-theme
	x11-themes/xcursor-themes
	virtual/zlib
"
RDEPEND="${DEPEND}"
BDEPEND="
	dev-build/cmake
	dev-vcs/git
	virtual/pkgconfig
"

QA_FLAGS_IGNORED="
	usr/bin/.*
"

src_unpack() {
	git-r3_src_unpack
	# resolves Cargo.lock and fetches the crates (needs network access,
	# i.e. FEATURES="-network-sandbox" or a per-package package.env)
	cargo_live_src_unpack
}

src_prepare() {
	# no patches are applied here on purpose: the ones for the snapshot
	# ebuild (finl_unicode no_std, xcb-imdkit) are tied to specific
	# submodule commits and may not apply to current HEAD.
	# Add them back if the build fails without them.

	# wezterm's build.rs reads the version string from .tag
	echo "9999-${EGIT_VERSION::8}-gentoo" > .tag || die

	default
}

src_configure() {
	local myfeatures=(
		distro-defaults
		vendor-nerd-font-symbols-font
		$(usev wayland)
	)
	cargo_src_configure --no-default-features
}

src_compile() {
	cargo_src_compile
}

src_install() {
	exeinto /usr/bin
	doexe "$(cargo_target_dir)/wezterm"
	doexe "$(cargo_target_dir)/wezterm-gui"
	doexe "$(cargo_target_dir)/wezterm-mux-server"
	doexe "$(cargo_target_dir)/strip-ansi-escapes"

	insinto /usr/share/icons/hicolor/128x128/apps
	newins assets/icon/terminal.png org.wezfurlong.wezterm.png

	newmenu assets/wezterm.desktop org.wezfurlong.wezterm.desktop

	insinto /usr/share/metainfo
	newins assets/wezterm.appdata.xml org.wezfurlong.wezterm.appdata.xml

	newbashcomp assets/shell-completion/bash ${PN}
	newzshcomp assets/shell-completion/zsh _${PN}
	newfishcomp assets/shell-completion/fish ${PN}.fish
}

pkg_postinst() {
	xdg_icon_cache_update
	einfo "It may be necessary to configure wezterm to use a cursor theme, see:"
	einfo "https://wezterm.org/faq.html#i-use-x11-or-wayland-and-my-mouse-cursor-theme-doesnt-seem-to-work"
	einfo "It may be necessary to set the environment variable XCURSOR_PATH"
	einfo "to the directory containing the cursor icons, for example"
	einfo 'export XCURSOR_PATH="/usr/share/icons"'
	einfo "before starting the wayland or X11 window compositor to avoid the error:"
	einfo "ERROR  window::os::wayland::frame > Unable to set cursor to left_ptr: cursor not found"
	einfo "For example, in the file ~/.wezterm.lua:"
	einfo "return {"
	einfo '  xcursor_theme = "whiteglass"'
	einfo "}"
}

pkg_postrm() {
	xdg_icon_cache_update
}
