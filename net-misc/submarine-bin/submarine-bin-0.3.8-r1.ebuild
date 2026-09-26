# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg

DESCRIPTION="Submarine - Modern SSH, FTP, and SFTP client"
HOMEPAGE="https://github.com/SinaXhpm/Submarine"
SRC_URI="https://github.com/SinaXhpm/Submarine/releases/download/v${PV}/Submarine_${PV}_amd64.deb -> ${P}.deb"

S="${WORKDIR}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

# Dependencies for Tauri / WebKitGTK applications
RDEPEND="
	app-accessibility/at-spi2-core:2
	dev-libs/glib:2
	dev-libs/openssl
	media-libs/fontconfig
	media-libs/freetype
	net-libs/webkit-gtk:4.1
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/pango
"
DEPEND="${RDEPEND}"

src_unpack() {
	unpack_deb "${A}"
}

src_install() {
	# Install main binary as submarine-bin to avoid wrapper conflict
	if [[ -d usr/bin ]]; then
		exeinto /usr/bin
		local bin
		for bin in usr/bin/*; do
			newexe "${bin}" submarine-bin
		done
	fi

	# Install desktop entry
	if [[ -d usr/share/applications ]]; then
		domenu usr/share/applications/*.desktop
	fi

	# Install application icons
	if [[ -d usr/share/icons ]]; then
		insinto /usr/share/icons
		doins -r usr/share/icons/*
	fi

	# Install optional /opt contents if present in upstream package
	if [[ -d opt ]]; then
		insinto /opt
		doins -r opt/*
	fi

	# Launcher wrapper to fix WebKitGTK DMABUF click-through bug on Wayland
	cat << 'EOF' > "${T}/submarine"
#!/bin/sh
export GDK_BACKEND=wayland
export WEBKIT_DISABLE_DMABUF_RENDERER=1

if [ -f /opt/Submarine/submarine ]; then
	exec /opt/Submarine/submarine "$@"
else
	exec /usr/bin/submarine-bin "$@"
fi
EOF

	dobin "${T}/submarine"
}
