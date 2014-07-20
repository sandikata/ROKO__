# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit git-2 autotools-utils

DESCRIPTION="Encrypted, P2P, messenging, audio and video calling platform"
HOMEPAGE="https://tox.im"
EGIT_REPO_URI="https://github.com/irungentoo/toxcore"
AUTOTOOLS_AUTORECONF="1"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="+av logging ntox daemon"

RDEPEND="
	dev-libs/libsodium
	daemon? ( dev-libs/libconfig )
	av? ( media-libs/libvpx
	      media-libs/opus )
	ntox? ( sys-libs/ncurses )"

DEPEND="${RDEPEND}"

src_configure() {
	local myeconfargs=(
		$(use_enable av)
		$(use_enable logging)
		$(use_enable ntox)
		$(use_enable daemon)
		--disable-tests
		--disable-testing
	)
	autotools-utils_src_configure
}

src_install() {
	autotools-utils_src_install

	use daemon && newinitd "${FILESDIR}"/initd tox-dht-daemon
}
