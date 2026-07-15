# Copyright 2024-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker desktop xdg

DESCRIPTION="HP Anyware PCoIP Client (formerly Teradici) - Ubuntu 24.04 build"
HOMEPAGE="https://anyware.hp.com/find/product/cloud-access-software/software-client-for-linux"
SRC_URI="https://dl.anyware.hp.com/pcoip-client/deb/ubuntu/pool/main/p/pcoip-client/pcoip-client_${PV}-24.04_amd64.deb"

LICENSE="HP-EULA"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="bindist mirror"

RDEPEND="
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtnetwork:5
	dev-qt/qtwidgets:5
	dev-qt/qtsvg:5
	media-libs/alsa-lib
	media-video/ffmpeg
	net-misc/curl
	sys-apps/pcsc-lite
	virtual/libudev
	x11-libs/libX11
"
DEPEND="${RDEPEND}"
BDEPEND="app-arch/dpkg"

S="${WORKDIR}"

src_unpack() {
	unpack_deb ${A}
}

src_install() {
	# Инсталиране на бинарните файлове
	if [[ -d usr/bin ]]; then
		into /usr
		dobin usr/bin/*
	fi

	# Обработка на библиотеките за Ubuntu 24.04 (multiarch пътища)
	if [[ -d usr/lib/x86_64-linux-gnu ]]; then
		insinto /usr/$(get_libdir)
		doins -r usr/lib/x86_64-linux-gnu/*
		find "${ED}/usr/$(get_libdir)" -type f -name "*.so*" -exec chmod 0755 {} +
	elif [[ -d usr/lib ]]; then
		insinto /usr/$(get_libdir)
		doins -r usr/lib/*
		find "${ED}/usr/$(get_libdir)" -type f -name "*.so*" -exec chmod 0755 {} +
	fi

	# Графични ресурси и .desktop файлове
	if [[ -d usr/share ]]; then
		insinto /usr/share
		doins -r usr/share/*
	fi
}
