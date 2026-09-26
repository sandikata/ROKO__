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

# Системни библиотеки, нужни за изпълнението на Tauri бинарния файл
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
	# 1. Бинарен файл
	if [[ -d usr/bin ]]; then
		dobin usr/bin/*
	fi

	# 2. Споделени библиотеки (ако има включени такива в пакета)
	if [[ -d usr/lib ]]; then
		dolib.so usr/lib/*
	fi

	# 3. .desktop файл за менюто
	if [[ -d usr/share/applications ]]; then
		domenu usr/share/applications/*.desktop
	fi

	# 4. Икони
	if [[ -d usr/share/icons ]]; then
		insinto /usr/share/icons
		doins -r usr/share/icons/*
	fi

	# 5. Ако пакетът инсталира съдържание в /opt/Submarine или /usr/lib/submarine
	if [[ -d opt ]]; then
		insinto /opt
		doins -r opt/*

		# Намираме изпълнимия файл в /opt и му даваме +x права
		local opt_bin
		opt_bin=$(find "${ED}/opt" -type f -name "submarine" -o -name "Submarine" 2>/dev/null)
		if [[ -n "${opt_bin}" ]]; then
			fperms +x "${opt_bin#${ED}}"
		fi

		# Символна връзка към /usr/bin, ако пакета няма такъв бинарен файл по подразбиране
		if [[ ! -f "${ED}/usr/bin/submarine" && -n "${opt_bin}" ]]; then
			dosym "../..${opt_bin#${ED}}" /usr/bin/submarine
		fi
	fi
}
